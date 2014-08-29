require 'nokogiri'
require 'open-uri'

puts Nokogiri::HTML(open('https://support.buildium.com/hc/admin/articles/200690178-Assign-or-email-a-task-to-a-vendor/edit?return_to=%2Fhc%2Fen-us%2Farticles%2F200690178-Assign-or-email-a-task-to-a-vendor&translation_locale=en-us'))
