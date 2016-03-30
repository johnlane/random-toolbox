#!/usr/bin/ruby
#
# Understanding the maths behind RSA
#
# This work by John lane 20160316

require_relative 'integer'

# Simple assertion takes a list of booleans
# It raises an exception if any are false or if the list is empty
def assert(*args)
  assert false unless args.length > 0
  args.each { |a| raise RuntimeError, "Assertion Failed", caller unless a }
end

# Return true if a and b are coprime (relatively prime), false otherwise
# two numbers are coprime if their greatest common divisor is 1
# (in support of assertions; not part of algorithm)
def coprime(a,b)
  a.coprime(b)
end

# Euler's Totient Function - phi(n) 
# the number of nonzero integers less than n that are relatively prime to n
# if given one argument then the iterative calculation is performed
# if given two arguments then assumes they're prime and coprime and calculates directly
def phi(*args)
  puts "Computing phi#{args}" if LOG
  case args.length
  when 2
    # phi = (p-1)(q-1) is valid only for coprime p and q
    assert coprime(*args)
    (args[0]-1)*(args[1]-1)
  when 1
    args[0].phi
  else
    nil
  end
end

# Carmichael Function - lambda(p,q)
def lam(p,q)
  (p-1).lcm(q-1)
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
    t = n.phi # this is the "hard" thing when n is big!
  when 2
    # p and q must be distinct primes and coprime with e
    args.each { |i| assert i.prime?, e.coprime(i-1) }
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

  # From Euler's theorem, e and phi(n) must be coprime so that:
  # e.d = phi(n)+1 (mod phi(n)) => e.d +k.phi(n) = 1 (Bézout's Identity)
  assert e.coprime(t)

  # Because e is coprime to phi(n), the multiplicative inverse of e with
  # respect to phi(n) can be efficiently and quickly determined using the
  # Extended Euclidean Algorithm.  This multiplicative inverse is the private key.
  a,b = e.eea(t)               # Extended Euclidean Algorithm (we don't need b
  assert (a*e)%t == e.gcd(t)   # Bézout's Identity             except to assert!)

  # The private key is the coefficient a (mod phi(n)). We apply mod phi(n) in
  # case a is negative; this returns a positive congruence
  d = a % t                           # Private key
  assert d*e%t == 1                   # Euler's theorem

  puts "a:#{a}\tb:#{b}\td:#{d}\te:#{e}\tt:#{t}" if LOG

  # The Chinese Remainder Theorem can be used to speed up the decryption process
  # if the primes p and q are known. Its use is optional but we compute its
  # three parameters so that it can be used to decipher a message (but the
  # default mechanism can still be used instead).
  # It doesn't work if p or q are less than two because the moduli for dp and dq
  # can become modulo 1 which is zero and things no longer work out.
  if defined?(p) && p.to_i>2 && defined?(q) && q.to_i>2
    dp = d % (p-1)
    dq = d % (q-1)
    qinv = q.eea(p).first % p # mod p to get positive congruence
    puts "dp:#{dp}\tdq:#{dq}\tqinv:#{qinv}" if LOG

    [d,n,p,q,dp,dq,qinv]

  else
  
    [d, n]

  end

end

# RSA crypt function can be used to encrypt or decrypt
def crypt(m, e, n)
  assert m < n
  assert coprime(g=m.gcd(n),n/g)
  #above assertion replaces below as per http://crypto.stackexchange.com/questions/33802
  #assert coprime(m,n) # for Euler's theorem so m^phi(n) = 1 (mod phi(n))
  e**[e,n]
end

# RSA decrypt function can be used to decrypt by the Chinese Remainder Theorem
def decrypt(c,p,q,dp,dq,qinv)
  assert p>2 and q>2                # see 'key' method for rationale
  n = p*q
  assert c < n
  assert coprime(g=c.gcd(n),n/g)

  m1 = c**[dp,p]
  m2 = c**[dq,q]
  h  = qinv*(m1-m2) % p # mod p to keep the sum positive
  m  = m2 + h*q
end
