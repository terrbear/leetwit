#!/usr/bin/ruby

require 'rubygems'
gem 'twitter4r'
require 'twitter'
require 'time'

class Twit
  def initialize(username, password)
    @username = username
    @password = password
    @last_time = nil
    @client = Twitter::Client.new(:login => @username, :password => @password)
  end
  
  def display_friend_tweets
    puts "\n-----------------------\e[31m#{Time.now}\e[0m-------------------------\n"
    begin
      if @last_time.nil?
        tweets = @client.timeline_for(:friends)
      else
        tweets = @client.timeline_for(:friends, :since => @last_time)
      end
    rescue Twitter::RESTError
      puts "no updates :(\n"
      return
    end
    tweets.reverse.each do |tweet|
      display_tweet(tweet)
      @last_time = tweet.created_at
    end
  end
  
  def send_tweet(text)
    @client.status(:post, text)
    puts "[\e[31mtweet sent\e[0m]"
  end
  
  def add_friend(friend_name)
    @client.friend(:add, friend_name)
  end
  
  def display_tweet(tweet)
    puts "\e[32m#{tweet.user.screen_name}\e[0m: #{tweet.text}"
  end
end

class Console

  def initialize(args = {})
    puts "Welcome to leetwit!"
    if args[:username].nil?
      print "Enter your username, noob: "
      username = gets.chomp!
      print "And now a password: \e[8m" 
      password = gets.chomp!
      print "\e[0m"
    end
    @twit = Twit.new(args[:username] || username, args[:password] || password)
    puts "We're all hooked up. Type :help if you're confused."
  end
    
  def run
    spawn_update_thread
    loop do
      prompt
      command = gets
      next if command.chomp == ''
      if command =~ /^:/          
        send(command.split(" ").first.sub(/:/, ''))
      else
        @twit.send_tweet(command)
      end
    end
  end
  
  def spawn_update_thread
    Thread.new(@twit) do |twit|
      loop do
        twit.display_friend_tweets
        prompt
        sleep 180
      end
    end
  end
  
  def prompt
    print "leetwit$ "
    $stdout.flush
  end
  
  def help
    puts "How to use leetwit (all commands should start with a ':'):"
    puts ":help       : show this message"
    puts ":update, :u : update the timeline to see the latest tweets"
    puts ":quit, :q   : quit"
    puts "if you want to tweet, just type something and press enter."  
  end
  
  def update
    @twit.display_friend_tweets
  end
    
  def quit
    @thread.kill if @thread
    puts "peace!"
    exit
  end
  
  alias :q :quit
  alias :u :update
  
  def method_missing(not_used)
   puts "Sorry, I don't know what you're trying to do. Type :help to see what you can do."
  end
end

console = Console.new
console.run()
