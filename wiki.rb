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
  
  
  helpers do 
    def nodes_to_li( nodes=[], separator='' )
      
      nodes.collect {|c| "<li>#{c.as_link}</li>" }.join(separator) unless nodes.nil?
    end
  end
  
  
  
  
  def initialize
    super
    @neo = Neography::Rest.new
    @etherpad = EtherPadConnector.new( 'iq-wiki', true )
  end
  
  
  before do
    @new_page_form_uri = "/new_page.html"    
  end
  
  
  get '/' do
    call env.merge("PATH_INFO" => '/0')
  end
  

  get '/new_page.html' do
    @parent_id = 0

    erb :new_page_form
  end
  
  
  
  get '/new_page.html/:parent_id' do
    @parent_id = params[:parent_id]
    
    erb :new_page_form
  end
  
  
  
  get '/:node_id' do

    node_id = params[:node_id]
    
    @node = load_wiki_node( node_id )

    @content = ''
    
    unless  node_id == '0'
      @edit_url = @etherpad.get_edit_url @node.title
      @content = BlueCloth.new( @etherpad.get_raw_content @node.title ).to_html
      @new_page_form_uri += "/#{node_id}"
    end
    
    @children = fetch_child_nodes_for( node_id )

    @bread_crumbs = fetch_bread_crumbs_for( node_id)
    
    erb :page_view
  end
  
  
  post '/:node_id' do

    parent = Neography::Node.load( params[:node_id] )
    pad = @etherpad.create_pad( params[ :title ] )
    
    child  = Neography::Node.create( :title => params[:title], :document_url => pad[:pad_readonly_url], :edit_url => pad[:pad_id] )    
    Neography::Relationship.create( "child", parent, child )
    redirect @etherpad.get_edit_url params[ :title ]
  end
  
  
  private 
  
  def fetch_bread_crumbs_for( node_id=0 )
    
    result = @neo.execute_query( "start n=node(#{node_id}) match n <-[*]-c return c" )
    result = result['data'].collect {|d| WikiNode.from_hash d }.reverse.<<( load_wiki_node node_id )
  end
  
  
  def fetch_child_nodes_for( node_id=0 )
    
    result = @neo.execute_query("start n=node(#{node_id}) match n-->c return c")
    
    result = result['data'].collect {|d| WikiNode.from_hash d }
  end
  
  def load_wiki_node( node_id=0 )
    node = @neo.get_node( node_id )
    
    WikiNode.from_hash node
  end
end
