#!/usr/bin/env ruby

require_relative 'Inventory.rb'

#load inventory

Inventory.new().load_new_inventory(ARGV[0])

