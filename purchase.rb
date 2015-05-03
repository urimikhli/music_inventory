#!/usr/bin/env ruby

require_relative 'Inventory.rb'

# decrement by uid

Inventory.new().purchase(ARGV[0])
