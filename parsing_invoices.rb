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

class Invoice
  attr_accessor :cfdi, :folio, :fecha, :subtotal, :descuento, :moneda, :tipo_cambio, :total, :rfc_emisor, :razon_emisor, :rfc_receptor, :razon_receptor

  def initialize (attributes = {})
    @cfdi = attributes[:cfdi]
    @folio = attributes[:folio]
    @fecha = attributes[:fecha]
    @subtotal = attributes[:subtotal]
    @descuento = attributes[:descuento]
    @moneda = attributes[:moneda]
    @tipo_cambio = attributes[:tipo_cambio]
    @total = attributes[:total]
    @rfc_emisor = attributes[:rfc_emisor]
    @razon_emisor = attributes[:razon_emisor]
    @rfc_receptor = attributes[:rfc_receptor]
    @razon_receptor = attributes[:razon_receptor]
  end
end

class Repository 
  attr_accessor :invoices
  def initialize (attributes = {})
    @invoices = []
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

while option == 'y'
  path = Path.new
  invoice = Invoice.new
  #Getting the path the user inputs, open it and converting it into a hash
  xml_file = path.ask_for_path
  file = File.open(xml_file)
  doc = Nokogiri::XML(file)
  doc_hashed = doc.to_hash
  
  invoice.cfdi = path.file_name
  invoice.folio = doc_hashed[:attr][2][:text] #Folio 
  invoice.fecha = doc_hashed[:attr][3][:text] #Fecha
  invoice.subtotal = doc_hashed[:attr][9][:text] #Subtotal
  invoice.descuento = doc_hashed[:attr][10][:text] #Descuento
  invoice.moneda = doc_hashed[:attr][11][:text] #Moneda
  invoice.tipo_cambio = doc_hashed[:attr][12][:text] # TipoCambio
  invoice.total = doc_hashed[:attr][13][:text] # Total
  invoice.rfc_emisor = doc_hashed[:kids][0][:attr][0][:text] # Obtener RFC del Emisor
  invoice.razon_emisor = doc_hashed[:kids][0][:attr][1][:text] #Razon social emisor
  invoice.rfc_receptor = doc_hashed[:kids][1][:attr][0][:text] # RFC del Receptor
  invoice.razon_receptor = doc_hashed[:kids][1][:attr][1][:text] #Razon social receptor

  repository.invoices << [invoice.cfdi, invoice.folio, invoice.fecha, invoice.subtotal, invoice.descuento, invoice.moneda, invoice.tipo_cambio, invoice.total, invoice.rfc_emisor, invoice.razon_emisor, invoice.rfc_receptor, invoice.razon_receptor]
  puts 'Do you want to add another invoice?(y/n)'
  print '>'
  option = gets.chomp
end


#CSV options
csv_options = { col_sep: ',', force_quotes: true }
filepath    = 'invoices.csv'

CSV.open(filepath, 'wb', csv_options) do |csv|
  csv << ['CFDI','Folio', 'Fecha', 'Subtotal','Descuento','Moneda', 'TipoCambio', 'Total', 'RFC_Emisor', 'Razon_Emisor', 'RFC_receptor', 'Razon_receptor']
  repository.invoices.each do |invoice|
    csv << [
        invoice[0],
        invoice[1],
        invoice[2],
        invoice[3],
        invoice[4],
        invoice[5],
        invoice[6],
        invoice[7],
        invoice[8],
        invoice[9],
        invoice[10],
        invoice[11]
      ]
  end
end

file.close

