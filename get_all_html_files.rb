require 'pry'
require 'nokogiri'
require 'open-uri'
require 'curb'
require 'json'

# Pull all articles and info via API
api_result = open('https://buildium1389260253.zendesk.com/api/v2/help_center/articles.json').read
articles = JSON.parse(api_result)["articles"]

articles.each do |article|
  File.open("/Users/samuelgladstone/Dropbox/zendesk_articles/#{article["title"]} (#{article["id"]}).html", 'w') do |f|
    f.write("#{article["body"]}")
  end
end

puts "Number of articles: #{articles.size}"
