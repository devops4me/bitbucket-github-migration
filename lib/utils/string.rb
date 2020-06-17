#!/usr/bin/ruby


# Reopen the core ruby String class and add behaviour to it
# to aide the migration.
class String

  # Return a new string matching this one with every non alpha-numeric
  # character removed. This string is left unchanged.
  #
  # Spaces, hyphens, underscores, periods are all removed. The only
  # characters left standing belong to a set of 62 and are
  #
  # - a to z
  # - A to Z
  # - 0 to 9
  #
  # @return [String]
  #    Remove any character that is not alphanumeric, a to z, A to Z
  #    and 0 to 9 and return a new string leaving this one unchanged.
  def to_alphanumeric
    return self.delete("^A-Za-z0-9")
  end



  # To hex converts this string to hexadecimal form and returns
  # the result leaving this string unchanged.
  # @return [String] hexadecimal representation of this string
  def to_hex

    return self.unpack("H*").first

  end



  # From hex converts this (assumed) hexadecimal string back into
  # its normal string form and returns the result leaving this string
  # unchanged.
  # @return [String] string that matches the hexadecimal representation
  def from_hex

    return [self].pack("H*")

  end



  # Return true if every character in this string is lowercase.
  # Note that if this string is empty this method returns true.
  #
  # @return true if every alpha character in this string is lowercase
  def is_all_lowercase?
    return self.downcase.eql? self
  end



end
