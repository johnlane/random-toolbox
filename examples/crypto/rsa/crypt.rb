#!/usr/bin/ruby
#
# Understanding the maths behind RSA
# 
# Test program
#
# This work by John lane 20160316
#
require_relative 'rsa'
m, mm = 0, ''

# Convert input character string into an integer
# by bit-shifting total by 8 bits to the right
# before adding the next byte.
STDIN.read.each_byte { |c| m=(m<<8)+c }

# Perform encryption; pass command-line arguments as integers
m = crypt(m,*ARGV.map{|i| i.to_i})

# Convert integer result into a character string
# takes the least-significant byte as a character
# and adds it to the front of the result string
# then left-shifting the integer result by 8 bits
# to remove the processed character from it.
while m>0 do
  mm.prepend (m & 255).chr
  m = m >> 8
end

# Put resulting character string onto standard output
# Uses 'print' not 'puts' to prevent trailing newline
# which would corrupt ciphertext.
print mm
