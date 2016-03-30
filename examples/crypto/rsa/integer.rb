#!/usr/bin/ruby
#
# Integer extensions
#
# This work by John lane 20160328

class Integer

  # Return true if a (self) and b are coprime (relatively prime),
  # false otherwise
  # two numbers are coprime if their greatest common divisor is 1
  def coprime(b)
    gcd(b) == 1
  end

  # Return greatest common divisor of a (self) and b using Euclid's Algorithm.
  # Typically the arguments are given such that a>b but it also works
  # when a<b - an extra iteration will occur which swaps them around.
  def gcd(b)
    (r = self % b) == 0 ? b : b.gcd(r)
  end

  # Euler's Totient Function - phi(n) 
  # the number of nonzero integers less than self that are relatively
  # prime to self. Note that this performs the iterative calculation
  # and is not suitable for calculating Phi for large numbers (to do
  # so would take forever, well a very long time anyway...)
  def phi
    (1..self).reduce(0) { |p,i| gcd(i)==1 ? p+1 : p }
  end

  # Return coefficients s and t for the relationship gcd(a,b) = sa+tb
  # using the Extended Euclidean Algorithm, where a is self.
  # (sa+tb is called Bézout's identity)
  def eea(b)
    return b==0 ? [1,b] : begin
      q, r = self.divmod b
      s, t = b.eea(r)
      [t, s - q * t]
    end 
  end

  private

  # Modular exponent
  def powmod(exponent, modulus)
    return modulus==1 ? 0 : begin
      result = 1
      base = self % modulus
      while exponent > 0
        result = result*base%modulus if exponent%2 == 1
        exponent = exponent >> 1
        base = base*base%modulus
      end
      result
    end
  end

end

class Bignum
  alias_method '_pow', '**'
  def **(args)
    args.is_a?(Array) ? powmod(*args) : _pow(*args)
  end
end

class Fixnum
  alias_method '_pow', '**'
  def **(args)
    args.is_a?(Array) ? powmod(*args) : _pow(*args)
  end
end
