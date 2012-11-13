#!/usr/bin/env ruby
#
# http://ruby.about.com/od/sinatra/ss/sinatra4_7.htm
#
# http://net.tutsplus.com/tutorials/ruby/an-introduction-to-haml-and-sinatra/
#
# http://playingwithtux.wordpress.com/2011/03/30/learnt-new-technologies-sinatra-and-haml/
#
# http://haml.info/docs.html
#
require 'rubygems'
require 'sinatra'
require 'haml'
 
get '/' do
  haml :index
end
 
# This one shows how you can use refer to
# variables in your Haml views.
# This method uses member variables.
get '/hello/:name' do|name|
  @name = name
  haml :hello
end
 
# This method shows you how to inject
# local variables
get '/goodbye/:name' do|name|
  haml :goodbye, :locals => { :name => name }
end
 
__END__
@@ layout
%html
  %head
    %title Haml on Sinatra Example
  %body
    =yield
 
@@ index
#header
  %h1 Haml on Sinatra Example
#content
  %p
    This is an example of using Haml on Sinatra.
    You can use Haml in all your projeccts now, instead
    of Erb. I'm sure you'll find it much easier!
 
@@ hello
%h1= "Hello #{@name}!"
 
@@ goodbye
%h1= "Goodbye #{name}!"
