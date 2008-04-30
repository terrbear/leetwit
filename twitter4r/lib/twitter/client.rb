# client.rb contains the classes, methods and extends <tt>Twitter4R</tt> 
# features to define client calls to the Twitter REST API.
# 
# See:
# * <tt>Twitter::Client</tt>

# Used to query or post to the Twitter REST API to simplify code.
class Twitter::Client
  include Twitter::ClassUtilMixin
end

require('twitter4r/lib/twitter/client/base.rb')
require('twitter4r/lib/twitter/client/timeline.rb')
require('twitter4r/lib/twitter/client/status.rb')
require('twitter4r/lib/twitter/client/friendship.rb')
require('twitter4r/lib/twitter/client/messaging.rb')
require('twitter4r/lib/twitter/client/user.rb')
require('twitter4r/lib/twitter/client/auth.rb')
require('twitter4r/lib/twitter/client/favorites.rb')

