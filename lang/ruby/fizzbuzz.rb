#
# #
# FizzBuzz: Write a program that prints the numbers from 1 to 100.
# But for multiples of three print “Fizz” instead of the number and for the multiples of five print “Buzz”.
# For numbers which are multiples of both three and five print “FizzBuzz”.
# #
#
mult_5 = false
mult_3 = false

for x in 1..100 do
    if x % 5 == 0
      mult_5 = true
    end
    if x % 3 == 0
      mult_3 = true
    end

    if mult_3 && mult_5
        puts x.to_s + ' fizzbuzz'
    elsif mult_3
        puts x.to_s +  ' fizz'
    elsif mult_5
        puts x.to_s + ' buzz'
    else
        puts x
    end

    mult_5 = false
    mult_3 = false
end
