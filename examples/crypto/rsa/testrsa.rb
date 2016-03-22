#!/usr/bin/ruby
#
# Understanding the maths behind RSA
# 
# Test program
#
# This work by John lane 20160316

require_relative 'rsa'

# RSA tester
# Exercises #key and #cipher
def rsa(m, e, *args)
  puts "m:#{m}\te:#{e}\targs:#{args.join(',')}" if LOG
  d, n = key(e,*args)
  assert (mm = cipher(c = cipher(m,e,n),d,n)) == m
  puts "n:#{n}\td:#{d}\tc:#{c}\tmm:#{mm}\tphi:#{phi(*args)}\t" if LOG
end

# Key length in bits, which is the size of the modulus n
# Above 16 bits the delay incurred by computing phi is apparent
# By 22 bits the delay is very obvious. This is what makes cracking
# RSA a "hard" problem. You don't want to do it for 2048 bits!
BITS = 2048
LOG=true

# Accept command-line arguments and test. Arguments are integers:
# message
# public exponent
# modulus
#
# The modulus can be given as one or two numbers, both of which need to be prime
# These aren't checked, so get them right!
if ARGV.length > 0

  rsa(*ARGV.map{|i| i.to_i})

else

  1000000.times do
  n=m=g=nil

  # Default private exponent (usually, but not necessarily, prime)
  # It's usual, although not necessary, to choose 65537 which is
  # a Fermat prime (see https://en.wikipedia.org/wiki/Fermat_prime).
  # It is conjectured that there are only five Fermat Primes
  # and they are 3, 5, 17, 257, and 65537.
  e=[3,5,17,257,65537].sample

  # randomly execute with a random n or random primes [p,q]
  case random(2..2)
  when 1
    # choose any value for n but cannot go below 3 because
    # phi(2) is 1 (see assertion in code)
    n = random(3..1<<BITS-1)
    args = [n]
  when 2
    # Choose two similar-sized but different prime numbers of
    # half the desired key length. They must be different so we
    # can efficiently compute Phi (using phi = (p-1)(q-1) which
    # is valid only for coprime p and q)
    p = q = prime(BITS/2)
    until p != q && coprime(p,q) do
      q = prime(BITS/2)
    end
    n = p*q # just for below, not passed to algorithm
    args = [p,q]
  end

  phi_n = phi(*args) # just for below, not passed to algorithm

  # choose another public exponent if the requested one is
  # unsuitable: it must be coprime with phi(n). It could be
  # bigger then phi(n) but there is no point because e is
  # congruent mod phi(n) anyway.
  #until !e.nil? && coprime(e,phi(*args))
  until coprime(e,phi_n)
    e = random(1..phi_n-1)
  end
  args.unshift(e)

  # choose m - gcd(n,m) must be coprime with n/gcd(n,m)
  puts "run with m:#{m}\tn:#{n}" if LOG
  until !m.nil? && coprime(g,n/g) #coprime(n,m)
    m = random(1..n-1)
    g = gcd(n,m)
    puts "m:#{m}\tg:#{g}\tn:#{n}" if LOG
  end
  args.unshift(m)

  rsa(*args)

end

end
