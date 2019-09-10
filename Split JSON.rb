#!/usr/bin/env ruby
require 'json'
file_contents = ARGF.read
data = JSON.parse(file_contents)

outdata = data.keys

time = Time.now.utc.strftime("%m%d%H%M")
path = "#{Dir.home}/Downloads/split-#{time}"

Dir.mkdir("#{path}") unless Dir.exist?(path)

outdata.each do |item|
	if data[item].length > 0
		File.open("#{path}/#{item}.json",'w') do |file|
			file.write(JSON.pretty_generate(data[item]))
		end
	end
end

response = {"path": "#{path}","counts": {"accounts": "#{data['accounts'].length}","admins": "#{data['admins'].length}","courses": "#{data['courses'].length}","enrollments": "#{data['enrollments'].length}","observers": "#{data['observers'].length}","sections": "#{data['sections'].length}","terms": "#{data['terms'].length}","users": "#{data['users'].length}"}}
print JSON.pretty_generate(response)