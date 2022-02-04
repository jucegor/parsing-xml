# filepath    = 'concepts.csv'
# CSV.open(filepath, 'wb', csv_options) do |csv|
#   csv << ['Folio', 'Fecha', 'Subtotal','Descuento','Moneda', 'TipoCambio', 'Total', 'RFC_Emisor', 'Razon_Emisor', 'RFC_receptor', 'Razon_receptor','Cantidad']
#   conceptos_iterator = doc_hashed[:kids][2][:kids].length
#   conceptos_iterator.times do |concepto| 
#   csv << [
#       doc_hashed[:attr][2][:text], #Folio 
#       doc_hashed[:attr][3][:text], #Fecha
#       doc_hashed[:attr][9][:text], #Subtotal
#       doc_hashed[:attr][10][:text], #Descuento
#       doc_hashed[:attr][11][:text], #Moneda
#       doc_hashed[:attr][12][:text], # TipoCambio
#       doc_hashed[:attr][13][:text], # Total
#       doc_hashed[:kids][0][:attr][0][:text], # Obtener RFC del Emisor
#       doc_hashed[:kids][0][:attr][1][:text], #Razon social emisor
#       doc_hashed[:kids][1][:attr][0][:text], # RFC del Receptor
#       doc_hashed[:kids][1][:attr][1][:text], #Razon social receptor
#       doc_hashed[:kids][2][:kids][concepto][:attr][2][:text], #Cantidad
#   ] 
#   concepto += 1
#   end
#   # ...
# end

  
csv << [
    path.file_name,
    doc_hashed[:attr][2][:text], #Folio 
    doc_hashed[:attr][3][:text], #Fecha
    doc_hashed[:attr][9][:text], #Subtotal
    doc_hashed[:attr][10][:text], #Descuento
    doc_hashed[:attr][11][:text], #Moneda
    doc_hashed[:attr][12][:text], # TipoCambio
    doc_hashed[:attr][13][:text], # Total
    doc_hashed[:kids][0][:attr][0][:text], # Obtener RFC del Emisor
    doc_hashed[:kids][0][:attr][1][:text], #Razon social emisor
    doc_hashed[:kids][1][:attr][0][:text], # RFC del Receptor
    doc_hashed[:kids][1][:attr][1][:text], #Razon social receptor
] 
# ...
CSV.open(@csv_file, 'wb') do |csv|