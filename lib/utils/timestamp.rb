#!/usr/bin/ruby

module Migrate

  require 'singleton'

  class TimeStamp
    include Singleton

    attr_reader :time_now

    # Return two digit [mo] month index from 01 to 12.
    # @example 02 => in February
    #
    def self.mo
      return TimeStamp.instance.time_now.strftime "%m"
    end


    # Return three character abbreviated month name.
    # @example feb => in February
    #
    def self.mmm
      return TimeStamp.instance.time_now.strftime( "%b" ).downcase
    end


    #
    # Return three character abbreviated day of week.
    # @example tue => on Tuesday
    #
    def self.ddd
      return TimeStamp.instance.time_now.strftime( "%a" ).downcase
    end


    #
    # Return two digit (character) hour of day from 00 to 23.
    # @example 22 => between 22.00.00 and 22.59.59 inclusive
    #
    def self.hh
      return TimeStamp.instance.time_now.strftime "%H"
    end


    #
    # Return two digit minute of hour from [00] to [59].
    #
    def self.mm
      return TimeStamp.instance.time_now.strftime "%M"
    end


    #
    # Return two digit second of minute from [00] to [59].
    #
    def self.ss
      return TimeStamp.instance.time_now.strftime "%S"
    end


    #
    # Return a [3 digit] second and tenth of second
    # representation.
    #
    # The final digit is derived from the 1000 sliced
    # millisecond of second running from 000 to 999.
    #
    # <tt>Truncation (Not Rounding)</tt>
    #
    # The [final] digit is acquired by TRUNCATING
    # (chopping off) the last 2 of the 3 millisecond
    # digits. No rounding is applied.
    #
    # The 3 returned digits comprise of the
    #
    # - second of minute => 2 digits | [00] to [59] (and)
    # - tenth of second  => 1 digit from [0] to [9]
    #
    # @example
    #
    #  => The time at the 562nd millisecond  of the 49th
    #     second of the minute.
    #
    #  => 3 chars
    #  => 495
    #
    #
    def self.sst
      millisec_string = TimeStamp.instance.time_now.strftime "%L"
      return "#{ss}#{millisec_string[0]}"
    end


    #
    # Return the [two] digit year (eg 19 for 2019).
    # that we are currently in.
    #
    def self.yy
      return TimeStamp.instance.time_now.strftime("%Y")[2..-1]
    end


    #
    # Return the [one] digit year (eg 9 for 2019).
    # that we are currently in.
    #
    def self.y
      return TimeStamp.instance.time_now.strftime("%Y")[3..-1]
    end


    #
    # Return the [four] digit year (eg 2019)
    # that we are currently in.
    #
    def self.yyyy
      return TimeStamp.instance.time_now.strftime("%Y")
    end


    # ------------------------------------------------- -- #
    # Return 3 digit julian day of year [001] to [366]. -- #
    # ------------------------------------------------- -- #
    def self.jjj
      return TimeStamp.instance.time_now.strftime "%j"
    end


    # [yymo_mmm] returns an amalgam of
    #
    #    => the two-digit year
    #    => the two-digit month index (starting at 01)
    #    => a period (separator)
    #    => the abbreviated month name
    #
    # @example
    #   => 1908.aug
    #   => for August 2019
    #
    def self.yymo_mmm
      return "#{yy}#{mo}.#{mmm}"
    end


    # Return 5 digit amalgam of year and julian day.
    #  eg [19003] for [January 3rd 2019]
    def self.yyjjj
      return "#{yy}#{jjj}"
    end


    # Return 4 digit amalgam of year and julian day.
    #  eg [9003] for [January 3rd 2019]
    def self.yjjj
      return "#{y}#{jjj}"
    end


    # Return the 4 digit amalgam of the hour and minute
    # using the 24 hour clock.
    #
    # @example
    #   => 1525
    #   => 03:25 pm
    #
    def self.hhmm
      return "#{hh}#{mm}"
    end


    #
    # Return the time of day to a TENTH of a second accuracy.
    # [8] characters will always be returned with the 5th one
    # being the (period) separator.
    #
    # The first (separated) segment delivers a hhmm 24 hour
    # clock representation of the stamped time.
    #
    # The 3 digits of the second segment comprise of
    #
    #   second of minute => 2 digits | [00] to [59]
    #   tenth of second  => 1 digit from [0] to [9]
    #
    # @example
    #   => The time at the 562nd millisecond  of the 49th
    #      second of the 23rd minute of the 17th hour of
    #      the day ( 17:23:49.562 )
    #
    #   => 8 chars
    #   => 1723.495
    #
    def self.hhmm_sst
      return "#{hhmm}.#{sst}"
    end


    # Return a string timestampt that is a period separated
    # amalgam of the 2 digit year, 3 digit julian day, 2 digit
    # hour, 2 digit minute, 2 digit second and 1 digit rounded
    # down tenth of second.
    #
    # Return the time of day to a TENTH of a second accuracy.
    # [8] characters will always be returned with the 5th one
    # being the (period) separator.
    #
    # The first (separated) segment delivers a hhmm 24 hour
    # clock representation of the stamped time.
    #
    # The 3 digits of the second segment comprise of
    #
    # - second of minute => 2 digits | [00] to [59]
    # - tenth of second  => 1 digit from [0] to [9]
    #
    # @example
    #   => The time at the 562nd millisecond  of the 49th
    #      second of the 23rd minute of the 17th hour of
    #      the day ( 17:23:49.562 )
    #
    #   => 8 chars
    #   => 1723.495
    #
    def self.yyjjj_hhmm_sst
      return "#{yyjjj}.#{hhmm}.#{sst}"
    end


    # Return the time of day to a TENTH of a second accuracy
    # via a string timestamp with zero separation.
    #
    # The timestampt returned is an amalgam of
    #
    # - a 2 digit year
    # - a 3 digit julian day
    # - a 2 digit hourn
    # - a 2 digit minute
    # - a 2 digit second and finally
    # - a 1 digit (rounded down) tenth of a second
    #
    # The 3 digits of the second segment comprise of
    #
    # - second of minute => 2 digits | [00] to [59]
    # - tenth of second  => 1 digit from [0] to [9]
    #
    # @example
    #   => The time at the 562nd millisecond  of the 49th
    #      second of the 23rd minute of the 17th hour of
    #      the day ( 17:23:49.562 )
    #
    #   => 8 chars
    #   => 1723.495
    #
    def self.yyjjjhhmmsst
      return "#{yyjjj}#{hhmm}#{sst}"
    end


    # Return the time of day to a TENTH of a second accuracy
    # via a string timestamp with zero separation.
    #
    # The timestampt returned is an amalgam of
    #
    # - a 1 digit year
    # - a 3 digit julian day
    # - a 2 digit hourn
    # - a 2 digit minute
    # - a 2 digit second and finally
    # - a 1 digit (rounded down) tenth of a second
    #
    # The 3 digits of the second segment comprise of
    #
    # - second of minute => 2 digits | [00] to [59]
    # - tenth of second  => 1 digit from [0] to [9]
    #
    # @example
    #   => The time at the 562nd millisecond  of the 49th
    #      second of the 23rd minute of the 17th hour of
    #      the day ( 72349562 )
    #
    #   => 8 chars
    #   => 1723.495
    #
    def self.yjjjhhmmsst
      return "#{yjjj}#{hhmm}#{sst}"
    end


    # Return the time of day to a single minute accuracy
    # via a string timestamp with zero separation.
    #
    # The timestampt returned is an amalgam of
    #
    # - a 2 digit year
    # - a 3 digit julian day
    # - a 2 digit hourn
    # - a 2 digit minute
    #
    def self.yyjjjhhmm
      return "#{yyjjj}#{hhmm}"
    end


    # Return a string timestampt that is a period separated
    # amalgam of the 2 digit year, 3 digit julian day, 2 digit
    # hour, 2 digit minute, 2 digit second and <b>9 digit</b>
    # nanosecond.
    #
    # @example
    #   return  => 19003.1725.42.836592034
    #   4 time  => 17:25:42 am on January 3rd 2019
    #
    # As per the above example, the time returned
    #
    # - is the 836592034 <b>nanosecond</b>
    # - of the 42nd <b>second</b>
    # - of the 25th <b>minute</b>
    # - of the 17th <b>hour</b>
    # - of the 3rd <b>day</b>
    # - of the 20th <b>year</b>
    # - of the 21st <b>century</b>
    #
    # @return [String]
    #    Return the time of day to nanosecond accuracy.
    #    23 characters are always returned with three (3) period
    #    separators at the 6th, 11th and 14th positions.
    def self.yyjjj_hhmm_ss_nanosec
      nanosec_str = TimeStamp.instance.time_now.strftime "%9N"
      return "#{yyjjj}.#{hhmm}.#{ss}.#{nanosec_str}"
    end


    # Fetch the human readable time stamp.
    #
    # @return [String]
    #    the human readable timestamp
    def self.human_readable
      return "#{Time.now.ctime} #{yyjjj_hhmm_sst}"
    end


    # Fetch the double barreled time stamp that is an amalgam of
    # the human readable time now and a machine time representation
    # from the moment this class was initialized.
    #
    # See the {yyjjj_hhmm_ss_nanosec} method for documentation of
    # the nanosecond accurate time stamp.
    #
    # @return [String]
    #    the double barreled time stamp containing a human readable
    #    (right this moment) time and a <b>class initialized time</b>
    #    representation with nanosecond accuracy.
    def self.fetch
      return "#{Time.now.ctime} ( #{yyjjj_hhmm_ss_nanosec} )"
    end


    # Fetch the human readable time denoting the weekday, month day,
    # month, year and the time (accurate to the nearest minute).
    #
    # @return [String]
    #    the weekday, month day, month, year and the hour minute time.
    def self.readable
      time_with_consecutive_spaces = Time.now.ctime
      return time_with_consecutive_spaces.gsub( "  ", " " )
    end


    # Grab the double barreled time stamp that is an amalgam of
    # the human readable time now and a machine time representation
    # from the moment this class was initialized.
    #
    #    On Friday June the 8th at about 6:26 pm.
    #    Fri Jun 8 18:26:17 2018 ( 18159.1826.138 )
    #
    # See the {yyjjj_hhmm_sst} method for documentation of stamp
    # that is accurate to the tenth of a second.
    #
    # @return [String]
    #    the double barreled time stamp containing a human readable
    #    (right this moment) time and a <b>class initialized time</b>
    #    representation with tenth of a second accuracy.
    def self.grab
      time_with_consecutive_spaces = Time.now.ctime
      human_readable_str = time_with_consecutive_spaces.gsub( "  ", " " )
      return "#{human_readable_str} ( #{yyjjj_hhmm_sst} )"
    end


    # Return the Rubyfied time zone being used.
    def self.zone
      return TimeStamp.instance.time_now.zone
    end


    # This singleton (one instance) class sets the time just once.
    def initialize
      @time_now = Time.now;
    end


  end


end
