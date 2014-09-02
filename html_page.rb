require 'pry'
require 'nokogiri'
require 'uri'

class HtmlPage
  attr_accessor :html, :open_html

  def initialize(html)
    @html = html
    @open_html = Nokogiri::HTML(@html)
  end

  def article_num
    @article_num = Nokogiri::HTML(html.css('td .articlecell')).text
  end

  def first_bit
  end

  def more_with_strong_text
  end

  def italic_text
  end

  def list_items
  end
end

binding.pry
