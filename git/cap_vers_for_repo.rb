#!/bin/env ruby
# @ mccv
def capvers_for_repo(dir)
  puts "scanning #{dir} for Capfiles"
  Dir.chdir(dir) do
    tree = `git ls-tree --full-tree -r master`
    files_n_shas = tree.split "\n"
    capfiles = files_n_shas.find_all {|f| f =~ /Capfile/}
    capfiles.each do |capfile_entry|
      infos = capfile_entry.split
      contents = `git cat-file -p #{infos[2]}`
      puts "\tcap entries for #{infos[3]}:"
      caplines = contents.grep /gem 'twitter-cap-utils/
      caplines += contents.grep /require 'twitter_cap_utils/
      caplines.each {|l| puts "\t\t#{l}"}
    end
    nil
  end
end

dirs = `ls -d *.git`

dirs.split("\n").each do |dir|
  capvers_for_repo(dir)
end

