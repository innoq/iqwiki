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



class EtherPadConnector
  
  
  def initialize( group_id = 'iq-wiki', connect_immediately = false )
    @group_id = group_id
    @etherpad_url = 'http://127.0.0.1:9001'
    @api_key = 'foobar'
    
    connect if connect_immediately
  end
  
  
  def connect 
    @ether = EtherpadLite.connect 9001, @api_key, '1.1'
  end
  
  
  def create_pad title
    raise "Connection to etherpad required!" if @ether.nil?
    
    pad = @ether.pad( title ) #ether.get_group( @group_id ).pad( title ) 
    pad.text = 'Please use markdown! Thanks!'
    
    { :pad_id => pad.id, :pad_url => pad.group_id, :pad_readonly_url => pad.read_only_id }
  end
  
  
  
  def get_raw_content padId
    raise "Connection to etherpad required!" if @ether.nil?

    pp @ether.get_pad( padId ).public_methods.sort
    
    @ether.get_pad( padId ).text
  end
  
  
  def get_edit_url padId
    
    pp @ether.get_pad( padId ).public_methods.sort
    @ether.get_pad( padId ).display
    
    "#{@ether.client.uri.to_s}/p/#{padId}"
  end
end



