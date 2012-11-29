#!/usr/bin/ruby

def get_grant_info(pmid)
  # assemble the url (standard pubmed format)
  base_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/"
  url = base_url + "efetch.fcgi?db=pubmed&id=#{pmid}&retmode=xml"
  doc = Nokogiri::XML(open(url))
  doc.xpath('///Grant').each do |node|
    puts "grant info is:\n\t#{node.text}"
  end
end