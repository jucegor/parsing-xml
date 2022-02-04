require 'nokogiri'
require 'csv'

class Path
  attr_accessor :year, :file_name

  def initialize(attributes = {})
    @year = attributes[:year]
    @file_name = attributes[:file_name]
  end
  
  def ask_for_year
    #Ask for the year to find the folder
    puts "Write the year:"
    print ">"
    @year = gets.chomp
    if @year =~ /^20\d\d$/
      return @year
    else
      puts "------------>>>Wrong format of year, try again!<<<------------"
      ask_for_year
    end
  end

  def ask_for_file
  #Ask for the file name to find the file to parse
  puts "Write the file name to parse:"
  print ">"
  @file_name = gets.chomp
    if @file_name =~ /^^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$$/
      return @file_name
    else
      puts "------------>>>Wrong format of CFDI, try again!<<<------------"
      ask_for_file
    end
  end
  
  def ask_for_path
    ask_for_year
    ask_for_file
    return "InvoicesATX/#{@year}/#{@file_name}.xml"
  end
end

class Concepts
  attr_accessor :cfdi, :ClaveProdServ, :NoIdentificacion, :Cantidad, :ClaveUnidad, :Unidad, :Descripcion, :ValorUnitario, :Importe, :Descuento, :Total_con_IVA

  def initialize (attributes = {})
    @cfdi = attributes[:cfdi]
    @ClaveProdServ = attributes[:ClaveProdServ]
    @NoIdentificacion = attributes[:NoIdentificacion]
    @Cantidad = attributes[:Cantidad]
    @ClaveUnidad = attributes[:ClaveUnidad]
    @Unidad = attributes[:Unidad]
    @Descripcion = attributes[:Descripcion]
    @ValorUnitario = attributes[:ValorUnitario]
    @Importe = attributes[:Importe]
    @Descuento = attributes[:Descuento]
    @Total_con_IVA = attributes[:Total_con_IVA]
  end
end

class Repository 
  attr_accessor :concepts
  def initialize (attributes = {})
    @concepts = []
  end
 end

#Class for converting a Nokogiri object into a Ruby Object: hash
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

option = 'y'
repository = Repository.new

while option != 'n'
  path = Path.new
  concept = Concepts.new
  #Getting the path the user inputs, open it and converting it into a hash
  xml_file = path.ask_for_path
  file = File.open(xml_file)
  doc = Nokogiri::XML(file)
  doc_hashed = doc.to_hash
  
  concept.cfdi = path.file_name

  concepts_length = doc_hashed[:kids][2][:kids].length
  iterator = 0
  concepts_length.times do
    concept.ClaveProdServ = doc_hashed[:kids][2][:kids][iterator][:attr][0][:text]
    concept.NoIdentificacion = doc_hashed[:kids][2][:kids][iterator][:attr][1][:text]
    concept.Cantidad = doc_hashed[:kids][2][:kids][iterator][:attr][2][:text]
    concept.ClaveUnidad = doc_hashed[:kids][2][:kids][iterator][:attr][3][:text]
    concept.Unidad = doc_hashed[:kids][2][:kids][iterator][:attr][4][:text]
    concept.Descripcion = doc_hashed[:kids][2][:kids][iterator][:attr][5][:text]
    concept.ValorUnitario = doc_hashed[:kids][2][:kids][iterator][:attr][6][:text]
    concept.Importe = doc_hashed[:kids][2][:kids][iterator][:attr][7][:text]
    concept.Descuento = doc_hashed[:kids][2][:kids][iterator][:attr][8][:text]
    concept.Total_con_IVA = concept.Importe.to_f * 1.16
    repository.concepts << [
        concept.cfdi,
        concept.ClaveProdServ,
        concept.NoIdentificacion,
        concept.Cantidad,
        concept.ClaveUnidad,
        concept.Unidad,
        concept.Descripcion,
        concept.ValorUnitario,
        concept.Importe,
        concept.Descuento,
        concept.Total_con_IVA
      ]
    iterator += 1
  end
  
  puts 'Do you want to add more concepts from another invoice?(y/n)'
  print '>'
  option = gets.chomp
end


#CSV options
csv_options = { col_sep: ',', force_quotes: true }
filepath    = 'concepts.csv'

CSV.open(filepath, 'wb', csv_options) do |csv|
  csv << ['CFDI','ClaveProdServ', 'NoIdentificacion', 'Cantidad','ClaveUnidad','Unidad', 'Descripcion', 'ValorUnitario', 'Importe', 'Descuento', 'TotalConIVA']
  repository.concepts.each do |concept|
    csv << [
        concept[0],
        concept[1],
        concept[2],
        concept[3],
        concept[4],
        concept[5],
        concept[6],
        concept[7],
        concept[8],
        concept[9],
        concept[10]
      ]
  end
end

file.close

