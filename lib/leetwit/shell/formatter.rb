module Leetwit
	module Shell
		module Formatter
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
	end
end
