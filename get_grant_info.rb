#!/usr/bin/ruby

###############################################################################
# By: Matt Demas
# Started 28 Nov 12
# input the pmid
# output the grant info
###############################################################################

require 'nokogiri'
require 'open-uri'

def get_grant_info(pmid)
  # assemble the url (standard pubmed format)
  if !pmid.nil?
    base_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/"
    url = base_url + "efetch.fcgi?db=pubmed&id=#{pmid}&retmode=xml"
    puts url
    doc = Nokogiri::XML(open(url))
    doc.xpath('///Grant').each do |node|
      puts "grant info is:\n\t#{node.text}"
    end
  else
    puts "Needs a pmid to get PubMed info..."
  end
end

if __FILE__ == $0
  puts ARGV[0]
  get_grant_info(ARGV[0])
end