require 'nokogiri'

class Nokogiri::XML::Node
    TYPENAMES = {1=>'element',2=>'attribute',3=>'text',4=>'cdata',8=>'comment'}
    def to_hash
      {kind:TYPENAMES[node_type],name:name}.tap do |h|
        h.merge! nshref:namespace.href, nsprefix:namespace.prefix if namespace
        h.merge! text:text
        h.merge! attr:attribute_nodes.map(&:to_hash) if element?
        h.merge! kids:children.map(&:to_hash) if element?
      end
    end
  end
  class Nokogiri::XML::Document
    def to_hash; root.to_hash; end
  end

XML_FILE = "InvoicesATX/2019/0EB9403D-DE13-449C-8318-FED7D9B96932.xml"
file = File.open(XML_FILE)
doc = Nokogiri::XML(file)
doc_hashed = doc.to_hash
puts "|<||<||<||<||<||<|"
puts "**********************************This is the doc***************************************"
p doc
puts "|<||<||<||<||<||<|"
puts "|<||<||<||<||<||<|"
puts "**********************************This is the doc***************************************"
p doc_hashed
puts "|<||<||<||<||<||<|"

p doc_hashed[:attr][2][:text]