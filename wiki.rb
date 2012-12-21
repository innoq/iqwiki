# Copyright 2012 innoQ Deutschland GmbH
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific
# language governing permissions and limitations under the License.



require 'rubygems'
require 'sinatra/base'
require 'neography'
require 'etherpad-lite'

require 'bluecloth'

require './wiki_node'
require './ether_pad_connector'

require 'PP'


class Wiki < Sinatra::Base
  
  def initialize
    super
    @neo = Neography::Rest.new
    @etherpad = EtherPadConnector.new( 'iq-wiki', true )
  end
  
  get '/' do
    
    result = @neo.execute_query("start n=node(0) match n-->c return c")
    
    result = result['data'].collect {|d| WikiNode.from_hash d }.to_s

    "#{pp result}" 
  end
  

  get '/new_page.html' do
    send_file 'new_page.html'
  end
  
  get '/:node_id' do

    node = Neography::Node.load( params[:node_id] )
    
    @node = node
    @new_url = "/#{ params[:node_id]}"
    @edit_url = @etherpad.get_edit_url node[ :title ]
    @content = @etherpad.get_raw_content node[ :title ]
    
    erb :page_view
  end
  
  
  post '/:node_id' do

    parent = Neography::Node.load( params[:node_id] )
    pad = @etherpad.create_pad( params[ :title ] )
    
    puts "=========="
    pp pad 
    puts "=========="
    
    child  = Neography::Node.create( :title => params[:title], :document_url => pad[:pad_readonly_url], :edit_url => pad[:pad_id] )    
    Neography::Relationship.create( "child", parent, child )
    redirect @etherpad.get_edit_url params[ :title ]
  end
  
end
