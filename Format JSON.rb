#!/usr/bin/ruby
require 'json'
file_contents = ARGF.read
data = JSON.parse(file_contents)
print JSON.pretty_generate(data)