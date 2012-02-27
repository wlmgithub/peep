#!/opt/local-lite/bin/ruby -w

require 'rubygems'
require 'mysql'

require 'date'

#### constants
BASE_DIR = '/home/falcon/hostmon/logs-twitterweb'

def get_db_connection
  begin
  # connect to the MySQL server
  # goto releasenest1:~falcon/liming for real
    db_host = ''
    db_user = ''
    db_pass = ''
    db_name = ''

    dbh = Mysql::new(db_host, db_user, db_pass, db_name)
    # get server version string and display it
    puts "Server version: " + dbh.get_server_info
  rescue Mysql::Error => e
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  ensure
  #  disconnect from server
  #  dbh.close if dbh
  end

  dbh
end

def get_timestamp_for_sql(ts)
  # ts in the form of, e.g.,  20120217-201038
  # timestamp suitable for sql is: 2012-02-17 20:10:38
  DateTime.strptime("#{ts}", '%Y%m%d-%H%M%S').strftime('%Y-%m-%d %H:%M:%S')
end

def insert_into(dbh, table=nil, columns=nil, values=nil)
  #stmt = %Q(INSERT INTO checklists(checklist) values('testing, test, foobar'))
  #dbh.query(stmt)
  #puts "Number of rows inserted: #{dbh.affected_rows}"

  stmt = %Q(INSERT INTO #{table}(#{columns}) values(#{values}))
  dbh.query(stmt)
#  puts "Number of rows inserted: #{dbh.affected_rows}"
  puts "Values inserted into #{table}: #{values}"
  dbh.insert_id  # return the last insert id
end

def select_from(dbh, table=nil, column=nil, where=nil)
  stmt = %Q(SELECT #{column} FROM #{table} WHERE #{where})
  res = dbh.query(stmt)

  p column, where
  res.fetch_row()[0]
=begin
  res.each do |column|
    p column
    return  column[0]
  end
=end

#  res.each do |array|
#    array.each do |value|
#      puts value
#    end
#  end
end

##############################
#if row_exists?(dbh, table='test_table', column='col1',  where_value="'foobarbaz'")
#  puts 'col1 = foobarbaz exists'
#else
#  puts 'col1 = foobarbaz NOT exists'
#end
##############################
def row_exists?(dbh, table=nil, column=nil, where_value=nil)
  stmt = %Q(SELECT #{column} FROM #{table} WHERE #{column} = #{where_value})
  res = dbh.query(stmt)
  ary = []
  res.each do |array|
    array.each do |value|
      ary << value
    end
  end
  ary.empty? ?  false : true
end

def multi_col_row_exists?(dbh, table=nil, columns=nil, where=nil)
  stmt = %Q(SELECT #{columns} FROM #{table} WHERE #{where})
  res = dbh.query(stmt)
  ary = []
  res.each do |array|
    array.each do |value|
      ary << value
    end
  end
  ary.empty? ?  false : true
end


def get_all_bin_files(dir_to_parse)
  Dir["#{dir_to_parse}/bin-*"]
end

def process_bin_file(dbh, bin_file, given_dir_name=given_dir_name)
  #
  # each given_dir_name  represents a run
  # 
  # * ts is time_checked for the run
  #
  ts = get_timestamp_for_sql(given_dir_name)

  File.open(bin_file).each_line do |line|
    line.chomp!
    next if line =~ /^$/
    puts "LINE: ~~#{line}~~"
    ##############################
    # line is like this:
    # smf1-aah-19-sr2.prod.twitter.com |SCP OK|SSH OK|WEBSH OK|CONFIG_DIR OK|TWITTER_DIR OK|CURRENT_LINK OK|HTTPD_LOG OK|LIVE_MATCH OK  |UPTIME OK  |UNICORN-8000 OK  |RAINBOWS OK  |TWITCHER OK  |MEMCACHED-22422 OK  |APACHE OK  |8080 OK  |8000 OK  |9000 OK  |UNICORN_PS_MATCH OK   |RAINBOWS_PS_MATCH OK 
    ##############################
    if line.include?('|')
      line_ary = line.gsub(/\s+\|/, '|').split('|') 
      ##############################
      # line_array is like this:
      # ["smf1-aah-19-sr2.prod.twitter.com", "SCP OK", "SSH OK", "WEBSH OK", "CONFIG_DIR OK", "TWITTER_DIR OK", "CURRENT_LINK OK", "HTTPD_LOG OK", "LIVE_MATCH OK", "UPTIME OK", "UNICORN-8000 OK", "RAINBOWS OK", "TWITCHER OK", "MEMCACHED-22422 OK", "APACHE OK", "8080 OK", "8000 OK", "9000 OK", "UNICORN_PS_MATCH OK", "RAINBOWS_PS_MATCH OK"]
      ##############################
      host = line_ary.shift
      printf("%s, %s\n",  host, ts)
      check_list = ''
      check_list_bits = ''
      line_ary.each do |check_str|
        check, result = check_str.split
        printf("\t%s:%s\n",  check, result)
        check_list << check+','
        result == 'OK' ? check_list_bits << '0'  :  check_list_bits << '1'
      end 
      check_list.chop!
      printf("\t%s\n", check_list)
      check_result = check_list_bits.to_i(2)
      printf("\t%s %d\n", check_list_bits, check_result)
      if check_list_bits.include?('1')
        puts "#{host} BAD"
      else
        puts "#{host} GOOD"
      end

      ##############################
      # now that we got stuff, let's stuck them in db
      ##############################

      # handle table hosts
      unless row_exists?(dbh, table='hosts', column='hostname',  where_value="'#{host}'") 
        # last_id is last_insert_id
        last_id_for_hosts = insert_into(dbh, table='hosts', columns='hostname',  values="'#{host}'")
      else 
        # last_id is existing id
        last_id_for_hosts = select_from(dbh, table='hosts', column='id',  values="hostname = '#{host}'")
      end

      # handle table checklists
      unless row_exists?(dbh, table='checklists', column='checklist',  where_value="'#{check_list}'") 
        # last_id is last_insert_id
        last_id_for_checklists = insert_into(dbh, table='checklists', columns='checklist',  values="'#{check_list}'")
      else 
        # last_id is existing id
        last_id_for_checklists = select_from(dbh, table='checklists', column='id',  values="checklist = '#{check_list}'")
      end

      # for self view pleasure
      puts "last_id_for_hosts: #{last_id_for_hosts}"
      puts last_id_for_hosts.class
      puts "last_id_for_checklists: #{last_id_for_checklists}"
      puts last_id_for_checklists.class

      # handle table checklist_results
      unless multi_col_row_exists?(dbh, table='check_results', column='host_id, checklist_id, time_checked',  where_value="host_id = '#{last_id_for_hosts}' and  checklist_id = '#{last_id_for_checklists}' and time_checked = '#{ts}'") 
        last_insert_id_for_check_results = insert_into(dbh, table='check_results', columns='host_id, checklist_id, phase, time_checked, result',  values="'#{last_id_for_hosts}', '#{last_id_for_checklists}', '1', '#{ts}', '#{check_result}'")
      else
        puts "INFO: data alreay in for #{ts}"
      end

    end  # if 
  end  # File.open
end



##############################
=begin   testing db part
#
# now that db is connected
#

dbh = get_db_connection

ts = get_timestamp_for_sql('20121212-121212')

insert_into(dbh, table='test_table', columns='col1, col2',  values="'testing, * % 121212  foobar', '#{ts}'")

exit
=end
##############################

if ARGV.size != 1
  abort "usage: #{$0} <dir-to-parse>
         e.g.,  #{$0} 20120216-215544 
  "
end

given_dir_name = ARGV[0]
dir_to_parse = File.join(BASE_DIR, given_dir_name)
puts "parsing dir: " + dir_to_parse

unless File.directory?(dir_to_parse)
  abort "#{dir_to_parse} is not a directory, quit."
end

# is dir_to_parse ignoreable?
# i.e., does it contain bins.txt and really_bad_hosts.txt?
#  
#  20120217-230026 ignorable
#  20120217-225916 parsable

unless File.exists?(File.join(dir_to_parse, 'bins.txt')) or 
       File.exists?(File.join(dir_to_parse, 'really_bad_hosts.txt'))
  abort "#{dir_to_parse} does not contain bins.txt and really_bad_hosts. quit."
end

dbh = get_db_connection


# now read the dir and do sth
all_bin_files = get_all_bin_files(dir_to_parse)

all_bin_files.each do  |bin_file|
  puts 'processing file: ' + bin_file
  process_bin_file(dbh, bin_file, given_dir_name)

end
