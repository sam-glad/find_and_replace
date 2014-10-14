require 'pry'
require 'nokogiri'
require 'open-uri'
require 'curb'
require 'json'
require 'dotenv'

Dotenv.load

#===========================Find-and-Replace Info===============================

find_and_replaces = {
  # /<span class=\"[a-zA-z]*\">/ => '', FIXME: Why did I put this here?
  'MCDropDown MCDropDown_Open dropDown ' => 'accordionSection closed',
  'MCDropDownBody dropDownBody ' => 'accordionContents',
  '<strong><span ' => '<strong ',
  '</span></strong>' => '</strong>',
  /<li\svalue\=\"\d*?\">/ => '<li>',
  'dir="ltr"' => '',
  '<p >' => '<p>',
  '</ol><ol>' => '',
  /<span\sclass\=\"MCDropDownHotSpot[^>]*?>/ => '<span>', # TODO: Check if this is even necessary
  /\<span class\=\"MCDropDownHead\s*dropDownHead\s\"\>/ => '<span>', #TODO: Check if this is even necessary
  'style="font-size: 10pt;"' => 'class="smallFont"' # TODO: verify that this works properly
}

# Find and replace everything in the find_and_replaces hash above
html_files = '/Users/samuelgladstone/Dropbox/zendesk_articles/unchanged_articles/*.html'
Dir.glob(html_files) do |html_file|
  text = File.read(html_file) # String: the whole html file
  find_and_replaces.each do |old_version, new_version|
    File.open(html_file, 'w') do |file|
      text = text.gsub(old_version, new_version)
      file.puts text
    end
  end

  # Replace style="italic" with <em> tags within paragraph text
  File.open(html_file, 'w') do |file|
    text.gsub!(/\<p style\=\"font-style\: italic;\"\>.*\<\/p\>/) do
      "<p><em>#{Nokogiri::HTML($&).css('p').text}</em></p>"
    end
    file.puts text
  end

  # Replace style="italic" with <em> tags within <li> elements
  File.open(html_file, 'w') do |file|
    text.gsub!(/\<li\sstyle="font-style:\sitalic;"\svalue=\"\d*\"\>(.|\s)*?\<\/li\>/) do
      "<li><em>#{Nokogiri::HTML($&).css('li').text}</em></li>"
    end
    file.puts text
  end

  # Replace style="italic" with <em> tags in unordered lists
  File.open(html_file, 'w') do |file|
    text.gsub!(/\<ul\sstyle=\"font-style\:\sitalic\;\"\>((.|\s)*?)\<\/ul\>/) do
      "<ul><em>#{Nokogiri::HTML($&).css('ul')}</em></ul>"
    end
    text.gsub!('<ul><em><ul style="font-style: italic;">', '<ul><em>')
    text.gsub!('</ul></em></ul>', '</em></ul>')
    file.puts text
  end

  # Replace style="italic" with <em> tags in ordered lists
  File.open(html_file, 'w') do |file|
    text.gsub!(/\<ol style\=\"font-style\: italic\;\"\>(\s*|.*)*\<\/ol\>/) do
      "<ol><em>#{Nokogiri::HTML($&).css('ol').text}</em></ol>"
    end
    file.puts text
  end

 # Replace MCPopupThumbnail img nonsense with an expandable img
  File.open(html_file, 'w') do |file|
    text.gsub!(/\<a\sclass\=\"MCPopupThumbnailLink\sMCPopupThumbnailPopup\"\s+href\=\"(.|\s)*?\"\>\s*?\<img\sclass\=\"MCPopupThumbnail\simg\s*?img\sBigImage"(.|\s)*?src\=\"(.|\s)*?\<\/a\>/) do
      title = Nokogiri::HTML($&).css("a[class='MCPopupThumbnailLink MCPopupThumbnailPopup']").first.css('img').first['title']
      src = Nokogiri::HTML($&).css("a[class='MCPopupThumbnailLink MCPopupThumbnailPopup']").first['href']
      "<img class=\"imgThumbnail inactive\" title=\"#{title}\" src=\"#{src}\">"
    end
    file.puts text
  end

  File.open(html_file, 'w') do |file|
    text.gsub!(/\<a\sclass\=\"MCPopupThumbnailLink\sMCPopupThumbnailHover\"\s+href\=\"(.|\s)*?\"\>\s*?\<img\sclass\=\"MCPopupThumbnail\simg\s*\"(.|\s)*?src\=\"(.|\s)*?\<\/a\>/) do
      title = Nokogiri::HTML($&).css("a[class='MCPopupThumbnailLink MCPopupThumbnailHover']").first.css('img').first['title']
      src = Nokogiri::HTML($&).css("a[class='MCPopupThumbnailLink MCPopupThumbnailHover']").first['href']
      "<img class=\"imgThumbnail inactive\" title=\"#{title}\" src=\"#{src}\">"
    end
    file.puts text
  end

  # Remove classes spans (produced by line 16 of this file)
  # TODO: Check if replacing those spans (line 16) is even necessary
  File.open(html_file, 'w') do |file|
    text.gsub!(/\<span\>*\s*\>.*\<\/span\>/) do
      $&[6..-8]
    end
    file.puts text
  end

  # Add <h2> and </h2> tags between accordion divs so that the accordion script
  # actually fires, since it looks for them
  File.open(html_file, 'w') do |file|
    accordion_regex = /<div\sclass\=\"accordionSection\sclosed\"\>.*?\<div\sclass\=\"accordionContents\"\>/m
    if accordion_regex.match(text) && !accordion_regex.match(text).to_s.include?('<h2>')
      text.gsub!(/<div\sclass\=\"accordionSection\sclosed\"\>.*?\<div\sclass\=\"accordionContents\"\>/m) do
        regex_match = $&
        regex_match_without_divs = regex_match.gsub(/<div\sclass\=\"accordionSection\sclosed\"\>\s*/, '').gsub(/\s*\<div\sclass\=\"accordionContents\"\>/, '')
        if !(regex_match_without_divs.include?('<h2>') && regex_match_without_divs.include?('</h2>'))
          # Add in <h2> and </h2> tags
          "<div class=\"accordionSection closed\">\n\t<h2>" \
          "#{regex_match_without_divs}</h2>\n<div class=\"accordionContents\">"
        end
      end
    end
    file.puts text
  end
end

# SAFETY VALVE
# binding.pry

#=============================Applying the Changes==============================

# ANOTHER SAFETY VALVE
# binding.pry

articles_changed = 1
MAX_ARTICLES_CHANGED = 30 # Normally 30, as that's what the API gives us per page
MAX_ARTICLES_PER_MINUTE = 199 # API limit - 1 (due to GET request)

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
  break if articles_changed > MAX_ARTICLES_CHANGED ||
           articles_changed > MAX_ARTICLES_PER_MINUTE
end
