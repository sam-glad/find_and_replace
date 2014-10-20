require 'pry'
require 'nokogiri'
require 'open-uri'
require 'json'

# Pull 30 articles and info via API
PAGE_NUMBER = 20
api_result = open("https://buildium.zendesk.com/api/v2/help_center/articles.json?page=#{PAGE_NUMBER}").read
articles = JSON.parse(api_result)["articles"]

articles.each do |article|
  id = article["id"]
  # Remove slash character so as not to mess up file path
  title = article["title"].gsub('/', '')
  File.open("/Users/samuelgladstone/Dropbox/zendesk_articles/unchanged_articles/#{title} (#{id}).html", 'w') do |f|
    f.write("#{article["body"]}")
  end
end

puts "Number of articles: #{articles.size}"
