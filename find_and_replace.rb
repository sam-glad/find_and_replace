require 'pry'
require 'nokogiri'

# ==============================Find and Replace================================

find_and_replaces = {
  # /<span class=\"[a-zA-z]*\">/ => '', FIXME: Why did I put this here?
  '<p>&nbsp;</p>' => '',
  'MCDropDown MCDropDown_Open dropDown ' => 'accordionSection closed',
  'MCDropDownBody dropDownBody ' => 'accordionContents',
  '<strong><span ' => '<strong ',
  '</span></strong>' => '</strong>',
  '<p>&nbsp;</p>' => '',
  /<li\svalue\=\"\d*?\">/ => '<li>',
  'dir="ltr"' => '',
  /<span\sclass\=\"MCDropDownHotSpot[^>]*?>/ => '<span>', # TODO: Check if this is even necessary
  /\<span class\=\"MCDropDownHead\s*dropDownHead\s\"\>/ => '<span>', #TODO: Check if this is even necessary
  'style="font-size: 10pt;"' => 'class="smallFont"', # TODO: verify that this works properly
  '<p class="MCWebHelpFramesetLink MCWebHelpFramesetLinkTop">&nbsp;</p>' => ''
}

# Find and replace everything in the find_and_replaces hash above
html_files = '/Users/samuelgladstone/Dropbox/work/html_files/*.html'
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
      title = Nokogiri::HTML(text).css("a[class='MCPopupThumbnailLink MCPopupThumbnailPopup']").first.css('img').first['title']
      src = Nokogiri::HTML(text).css("a[class='MCPopupThumbnailLink MCPopupThumbnailPopup']").first['href']
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
        gsub_result = $&
        gsub_result_without_divs = gsub_result.gsub(/<div\sclass\=\"accordionSection\sclosed\"\>\s*/, '').gsub(/\s*\<div\sclass\=\"accordionContents\"\>/, '')
        if !(gsub_result_without_divs.include?('<h2>') && gsub_result_without_divs.include?('</h2>'))
          # Add in <h2> and </h2> tags
          "<div class=\"accordionSection closed\">\n\t<h2>" \
          "#{gsub_result_without_divs}</h2>\n<div class=\"accordionContents\">"
        end
      end
      file.puts text
    else
      file.puts text
    end
  end

  # File.open(html_file, 'w') do |file|
  #   Nokogiri::HTML(text).css('span[class="MCDropDownHotSpot dropDownHotspot  MCDropDownHotSpot_"]').each do |useless_span|
  #     useless_span.gsub!(/<span\sclass\=\"MCDropDownHotSpot[^>]*?>/, '').slice!(-7..-1)
  #   end
  #   file.puts text
  # end

end
