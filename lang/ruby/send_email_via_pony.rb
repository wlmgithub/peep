#
# https://github.com/adamwiggins/pony
#
# http://adam.heroku.com/past/2008/11/2/pony_the_express_way_to_send_email_from_ruby/
#
require 'rubygems'
require 'pony'

Pony.mail(:to => 'you@example.com', :from => 'me@example.com', :subject => 'hi', :body => 'Hello there. testing pony')
