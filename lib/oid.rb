# Credit:
# http://robvs.wordpress.com/2010/07/08/obfuscating-ids-in-urls-with-rails/

require 'base32/crockford'

module OID

  MAXID = 2147483647  # (2**31 - 1)
  PRIME = 1580030173  # number suggested on the blog
  PRIME_INVERSE = 59260789 # (PRIME * PRIME_INVERSE) & MAXID == 1

  def self.encode(id)
    encoded_id = (id.to_i * self::PRIME) & self::MAXID
    Base32::Crockford.encode(encoded_id).downcase
  end

  def self.decode(oid)
    encoded_id = Base32::Crockford.decode(oid)
    (encoded_id * self::PRIME_INVERSE) & self::MAXID
  end
end
