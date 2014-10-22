require 'pry'
require 'nokogiri'
require 'open-uri'
require 'curb'
require 'json'
require 'dotenv'

Dotenv.load

files_changed = 1
MAX_FILES_CHANGED = 1000

html_files = '/Users/samuelgladstone/Dropbox/zendesk_articles/unchanged_articles/*.html'
Dir.glob(html_files) do |html_file|
  # html_file = '/Users/samuelgladstone/Dropbox/work/sample_html_file.html'
  text = File.read(html_file) # String: the whole html file

  File.open(html_file, 'w') do |file|
    accordion_regex = /\<div\sclass\=\"accordionSection\sclosed\"\>\s{1,4}\<h2\>.*?\<\/h2\>\s{1,4}\<div\sclass\=\"accordionContents\"\>/m
    if accordion_regex.match(text) && !accordion_regex.match(text).to_s.include?('<span class="showhide">')
      text.gsub!(/<div\sclass\=\"accordionSection\sclosed\"\>.*?\<div\sclass\=\"accordionContents\"\>/m) do
        regex_match = $&
        regex_match_without_divs = regex_match.gsub(/<div\sclass\=\"accordionSection\sclosed\"\>\s{1,4}<h2>/, '').gsub(/<\/h2>\s*\<div\sclass\=\"accordionContents\"\>/, '')
        if !(regex_match_without_divs.include?('<span class="showhide">') && regex_match_without_divs.include?('</span>'))
          # Add in <span> and </span> tags
          "<div class=\"accordionSection closed\">\n" \
            "<h2>" \
              "#{regex_match_without_divs}" \
              "<span class=\"showhide\">Show</span>" \
              "<span class=\"showhide hide\">Hide</span>" \
            "</h2>" \
          "<div class=\"accordionContents\">"
        end
      end
    end
    file.puts text
  end
  files_changed += 1
  break if files_changed >= MAX_FILES_CHANGED
end



# SAFETY VALVE
# binding.pry

# =============================Applying the Changes==============================

# ANOTHER SAFETY VALVE
# binding.pry

articles_changed = 1
MAX_ARTICLES_CHANGED = MAX_FILES_CHANGED

# Set changes to each article's body and PUT it via the API
Dir.glob(html_files) do |html_file|
  # Escape all backslashes again so as not to upset JSON
  new_body = File.read(html_file).gsub(/\r/, '\\\\r').gsub(/\n/, '\\\\n').gsub(/\"/, '\\\\"')
  replacement_json = "{\"article\":{\"body\":\"#{new_body}\"}}"
  id = html_file.gsub('/Users/samuelgladstone/Dropbox/zendesk_articles/unchanged_articles/', '').gsub(/.*(?=\()/, '').gsub(/[\(\)]/, '').gsub('.html', '')
  # PUT new auto-formed body via an API call
  c = Curl::Easy.http_put("https://buildium.zendesk.com/api/v2/help_center/articles/#{id}.json", replacement_json) do |curl|
    curl.http_auth_types = :basic
    curl.username = ENV["API_EMAIL"]
    curl.password = ENV["API_PASSWORD"]
    curl.headers['Content-Type'] = 'application/json'
    # curl.verbose = true
  end
  puts html_file.to_s
  puts c.status
  puts
  articles_changed += 1
  break if articles_changed > MAX_ARTICLES_CHANGED
end
