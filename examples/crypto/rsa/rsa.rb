#!/usr/bin/ruby
#
# Understanding the maths behind RSA
#
# This work by John lane 20160316

# Simple assertion takes a list of booleans
# It raises an exception if any are false or if the list is empty
def assert(*args)
  assert false unless args.length > 0
  args.each { |a| raise RuntimeError, "Assertion Failed", caller unless a }
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

# Return greatest common divisor of a and b using Euclid's Algorithm.
# Typically the arguments are given such that a>b but it also works
# when a<b - an extra iteration will occur which swaps them around.
def gcd(a,b)
  (r = a % b) == 0 ? b : gcd(b,r)
end

# Return coefficients s and t for the relationship gcd(a,b) = sa+tb
# using the Extended Euclidean Algorithm (sa+tb is called Bézout's identity)
def eea(a,b)
  return b==0 ? [1,b] : begin
    q, r = a.divmod b
    s, t = eea(b,r)
    [t, s - q * t]
  end 
end

# Return true if a and b are coprime (relatively prime), false otherwise
# two numbers are coprime if their greatest common divisor is 1
def coprime(a,b)
  gcd(a,b) == 1
end

# Euler's Totient Function - phi(n) 
# the number of nonzero integers less than n that are relatively prime to n
# if given one argument then the iterative calculation is performed
# if given two arguments then assumes they're prime and coprime and calculates directly
def phi(*args)
  print args.length; $stdout.flush
  case args.length
  when 2
    # phi = (p-1)(q-1) is valid only for coprime p and q
    assert coprime(*args)
    (args[0]-1)*(args[1]-1)
  when 1
    n = args[0]
puts n
    (1..n).reduce(0) { |p,i| gcd(n,i)==1 ? p+1 : p }
  else
    nil
  end
end

# Carmichael Function - lambda(p,q)
def lam(p,q)
  (p-1).lcm(q-1)
end

# Return a prime number less than n bits
require 'openssl'
def prime(n)
  OpenSSL::BN::generate_prime(n).to_i
end

class Integer
  def prime?
    OpenSSL::BN.new(self).prime?
  end
end

# RSA private key generator
# Returns private key for public key e and modulus
# the modlus can be given as a number n
# or as a pair of primes [p,q].
# It is only practical to use [p,q] when n is large - this is what secures RSA.
def key(e, *args)
  case args.length
  when 1
    n = args[0]
    t = phi(n) # this is the "hard" thing when n is big!
  when 2
    # p and q must be distinct primes and coprime with e
    args.each { |i| assert i.prime?, coprime(e,i-1) }
    p, q = *args
    assert p != q

    n = p*q
    t = lam(p,q) # use Carmichael Numbers instead of Primes
  else
    raise ArgumentError
  end

  # modulus n must be n>2 otherwise, for n=2 you get phi(2)=1
  # which is effectively modulo 1. Modulo 1 is zero for any n
  # and can therefore not satisfy Euler's Theorem.
  assert n>2

  # From Euler's theorem, e and d must be coprime so that:
  # e.d = phi(n)+1 (mod phi(n)) => e.d +k.phi(n) = 1 (Bézout's Identity)
  assert coprime(e,t)

  # Because e is coprime to phi(n), the multiplicative inverse of e with
  # respect to phi(n) can be efficiently and quickly determined using the
  # Extended Euclidean Algorithm.  This multiplicative inverse is the private key.
  a,b = eea(e,t)               # Extended Euclidean Algorithm (we don't need b
  assert (a*e)%t == gcd(e,t) # Bézout's Identity             except to assert!)

  # The private key is the coefficient a (mod phi(n)). We apply mod phi(n) in
  # case a is negative; this returns a positive congruence
  d = a % t                           # Private key
  assert d*e%t == 1                   # Euler's theorem
  puts "a:#{a}\t\tb:#{b}\t\td:#{d}\te:#{e}\tt:#{t}" if LOG

  [d, n]

end

# Modular exponent
def powmod(base, exponent, modulus, *)
  return modulus==1 ? 0 : begin
    result = 1
    base = base % modulus
    while exponent > 0
      result = result*base%modulus if exponent%2 == 1
      exponent = exponent >> 1
      base = base*base%modulus
    end
    result
  end
end

# RSA cipher function
def cipher(m, e, n)
  assert m < n
  assert coprime(g=gcd(m,n),n/g)
  #above assertion replaces below as per http://crypto.stackexchange.com/questions/33802
  #assert coprime(m,n) # for Euler's theorem so m^phi(n) = 1 (mod phi(n))
  powmod(m,e,n)
end
