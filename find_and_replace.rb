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
  'dir="ltr"' => ''
  # TODO: smallFont -> font-style:
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
    text = text.gsub(/\<p style\=\"font-style\: italic;\"\>.*\<\/p\>/) do
      "<p><em>#{Nokogiri::HTML($&).css('p').text}</em></p>"
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
    text = text.gsub(/\<ol style\=\"font-style\: italic\;\"\>(\s*|.*)*\<\/ol\>/) do
      "<ol><em>#{Nokogiri::HTML($&).css('ol').text}</em></ol>"
    end
    file.puts text
  end

# Replace MCPopupThumbnail img nonsense with an expandable img
  File.open(html_file, 'w') do |file|
    text = text.gsub(/\<a\sclass\=\"MCPopupThumbnailLink\sMCPopupThumbnailPopup\"\s+href\=\".*?\"\>\s*?\<img\sclass\=\"MCPopupThumbnail\simg\s*?img\sBigImage"(.|\s)*?src\=\"(.|\s)*?\<\/a\>/) do |replace_with|
      title = Nokogiri::HTML(text).css("a[class='MCPopupThumbnailLink MCPopupThumbnailPopup']").first.css('img').first['title']
      src = Nokogiri::HTML(text).css("a[class='MCPopupThumbnailLink MCPopupThumbnailPopup']").first['href']
      replace_with = "<img class=\"imgThumbnail inactive\" title=\"#{title}\" src=\"#{src}\">"
    end
    file.puts text
  end

end
