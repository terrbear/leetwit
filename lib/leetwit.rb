#!/usr/bin/env ruby

require 'rubygems'
require 'time'
require 'net/https'
require 'uri'
require 'json'

require 'leetwit/errors/invalid_tweet_error'
require 'leetwit/shell/formatter'
require 'leetwit/shell/options'
require 'leetwit/shell/base'
require 'leetwit/plugins/twitter_client'

console = Leetwit::Shell::Base.new
console.run()
