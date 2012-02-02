#!/usr/bin/env ruby
#
# credit: http://rubysource.com/threading-ruby/
#

require 'pp'
require 'rubygems'
require 'trollop'
require 'loony'
require 'thread'

CHUNK_SIZE = 10

# hash of ver to hosts
# sorry it has to be a global variable
$hosts_of_ver = Hash.new{|h,k| h[k] = []}

def get_options
  opts = Trollop::options do
    version '0.0.1'
    banner <<-EOS
  check_versions check which versions are running on which hosts

  Usage:
    check_versions  [options]

  EOS
    opt :verbose, "Enable verbose output", :short => 'v'
    opt :dc, "data center of the service to check", :short => 'd', :default => 'smfd'
    opt :role, "loony role of the service to check", :short => 'r', :default => 'gizmoduck'
  end
  opts
end
opts = get_options

#
# assuming the service uses Ostrich for runtime stats
#
def check_version_of(host)
  check_version_cmd = %Q(
    curl http://localhost:9900/server_info.txt -s | grep build_revision  | sed -e "s/build_revision: //"
  )
  ver =  %x(ssh #{host} '#{check_version_cmd}')
end

#
# split the hosts into chunks of CHUNK_SIZE and treat each chunk as a queue
#   for faster processing
#
def check_versions(hosts)
  queue = Queue.new
  semaphore = Mutex.new
  hosts.each { |host| queue << host }

  CHUNK_SIZE.times.map {
    Thread.new do
      begin
        while host = queue.pop(true)
          ver = check_version_of(host)
          semaphore.synchronize {
            yield host, ver
          }
        end
      rescue ThreadError => e
        raise unless e.message =~ /queue empty/
      end
    end
  }.each { |thread| thread.join }
end

######## main
#
# gizmoduck, tweetypie, timelineservice
#hosts = Loony::Client.list(:roles => ['tweetypie'])
#hosts = Loony::Client.list(:roles => ['timelineservice'])
##hosts = Loony::Client.list(:roles => ['support'], :managed => true)

hosts = Loony::Client.list(:dc => [opts[:dc]], :roles => [opts[:role]])


=begin
# use these smfd hosts for testing
hosts = %w(
  smfd-amm-20-sr1.devel.twitter.com
  smfd-aml-20-sr1.devel.twitter.com
)
pp hosts
=end



check_versions(hosts) do |host, ver|
  if opts[:verbose]
    puts "#{host} : #{ver}"
  end
  $hosts_of_ver[ver.chomp] << host
end

if opts[:verbose]
  puts '-' * 80
  puts 'Hosts:'
  puts '-' * 80

  pp hosts
  pp hosts.size
  pp $hosts_of_ver

end

unless  $hosts_of_ver.keys.size  == 1
  STDERR.puts "Ooops, not all hosts are running the same version"
  $hosts_of_ver.each {|ver,hosts|
    STDERR.puts "#{ver}:"
    hosts.each {|host|
      STDERR.puts "\t#{host}"
    }
  }

else
  ver = $hosts_of_ver.keys.to_s
  STDERR.puts "Bingo! All hosts running the same version: #{ver}"
end

