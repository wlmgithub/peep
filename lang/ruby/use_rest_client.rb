#
# json and rest-client are gems
#
#--------------------------------
# $ gem list -d json
#
# *** LOCAL GEMS ***
#
# json (1.6.1, 1.6.0, 1.1.9)
#     Author: Florian Frank
#         Rubyforge: http://rubyforge.org/projects/json
#             Homepage: http://flori.github.com/json
#                 Installed at (1.6.1): /usr/local/rvm/gems/ree-1.8.7-2011.03@twitter
#                                  (1.6.0): /usr/local/rvm/gems/ree-1.8.7-2011.03@twitter
#                                                   (1.1.9): /usr/local/rvm/gems/ree-1.8.7-2011.03@twitter
#
#                                                       JSON Implementation for Ruby
#
#
#-----------------------------------
#
#$ gem list -d rest-client
#
#*** LOCAL GEMS ***
#
#rest-client (1.6.7, 0.9)
#    Authors: Adam Wiggins, Julien Kirch
#        Homepage: http://github.com/archiloque/rest-client
#            Installed at (1.6.7): /usr/local/rvm/gems/ree-1.8.7-2011.03@twitter
#                             (0.9): /usr/local/rvm/gems/ree-1.8.7-2011.03@twitter
#
#                                 Simple HTTP and REST client for Ruby, inspired by microframework
#                                     syntax for specifying actions.
#
#
require 'rubygems'
require 'json'
require 'rest-client'

user = '' # need real name
pass = '' # need real pass

uri_str = %Q(http://#{user}:#{pass}@release.local.twitter.com/pellets.json)

pellets_str = (RestClient.get URI.escape("#{uri_str}")).body
pellets = JSON.parse pellets_str
branch_list = pellets.map {|p| p['pellet']['branch_name']}

#puts branch_list.join(',')
puts branch_list
