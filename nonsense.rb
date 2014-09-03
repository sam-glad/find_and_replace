require 'pry'
require 'nokogiri'
require 'open-uri'
# #
# # puts Nokogiri::HTML(open('https://support.buildium.com/hc/admin/articles/200690178-Assign-or-email-a-task-to-a-vendor/edit?return_to=%2Fhc%2Fen-us%2Farticles%2F200690178-Assign-or-email-a-task-to-a-vendor&translation_locale=en-us'))
#
# # html_files = Dir.new('/Users/samuelgladstone/Dropbox/work/html_files/*.html')
# Dir.glob('/Users/samuelgladstone/Dropbox/work/html_files/*.html') do |html_file|
#   opened_file = File.open(html_file, 'r')
#   puts Nokogiri::HTML(opened_file)
#   # opened_file.each do |line|
#   #   print line
#   # end
# end


# file_names = ['foo.css']
#
# file_names.each do |file_name|
#   puts file_name.class
#   text = File.read(file_name)
#   binding.pry
#   File.open(file_name, 'w') { |file| file.puts text.gsub('foo', 'BAR') }
# end

foo.css('p').each do |element|
  
end
