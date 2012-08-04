#
# Add a method to Nokogiri::XML::Element to match an XPath query
# and return a sanitized array of values
#

class Nokogiri::XML::Element

  def xpath_map(xpath='')
    mapped = self.xpath(xpath).map(&:text).map(&:strip).uniq
    mapped unless mapped.empty?
  end
end