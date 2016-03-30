#!/usr/bin/ruby
#
# Understanding the maths behind RSA
# 
# Test program
#
# This work by John lane 20160316

#require_relative '../rsa'   # unannotated, for publication
require_relative 'rsa'       # annotated, for reference

# Assert method is only defined in the annotated rsa.rb
unless respond_to? :assert
    def assert(*)
    end 
end

# Return a random number
# It ensures that the RNG returns a number (it retries if RNG returns nil).
# (it will get stuck if the RNG only returns nil)
# It defaults to the Kernel object's RNG, but optionally define constant RG
# to any object that responds to #rand and accepts an integer or range
# (see Kernel#rand for expected behaviour). 
# Suggestions:
RG = Random
# RG = Random.new
def random(*args)
  r = (defined?(RG) ? RG : Kernel).rand(*args) while r.nil?
  r
end

# Return a prime number less than n bits
# Uses external implementation except for small numbers
# (the OpenSSL BigNum library requires a minimum 16 bits)
# The external library is still slow for large (e.g. 4096
# bit numbers) but it's much faster than the internal
# implementation. This is only used to generate primes for
# testing.
require 'openssl'
require 'primes/utils'
def prime(n)
  n>15 ? OpenSSL::BN::generate_prime(n).to_i : begin
    p = 0
    loop do
      p = random(n)
        break if p.prime?
      end 
      p
  end
end

class Integer
  # Check if number is prime 
  # use external BigNum library for large numbers because the
  # internal implementation becomes too slow for large numbers.
  def prime?
    self>2<<10 ? OpenSSL::BN.new(self).prime? : super
  end 
end 

# Return true if a and b are coprime (relatively prime), false otherwise
# two numbers are coprime if their greatest common divisor is 1
def coprime(a,b)
  a.gcd(b) == 1
end

# RSA tester
# Exercises #key and #crypt
def rsa(m, e, *args)
  puts "m:#{m}\te:#{e}\targs:#{args.join(',')}" if LOG
  d, n, *crt = key(e,*args)
  assert (mm = crypt(c = crypt(m,e,n),d,n)) == m
  if crt.length==5# && crt[0]>2 && crt[1]>2
    mm = decrypt(c = crypt(m,e,n),*crt)
    assert (mm = decrypt(c = crypt(m,e,n),*crt)) == m
  end
  puts "n:#{n}\td:#{d}\tc:#{c}\tmm:#{mm}\tphi:#{phi(*args)}\t" if LOG
  [m,c,n,e,d,*crt]
end

# Key length in bits, which is the size of the modulus n
# Above 16 bits the delay incurred by computing phi is apparent
# By 22 bits the delay is very obvious. This is what makes cracking
# RSA a "hard" problem. You don't want to do it for 2048 bits!
BITS = 20
LOG=true

# Accept command-line arguments and test. Arguments are integers:
# message
# public exponent
# modulus
#
# The modulus can be given as one or two numbers, both of which need to be prime
# These aren't checked, so get them right!
if ARGV.length > 0

  m, c, *params = rsa(*ARGV.map{|i| i.to_i})
  puts "asn1=SEQUENCE:rsa_key\n\n[rsa_key]"
  %w(modulus pubExp privExp p q e1 e2 coeff).each do |i|
    break if params.empty?
    puts "#{i}=INTEGER:#{params.shift}"
  end

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
    case random(1..2)
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
      g = n.gcd(m)
      puts "m:#{m}\tg:#{g}\tn:#{n}" if LOG
    end
    args.unshift(m)

    rsa(*args)

  end

end
