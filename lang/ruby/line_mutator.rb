#
# http://ruby-doc.org/stdlib-1.9.2/libdoc/tempfile/rdoc/Tempfile.html
#
# use tempfile to get the first column of the lines in a file
#
require 'fileutils'
require 'tempfile'

t_file = Tempfile.new('filename_temp.txt')
begin
  File.open("filename.txt", 'r') do |f|
    f.each_line{|line| t_file.puts line.split(",")[0].to_s }
  end
  t_file.flush
ensure
  t_file.close
#  file.unlink
end

FileUtils.mv(t_file.path, "filename.txt")

