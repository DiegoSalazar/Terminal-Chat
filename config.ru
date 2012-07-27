#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require 'rack'
require './chat'

Rack::Handler::WEBrick.run Chat.new, :Port => 9000