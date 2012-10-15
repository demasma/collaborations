require 'rexml/document'
include REXML
require 'geocoder'

Geocoder.configure do |config|
  config.lookup = :yahoo
end

puts "Hello, #{ARGV.first}!"

#doc = Document.new(File.new("minor-lab-papers_1995-9Oct2012.xml"))
doc = Document.new(File.new("minor-lab-papers_WoK_EN-updated.xml"))
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
  # make sure that record has authors
  if !record.elements['auth-address'].nil?
    auth_addr = record.elements['auth-address'][0][0].to_s.\
                       gsub("&amp;", "and").split("&#xD;")
    if auth_addr.length == 1
      auth_addr = record.elements['auth-address'][0][0].to_s.\
                         gsub("&amp;", "and").split(";")
    elsif record.elements['auth-address'][0][0].to_s.\
                 gsub("&amp;", "and").split(";").length == 1
      auth_addr = record.elements['auth-address'][0][0].to_s.\
                         gsub("&amp;", "and").split(";")
    end
    auth_addr.each do |addr|
      if !/\w+, [A-Z]{1,3}$/.match(addr)
        addrs << "(#{pub_date}) #{addr}"
        #addr_old = addr
        #sleep(0.5)
        # checks to see if the result of the above parse returned short addresses
        # not just a long string without ";" etc
        #if addr.length >= 250
        #  addr = addr
        #else
        #  addr = Geocoder.search(addr)[0].address unless Geocoder.search(addr).\
        #                  empty?
        #end
        #puts "\t<<<#{addr_old}\n\t>>>#{addr}"
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
