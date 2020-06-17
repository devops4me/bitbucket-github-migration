#!/usr/bin/ruby

module Migrate

  require 'inifile'

  # DataMap is a <b>key-value</b> store backed by a plain-text file in
  # an <b>INI format</b> that sits on an accessible file-system.
  #
  class DataMap

    # Initialize the key value store.
    #
    # The path to the backing INI file is gleened from the first
    # backing file path parameter.
    #
    # @param backing_file_path [String]
    #    the expected location of the file-backed key-value store.
    #    If the folder and/or file do not exist the folder is created
    #    and then the file is created along with the time stamps.
    #
    # @param the_default_group [String]
    #    the name of the default group. If none is presented this value
    #    will default to the aptly named "default".
    def initialize( backing_file_path )
      @file_path = backing_file_path
    end


    # Set the section to use for future data exchanges via the ubiquitous {get}
    # and {set} methods as well as the query {contains} key method.
    #
    # @param the_section_name [String]
    #    the non-nil and non whitespace only section name that will lead a
    #    set of key-value pairs in the INI formatted file.
    def use( the_section_name )
      raise ArgumentError, "Cannot use a Nil section name." if the_section_name.nil?
      @section_to_use = the_section_name
    end

    # Stash the setting directive and its value into the configuration file
    # using the default settings group.
    #
    # @param key_name [String] the name of the key whose value is to be written
    # @return [String]
    #    return the value of the configuration directive in the default group
    def get( key_name )
      raise ArgumentError, "Cannot get from a Nil section name." if @section_to_use.nil?
      read( @section_to_use, key_name )
    end


    # Return the name of the currently in-focus section that has been set using
    # the {use} method.
    #
    # @return [String]
    #    return the name of the currently in-focus section
    def section()
      raise ArgumentError, "The use method has not specified a section." if @section_to_use.nil?
      return @section_to_use
    end


    # Given the configuration key name and the context name, get the
    # corresponding key value from the configuration file whose path
    # is acquired using the {self#get_filepath} method.
    #
    # @param key_name [String] the key whose value is to be retrieved
    #
    # @return [String] the value configured for the parameter key
    #
    # @raise ArgumentError for any one of a long list of reasons that
    #     cause the key value to not be retrieved. This can range from
    #     non-existent directories and files, non readable files, incorrect
    #     configurations right down to missing keys or even missing values.
    def read( section_name, key_name )

      raise ArgumentError.new "No section given." if section_name.nil? || section_name.strip.empty?
      raise ArgumentError.new "No parameter key given." if key_name.nil? || key_name.strip.empty?
      raise ArgumentError.new "No file found at [ #{@file_path} ]" unless File.exists? @file_path
      the_text = File.read @file_path
      raise ArgumentError.new "This file is empty => [ #{@file_path} ]" if the_text.empty?

      the_data = IniFile.load @file_path
      key_exists = the_data[ section_name ].has_key?( key_name )
      key_err_msg = "Key [#{key_name}] not found in section [#{section_name}]"
      raise ArgumentError, key_err_msg unless key_exists

      rawvalue = the_data[section_name][key_name]
      key_val_msg = "Nil empty or whitespace value for key [#{section_name}][#{key_name}]"
      nil_empty_or_whitespace = rawvalue.nil? || rawvalue.to_s.chomp.strip.empty?
      raise ArgumentError, key_val_msg if nil_empty_or_whitespace

      return rawvalue.to_s.chomp.strip

    end


    # Return true if the settings configuration file contains the specified
    # parameter key within the current section name that has been set via
    # the {use} method.
    #
    # This method does not check the contents (value) of the key. Even if it
    # is an empty string, this method returns true so long as the section
    # exists and the key exists within that.
    #
    # @param key_name [String]
    #    does a key with this name exist within the current map section.
    #
    # @return [Boolean]
    #    return true if the current section exists and a key with the parameter
    #    name exists within it.
    #    return false if <b>either</b> the section <b>or</b> the key do not exist.
    #
    # raise [ArgumentError]
    #    if the configuration file does not exist or is empty
    #    if the paramter key_name is nil, empty or contains only whitespace
    def contains?( key_name )

      raise ArgumentError.new "No parameter key given." if key_name.nil? || key_name.strip.empty?
      raise ArgumentError.new "No file found at [ #{@file_path} ]" unless File.exists? @file_path
      the_text = File.read @file_path
      raise ArgumentError.new "This file is empty => [ #{@file_path} ]" if the_text.empty?

      the_data = IniFile.load @file_path
      return false unless the_data.has_section?( @section_to_use )
      return the_data[ @section_to_use ].has_key?( key_name )

    end


    # Return true if the settings configuration file contains the specified
    # section name. This method ignores whatever section that may or may not
    # have been pointed to by the use command.
    #
    # @param section_name [String]
    #    does a section with this name exist within the file data structure
    #
    # @return [Boolean]
    #    return true if a section exists with the specified name
    def has_section?( section_name )

      KeyError.not_new( section_name, self )

      raise ArgumentError.new "No file found at [ #{@file_path} ]" unless File.exists? @file_path
      the_text = File.read @file_path
      raise ArgumentError.new "This file is empty => [ #{@file_path} ]" if the_text.empty?

      the_data = IniFile.load @file_path
      return the_data.has_section?( section_name )

    end


    def section_names( prefix_to_axe )

      raise ArgumentError.new "No file found at [ #{@file_path} ]" unless File.exists? @file_path
      the_text = File.read @file_path
      raise ArgumentError.new "This file is empty => [ #{@file_path} ]" if the_text.empty?

      the_data = IniFile.load @file_path
      section_names_array = Array.new
      the_data.each_section do |section|
        next unless section.start_with?( prefix_to_axe )
        section_name = section[ prefix_to_axe.length() .. -1 ]
        section_names_array.push( section_name )
      end
      
      return section_names_array

    end


    # Fetch this one-dimensional data store as a string in INI file format.
    # @return [String] an INI formatted string representation of this data
    def as_string()

      data_map = IniFile.new( :filename => @file_path, :encoding => 'UTF-8' )
      data_map = IniFile.load( @file_path ) if File.file? @file_path
      return data_map.to_s

    end


  end


end
