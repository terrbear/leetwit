
gem 'twitter4r'
require 'twitter'

module Leetwit
	module Plugins
		class TwitterClient
			include Leetwit::Shell::Options
		
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
						dms = []
		      else
		        tweets = @client.timeline_for(:friends, :since => (@last_time + 1))
						dms = [] #@client.messages(:received, :since => (@last_time + 1))
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
		
				dms.reverse.each do |dm|
					display_dm(dm)
					@last_time = [@last_time, dm.created_at].max
				end
		
				debug("last created_at time: #{@last_time}")
				return true
		  end
		  
		  def send_tweet(text)
		    begin
					raise Errors::InvalidTweet.new if text.strip.split(" ").size <= 1
		      @client.status(:post, text)
					notify("tweet sent")
				rescue Errors::InvalidTweet
					debug("invalid tweet: #{text}")
					error("No one word or blank text tweets. This is for your own good.")
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
		
			def display_dm(dm)
		    text = dm.text.to_s.gsub(/&quot;/, '\'').gsub(/&lt;/, '<').gsub(/&gt;/, '>')
		    puts "\e[32m*** DM from #{dm.sender.screen_name}\e[0m: #{text}"
			end
		end
	end
end
