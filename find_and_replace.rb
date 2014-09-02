require 'pry'

# ==============================Find and Replace================================

find_and_replaces = {
  /\<a class\=\"MCPopupThumbnailLink\sMCPopupThumbnailPopup\"\shref\=\"http.?\:.*\"\>\<img class\=\"imgThumbnail\sinactive\"\stitle=\"Image\:\shttp.?\:\/\/.*\.[a-zA-z]+\"\ssrc=\"http.?\:\/\/.*\.[a-zA-Z]+\".*\>\<\/a\>/ => "<img class=\"imgThumbnail inactive\" title=\"Image: #{img_name}\" src=\"https://p1.zdassets.com/hc/theme_assets/187345/200021157/rentals_tenants_add_lease.bmp\"/>",
  /<span class=\"[a-zA-z]*\">/ => '',
  '<p>&nbsp;</p>' => '',
  'MCDropDown MCDropDown_Open dropDown' => 'accordionSection closed',
  'MCDropDownBody dropDownBody' => 'accordionContents',
  'MCPopupThumbnail img  img BigImage' => 'imgThumbnail inactive',
  '<strong><span ' => '<strong ',
  '</span></strong>' => '</strong>',
  '<p>&nbsp;</p>' => '',
  / value=\"[0-9]\"/ => '',
  'dir="ltr"' => '',
  # TODO: smallFont -> font-style:
  # TODO: style="italic" -> <em>
}

html_files = Dir.new('/Users/samuelgladstone/Dropbox/work/html_files/*.html')
Dir.glob(html_files) do |html_file|
  text = File.read(html_file) # String: the whole html file
  find_and_replaces.each do |old_version, new_version|
    File.open(html_file, 'w') do |file|
      # binding.pry
      text = text.gsub(old_version, new_version)
      file.puts text
    end
  end
end

# ==============================Adding the CSS==================================
#
# files = ['foo.css'] # TODO: get the right files and stick them here
# files.each do |file|
#   file = File.open(file, 'w+')
#
#   file.puts(".accordionSection h2 {
#     border-bottom: 1px solid;
#     font-size: 16px;
#     cursor: pointer;
#   }
#   .accordionSection.closed .accordionContents {
#     display: none
#   }
#   img.imgThumbnail {
#     width: 800px;
#     cursor: pointer;
#   }
#   img.imgThumbnail.inactive {
#     width: 300px;
#   }
#   img.buildiumtip {
#     border: 0px;
#     position: relative;
#     top: -7px;
#   }
#   .smallFont {
#     font-size: 10px;
#   }
#   .article-body ul.eg {
#     margin: -10px 20px;
#   }"
#   )
#   file.close
# end
#
# # =============================Adding the Script================================
#
# files = ['foo.css'] # TODO: get the right files and stick them here
# files.each do |file|
#   file = File.open(file, 'w+')
#
#   file.puts("$('.accordionSection h2').on('click', function(e) {\n\n" \
# "  $(e.currentTarget).closest('.accordionSection').toggleClass('closed');\n\n" \
# "});\n\n" \
# "$('img.imgThumbnail').on('click', function(e) {\n\n" \
# "  $(e.currentTarget).toggleClass('inactive');\n\n" \
# "});"
# )
# end
