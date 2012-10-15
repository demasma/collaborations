#!/usr/bin/ruby -w minor-lab-papers_WoK_EN-updated.xml
#
# Matthew Demas
#
# inspects XML document exported from ENDNOTE and extracts author addresses
#

require 'rexml/document'
include REXML
require 'geocoder'

# Set the geocoder service to Yahoo!.  I overused my limits for Google 
# the other day.
Geocoder.configure do |config|
  config.lookup = :yahoo
end

# Set the file name and set the prepare the file for XML parsing
filename = ARGV.first || "minor-lab-papers_WoK_EN-updated.xml" 
doc = Document.new(File.new(filename))
root = doc.root

addresses = {}
addrs = []

i = 0

root.each_element('//record') do |record|
  i += 1
  # define values of interest
  isi_num = record.elements['accession-num'][0][0]
  first_auth = record.elements['contributors'][0][0][0][0].to_s
  pub_date = record.elements['dates'].elements['year'][0][0]
  pub_type = record.elements['ref-type'].attributes['name']
  info_str = "#{pub_type}>>>#{pub_date}--#{first_auth} #{isi_num}"
  
  title = record.elements['titles'].elements['title'][0][0]
  #puts "#{i}>>#{pub_date} -- #{title}"

addr_split(record.elements['auth-address'])

def addr_split(addr_rec)
  # FIXME
  # addresses are not always delimited by ";" or "&#xd;".
  # there is at least 1 case where there are just spaces between address entries
  #
=begin
  take in a string? xml element?
  try different delimiters and check the length of the returned list
  break it down by delimiter? search for delimiter?
  and output a list of addresses
=end
  # make sure that record has authors and...
  if !addr_rec.nil?
    auth_addr_raw = addr_rec[0][0].to_s.gsub("&amp;", "and")
    auth_addr = addr_rec[0][0].to_s.gsub("&amp;", "and").split("&#xD;")
    # try to break up the author address string into parts based on delimiter
    if auth_addr.length == 1
      auth_addr = auth_addr_raw.split(";")
    elsif addr_rec[0][0].to_s.gsub("&amp;", "and").split(";").length == 1
      auth_addr = addr_rec[0][0].to_s.gsub("&amp;", "and").split(";")
    end
  end
end
      
      
    auth_addr.each do |addr|
      # Accounts for entries of the corresponding author, which is included
      # in the address section
      if !/\w+, [A-Z]{1,3}$/.match(addr)
        addrs << "(#{pub_date}) #{addr}"
        addr_old = addr
        sleep(0.5) # wait so as not to overload the geocoding service
        # checks to see if the result of the above parse returned short addresses
        # not just a long string without ";" etc
        if addr.length >= 250
          addr = addr
        else
          addr = Geocoder.search(addr)[0].address unless Geocoder.search(addr).\
                          empty?
        end
        puts "\t<<<#{addr_old}\n\t>>>#{addr}"
        if addresses.has_key? addr
          addresses[addr] << info_str unless addresses[addr] == info_str 
        else
          addresses[addr] = [info_str]
        end
      end
    end
  end
end

#addresses.each do |key, value|
#  puts "#{key} >>> {#{value.join("; ")}}"
#  #puts "\t\t---#{key}---"
#  #puts "#{Geocoder.search(key)[0].address} {#{value.join("; ")}}" unless \
#  #puts "#{Geocoder.search(key)[0].address}" unless \
#  #     Geocoder.search(key).empty?
#  #sleep(1)
#end

#addrs.uniq.sort.each do |addr|
#  puts addr.split(",")
#end
if __FILE__ == $0
  ...
end