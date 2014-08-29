require 'pry'
#
# files = ['foo.css']
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
#   }
#   foo")
#
#   file.close
# end
#
# file_names = ['foo.css']
#
# file_names.each do |file_name|
#   text = File.read(file_name)
#   File.open(file_name, 'w') { |file| file.puts text.gsub('foo', 'BAR') }
# end

# ==============================Find and Replace================================

find_and_replaces = [
  { 'MCDropDown MCDropDown_Open dropDown' => 'accordionSection closed' },
  { 'MCDropDownBody dropDownBody' => 'accordionContents' },
  { 'MCPopupThumbnail img  img BigImage' => 'imgThumbnail inactive' },
  { '<strong><span ' => '<strong ' },
  { '</span></strong>' => '</strong>' },
  { '<p>&nbsp;</p>' => '' },
  { "<a class=\"MCPopupThumbnailLink MCPopupThumbnailPopup\" href=\"https://p1.zdassets.com/hc/theme_assets/187345/200021157/rentals_tenants_add_lease.bmp\">\n" \
    "<img class=\"MCPopupThumbnail img  img BigImage\" title=\"Image: https://p1.zdassets.com/hc/theme_assets/187345/200021157/rentals_tenants_add_lease_thumb_0_200.jpg\" src=\"https://p1.zdassets.com/hc/theme_assets/187345/200021157/rentals_tenants_add_lease_thumb_0_200.jpg\" alt=\"\" width=\"1328\" data-mc-=\"\" data-mc-height=\"922\" />" \
    "</a>" => "<img class=\"imgThumbnail inactive\" title=\"Image: https://p1.zdassets.com/hc/theme_assets/187345/200021157/rentals_tenants_add_lease_thumb_0_200.jpg\" src=\"https://p1.zdassets.com/hc/theme_assets/187345/200021157/rentals_tenants_add_lease.bmp\"/>" },
  { "value=\"[0-9]\"" => '' },
  { 'dir="ltr"' => ''}
]

html_files = SOMEDIRECTORYBUTWHICH # TODO: get the right folder
Dir.foreach(html_files) do |file_name|
  text = File.read(file_name)
  File.open(file_name, 'w') do |file|
    find_and_replaces.each do |old_version, new_version|
      file.puts text.gsub(old_version, new_version)
    end
  end
end

# ==============================Adding the CSS==================================

files = ['foo.css'] # TODO: get the right files and stick them here
files.each do |file|
  file = File.open(file, 'w+')

  file.puts(".accordionSection h2 {
    border-bottom: 1px solid;
    font-size: 16px;
    cursor: pointer;
  }
  .accordionSection.closed .accordionContents {
    display: none
  }
  img.imgThumbnail {
    width: 800px;
    cursor: pointer;
  }
  img.imgThumbnail.inactive {
    width: 300px;
  }
  img.buildiumtip {
    border: 0px;
    position: relative;
    top: -7px;
  }
  .smallFont {
    font-size: 10px;
  }
  .article-body ul.eg {
    margin: -10px 20px;
  }"
  )
  file.close
end

# =============================Adding the Script================================

files = ['foo.css'] # TODO: get the right files and stick them here
files.each do |file|
  file = File.open(file, 'w+')

  file.puts("$('.accordionSection h2').on('click', function(e) {\n\n" \
"  $(e.currentTarget).closest('.accordionSection').toggleClass('closed');\n\n" \
"});\n\n" \
"$('img.imgThumbnail').on('click', function(e) {\n\n" \
"  $(e.currentTarget).toggleClass('inactive');\n\n" \
"});"
)
end
