#!/usr/bin/env ruby

# <bitbar.title>External IP country flag emoji</bitbar.title>
# <bitbar.version>v1.5 beta 1</bitbar.version>
# <bitbar.author>Bruce Steedman</bitbar.author>
# <bitbar.author.github>MatzFan</bitbar.author.github>
# <bitbar.desc>Displays country flag emoji - e.g. for VPN use</bitbar.desc>
# <bitbar.image>http://s24.postimg.org/wu8glnryt/flag.png</bitbar.image>
# <bitbar.dependencies>OS X 10.11</bitbar.dependencies>

require 'open-uri'
require 'json'

ip_hash = JSON.parse open('http://ipinfo.io').read
code = ip_hash['country']
c1, c2 = *code.split('').map { |c| (c.ord + 0x65).chr.force_encoding 'UTF-8' }
puts "\xF0\x9F\x87#{c1}\xF0\x9F\x87#{c2}"
puts '---'
ip_hash.map { |k,v| puts "#{k}: #{v}" }
