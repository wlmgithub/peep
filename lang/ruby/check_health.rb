#!/usr/bin/env ruby -w
#
require 'open-uri'

def check_health
  #my_url  = 'http://release.local.twitter.com/health'
  my_url = 'http://ganglia.smf1.twitter.com/check_key_metrics.php'

  text = open(my_url).read
  if text =~ /CRITICAL/
    puts 'system health critical: '
    puts '=' * 80
    puts text
    puts '=' * 80
  else
    puts 'system health ok'
  end

end

if __FILE__ == $0
  puts "start checking health..."
  check_health
  loop do
    check_health
    print 'Do you want to continue? (y/n) '
    case gets.strip
      when /^y/i : puts 'continue...'; next
      when /^n/i : puts 'quit';  exit 1
    end
  end
end

exit


