#!/usr/bin/ruby

require 'twitter4r/lib/twitter'
require 'time'
require 'net/https'
require 'uri'
require 'json'

module ConsoleOutput
	def header(str)
    puts "\n-----------------------\e[31m#{str}\e[0m-------------------------\n" 
	end

	def notify(str)
 		puts "[\e[33m#{str}\e[0m]"
	end

	def error(str)
 		puts "[\e[31m#{str}\e[0m]"
	end

	def regular(str)
		puts str
	end
end

module Options
	include ConsoleOutput
	attr_accessor :options

	def set_option(option, value)
		self.options[option] = value =~ /true|on/i
	end
  
	def debug(msg)
		notify msg if self.options['debug']
	end	
end

class Twit
	include Options

  def initialize(username, password)
		self.options = {'debug' => false, 'timestamps' => false}
    @username = username
    @password = password
    @last_time = nil
    @client = Twitter::Client.new(:login => @username, :password => @password)
  end

  def display_friend_tweets
		header(Time.now) if self.options['timestamps']
    begin
      if @last_time.nil?
        tweets = @client.timeline_for(:friends)
      else
        tweets = @client.timeline_for(:friends, :since => (@last_time + 1))
      end
    rescue Twitter::RESTError
			debug("rest error: #{$!} - this means no new tweets")
      regular("no updates :(\n") if @options['timestamps']
      return false
    end
		puts unless @options['timestamps']
    tweets.reverse.each do |tweet|
      display_tweet(tweet)
      @last_time = tweet.created_at
    end
		debug("last created_at time: #{@last_time}")
		return true
  end
  
  def send_tweet(text)
    begin
      @client.status(:post, text)
			notify("tweet sent")
    rescue Timeout::Error
			debug("timeout error: #{$!}")
			error("TIMEOUT ERROR")
    rescue Errno::EPIPE
			debug("pipe error: #{$!}")
			error("NETWORK ERROR (try again shortly)")
    rescue Twitter::RESTError
			debug("rest error: #{$!}")
			error("OMG THIS NEVER HAPPENS. Twitter assploded. (try again shortly)")
    end
  end

  def add_friend(friend_name)
    @client.friend(:add, friend_name)
  end
  
  def display_tweet(tweet)
    text = tweet.text.to_s.gsub(/&quot;/, '\'').gsub(/&lt;/, '<').gsub(/&gt;/, '>')
    puts "\e[32m#{tweet.user.screen_name}\e[0m: #{text}"
  end
end

class Console
	include Options

  def initialize(args = {})
		self.options = {'debug' => false}
    regular "Welcome to leetwit!"
    if args[:username].nil?
      print "Enter your username, noob: "
      username = gets.chomp!
      print "And now a password: \e[8m" 
      password = gets.chomp!
      print "\e[0m"
    end
    @twit = Twit.new(args[:username] || username, args[:password] || password)
    regular "We're all hooked up. Type :help if you're confused."
  end
    
  def run
    spawn_update_thread
    loop do
      prompt
      command = gets
      next if command.chomp == ''
      if command =~ /^:/          
				cmd = command.split(" ")
				begin
        	send(cmd.first.sub(/:/, ''), *cmd[1, cmd.length])
				rescue SocketError
					error "Network Failure Detected. Check the plug?"
				rescue
					debug("error: #{$!.inspect}")
					error "whoah there partner. i'm not sure what you're trying to do. try :help."
				end
      else
        @twit.send_tweet(command)
      end
    end
  end
  
  def spawn_update_thread
    Thread.new(@twit) do |twit|
      loop do
        prompt if twit.display_friend_tweets
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
		puts ":set <option> <value> : set option to value"
		puts ":read <option> : show value for option"
    puts ":terrbear   : add terrbear to your friends list"
    puts "if you want to tweet, just type something and press enter."  
  end

	def set(option, value)
		return unless ['timestamps', 'debug'].include? option
		set_option(option, value)
		@twit.set_option(option, value)	
	end

	def set_help
		puts "valid options: debug, timestamps"
		puts "example: :set timestamps off"
	end

	def read(option)
		puts "#{option}: #{self.options[option] ? "on" : "off"}"
	end
  
  def terrbear
    @twit.send_tweet("follow terrbear")
  end
  
  def update
    @twit.display_friend_tweets
  end
    
  def quit
    @thread.kill if @thread
    notify "peace!"
    exit
  end
  
  alias :q :quit
  alias :u :update
  
  def method_missing(not_used)
   error "Sorry, I don't know what you're trying to do. Type :help to see what you can do."
  end
end

console = Console.new
console.run()
