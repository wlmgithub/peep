#
# http://max.jungeelite.de/post/3783349356/ruby-retry-exceptions
#
def retry_1

  try = 0
  begin
   3/0
  rescue Exception => e
    sleep 2
    try += 1
    puts "trying #{try}"
    retry
  end

end

def retry_2

  try = 0
  begin
   puts "trying #{try}"
   3/0
  rescue Exception => e
    sleep 2
    try += 1
    retry  if try < 3
  end

end


if __FILE__ == $0
#  retry_1
  retry_2
end
