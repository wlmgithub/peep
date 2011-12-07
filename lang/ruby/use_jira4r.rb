require 'rubygems'
require 'jira4r'
require 'highline/import'

def get_password(prompt="Enter Password")
   #ask(prompt) {|q| q.echo = false}
   ask(prompt) {|q| q.echo = '*'}
end

if ARGV.size != 1
  puts "usage: script <username> "
  exit
end

username = ARGV[0]
password = get_password()

jira = Jira4R::JiraTool.new(2, "http://jira.local.twitter.com")
jira.login(username, password)

p jira.getProjectByKey('BUILD')


exit


