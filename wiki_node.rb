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


class WikiNode
  
  
  def self.from_hash data
    hash = data[0]

    WikiNode.new(
      :neo_id       => extract_id( hash['self'] ),
      :title        => hash['data']['title'],
      :document_url => hash['data']['document_url'],
      :edit_url     => hash['data']['edit_url']
    )
  end

  
  def initialize hash
    @neo_id = hash[:neo_id]
    @title = hash[:title]
    @document_url = hash[:document_url]
    @edit_url = hash[:edit_url]
  end
  
  
  def to_s
    '<li><a href="/%s">%s [%s]</a></li>' % [ @neo_id != '0' ? @neo_id : '', @title, @document_url]
  end
  
  private 
  
  def self.extract_id txt
    txt.split('/').last || -1
  end
end


