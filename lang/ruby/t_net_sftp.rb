require 'rubygems'
require 'net/sftp'

Net::SFTP.start('nest1.corp.twitter.com', 'liming', :password => 'password') do |sftp|
  # upload a file or directory to the remote host
  sftp.upload!("/Users/liming/jk/s", "/home/liming/s")
#
#  # download a file or directory from the remote host
#  sftp.download!("/path/to/remote", "/path/to/local")
#
#  # grab data off the remote host directly to a buffer
#  data = sftp.download!("/path/to/remote")
#
#  # open and write to a pseudo-IO for a remote file
#  sftp.file.open("/path/to/remote", "w") do |f|
#    f.puts "Hello, world!\n"
#  end
#
#  # open and read from a pseudo-IO for a remote file
#  sftp.file.open("/path/to/remote", "r") do |f|
#    puts f.gets
#  end
#
#  # create a directory
#  sftp.mkdir! "/path/to/directory"
#
#  # list the entries in a directory
  sftp.dir.foreach("/home/liming") do |entry|
    puts entry.longname unless entry.name =~ /^\./
  end
end
