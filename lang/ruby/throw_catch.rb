#
require 'pp'

def promptAndGet(prompt)
  print prompt
  res = readline.chomp
  throw :quitRequested if res == "!"
  return res
end


catch :quitRequested do
  name = promptAndGet("Name: ")
  age  = promptAndGet("Age:  ")
  sex  = promptAndGet("Sex:  ")
  # ..
  #   # process information
  #   end
  #
  pp 'name: ' + name
  pp 'age: ' + age
  pp 'sex: ' + sex
end


