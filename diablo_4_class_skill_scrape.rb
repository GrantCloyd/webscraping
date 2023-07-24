require 'nokogiri'
require 'open-uri'
require 'pry'

def format_tag(string) 
  return nil unless string.scan('-').empty?
  
  string.split(/(?=[A-Z])/).join(" || ")
end

classes = ['Necromancer', 'Barbarian', 'Sorceress', 'Rogue', 'Druid']

documents = classes.map {|class_name| Nokogiri::HTML5(URI.open("https://diablo4.wiki.fextralife.com/#{class_name}"))}

skills_tables = documents.map {|doc| doc.at_css('table.wiki_table.sortable.searchable') }

formatted_skills = skills_tables.each_with_object({}).with_index do |(skills_table, hsh), idx| 
  # grab each row
  trs = skills_table.css('tr')
  # access the td nodes
  children = trs.map {|tr| tr.children}
  # format to remove additional padding
  nodes = children.map {|c| c.text}.map {|c| c.split(/\n/).map(&:strip)}
  # remove th line and map remaining entries
  skills = nodes[1..].map do |node|
    {
      name: node[1], 
      type: node[2],
      tags: format_tag(node[3]),
      effect: node[4]
    }  
  end
  
  hsh[classes[idx].downcase.to_sym] = skills
end


 
# formatted_skills returns a hash with each class available via symbol access by name
 

