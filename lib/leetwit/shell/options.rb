module Leetwit
	module Shell
		module Options
			include Formatter
			attr_accessor :options
		
			def set_option(option, value)
				self.options[option] = value =~ /true|on/i
			end
		  
			def debug(msg)
				notify msg if self.options['debug']
			end	
		end
	end
end
