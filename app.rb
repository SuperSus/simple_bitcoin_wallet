#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler'
require 'optparse'

Bundler.setup

require_relative 'lib/wallet'
require_relative 'lib/cmd'

command = ARGV.shift
params = ARGV

cmd = Cmd.new(command, params)

err = cmd.validate!
if err
  puts err
  cmd.help
  exit
end

cmd.run
