#!/usr/bin/ruby

module Migrate

  require 'inifile'
  require 'json'
  require "roo"

  # This class can read the configuration file and the data files
  # that are required to fuel the migration.
  class Config

    DEFAULT_CONFIGURATION_FILE="migrate-configuration.ini"
    MIGRATION_CONFIGURATION_FILE="MIGRATION_CONFIGURATION_FILE"

    attr_reader :bitbucket_host, :bitbucket_port
    attr_reader :github_separator, :github_access_token, :github_username
    attr_reader :repositories

    attr_reader :cache_mirror_dir, :cache_backup_dir


    # This constructor reads up the configuration from an INI file
    # and the data from an Excel spreadsheet.
    #
    # The path to the migrate INI configuration file is gleened from the
    # MIGRATION_CONFIGURATION_FILE environment variable.
    #
    # The path to the spreadsheet that carries the information on which
    # repositories to migrate is within the INI configuration.
    def initialize

      view_ssh_folder()

      @cache_mirror_dir = "repos.mirror.#{Migrate::TimeStamp.yyjjjhhmmsst()}"
      @cache_backup_dir = "repos.backup.#{Migrate::TimeStamp.yyjjjhhmmsst()}"

      read_configuration_data()

      @config_data.use( "source" )
      @bitbucket_host = @config_data.get( "bitbucket.host" )
      @bitbucket_port = @config_data.get( "bitbucket.port" )

      @config_data.use( "destination" )
      @github_separator = @config_data.get( "github.separator" )
      @github_username = @config_data.get( "github.username" )
      @github_access_token = @config_data.get( "github.access.token" )

      @config_data.use( "spreadsheet" )
      @sheet_filepath = @config_data.get( "sheet.filepath" )
      @sheet_repo_name_column = @config_data.get( "sheet.column.repository.name" )
      @sheet_bitbucket_project_name_column = @config_data.get( "sheet.column.bitbucket.project" )
      @sheet_github_prefix_column = @config_data.get( "sheet.column.github.prefix" )

      read_spreadsheet_data()

    end

    def view_ssh_folder

      puts ""
      puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@"
      puts "@@@ Viewing the SSH Folder Contents @@@"
      puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@"
      
      ssh_dir_path = File.join( Dir.home, ".ssh" )
      ssh_folder_list_cmd = "ls -lah #{ssh_dir_path}"
      puts ""; puts "Listing ssh folder contents with #{ssh_folder_list_cmd}"
      system ssh_folder_list_cmd

      puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@"
      puts ""

    end


    # Get the migration configuration data with the filepath specified
    # by an environment variable.
    #
    # @raise ArgumentError if the environment variable does not exist
    #     or no file can be found at the specified path.
    def read_configuration_data()

      default_conf_path = File.join( Dir.home, DEFAULT_CONFIGURATION_FILE )
      migration_filepath = default_conf_path unless ENV.has_key?( MIGRATION_CONFIGURATION_FILE )
      migration_filepath = ENV[ MIGRATION_CONFIGURATION_FILE ] if ENV.has_key?( MIGRATION_CONFIGURATION_FILE )

      @config_data = Migrate::DataMap.new( migration_filepath )

    end



    # Read the spreadsheet data where each row represents a repository to
    # migrate and there are at a minimum columns holding
    # - the repository name
    # - the repository bitbucket project
    # - the github prefix
    #
    # @raise ArgumentError if the spreadsheet does not exist at the specified
    #     path or the data inside it is inconsistent.
    def read_spreadsheet_data()

      raise ArgumentError.new( "No filepath configured for the migration spreadsheet." ) if @sheet_filepath.nil?

      sheet_full_path = File.join( Dir.home, @sheet_filepath )
#########      sheet_full_path = ::File.absolute_path( @sheet_filepath )
      sheet_exists = File.exist?( sheet_full_path ) && File.file?( sheet_full_path )
      raise ArgumentError.new( "Spreadsheet #{@sheet_filepath} [#{sheet_full_path}] was not found." ) unless sheet_exists

      ssheet = Roo::Spreadsheet.open( sheet_full_path )
      read_spreadsheet_rows( ssheet )

    end



    # Read the spreadsheet data rows where each row represents a repository to
    # migrate and there are at a minimum columns holding
    # - the repository name
    # - the repository bitbucket project
    # - the github prefix
    #
    # @raise ArgumentError if the spreadsheet does not exist at the specified
    #     path or the data inside it is inconsistent.
    def read_spreadsheet_rows( spreadsheet )

      raise ArgumentError.new( "No repository name column configured." ) if @sheet_repo_name_column.nil?
      raise ArgumentError.new( "No bitbucket project name column configured." ) if @sheet_bitbucket_project_name_column.nil?
      raise ArgumentError.new( "No github prefix column configured." ) if @sheet_github_prefix_column.nil?

      @repositories = Array.new
      skip_first = true
      spreadsheet.each( bitbucket_project: @sheet_bitbucket_project_name_column, repository_name: @sheet_repo_name_column, github_prefix: @sheet_github_prefix_column ) do | repository |
        @repositories.push( repository ) unless skip_first
        skip_first = false
      end

      puts JSON.pretty_generate( @repositories )
      puts ""; puts "There are [#{@repositories.length()}] repositories to migrate."; puts ""

    end


  end


end
