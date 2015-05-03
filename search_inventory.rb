#!/usr/bin/env ruby

require_relative 'Inventory.rb'

#search by category and keyword

Inventory.new().search_inventory(ARGV[0], ARGV[1])
