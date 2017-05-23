PDFKit.configure do |config|
  config.wkhtmltopdf = 'C:\wkhtmltopdf\bin\wkhtmltopdf.exe'
  config.default_options = {
      :page_size => 'Letter',
      :print_media_type => true
  }
end