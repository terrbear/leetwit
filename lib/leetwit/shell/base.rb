module Leetwit
	module Shell
		class Base
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
				puts "making client"
		    @twit = Leetwit::Plugins::TwitterClient.new(args[:username] || username, args[:password] || password)
		    regular "We're all hooked up. Type :help if you're confused."
		  end
		    
		  def run
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
	end
end
