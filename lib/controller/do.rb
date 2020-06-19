#!/usr/bin/ruby
	
module Migrate

  # Perform the bitbucket to github migration. This activity controller
  # depends on a GITHUB_ACCESS_TOKEN and MIGRATION_CONFIGURATION_FILE
  # mandatory environment variables. The list of repositories to migrate
  # is pulled in from an excel spreadsheet.
  class Do

    # If this dryrun flag is set to true then source repositories
    # will still be cloned to the local brain machine and the remote
    # github url will still be set. However
    # - repositories will not be created at the destination
    # - the push operation to mirror repo data will not occur
    attr_writer :dryrun

    # Perform the bitbucket to github migration. This involves
    #   1 - reading the config and spreadsheet data
    #   2 - create local caches for mirror and backup repos
    #   3 - looping over the repositories to migrate
    #   4 - cloning them (--mirror) from bitbucket
    #   5 - creating the github repository
    #   6 - changing the remote origin push url
    #   7 - pushing (--mirror) to the new github repository
    def do

      conf = Migrate::Config.new()
      clone_dir_path = File.join( Dir.pwd, conf.cache_mirror_dir )
      Dir.mkdir( clone_dir_path )

      conf.repositories.each do |repo|

        local_repo_path = "#{clone_dir_path}/#{repo[:github_prefix]}.#{repo[:repository_name]}"
        github_repository_name = "#{repo[:github_prefix]}#{conf.github_separator}#{repo[:repository_name]}"

        clone_repository( conf, repo, local_repo_path )
        create_github_repo_if_not_exists( conf.github_access_token, github_repository_name )
        set_origin_url( conf, repo, local_repo_path, github_repository_name )
        push_to_remote_origin( local_repo_path )

      end

      puts ""; puts "Repository migration completed successfully."; puts "";

    end


    private


    def clone_repository( conf, repo, local_repo_path )

        puts ""
        puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        puts "@@@@ From BitBucket =>> #{repo[:bitbucket_project]}/#{repo[:repository_name]}"
        puts "@@@@ To Github      =>> #{repo[:github_prefix]}#{conf.github_separator}#{repo[:repository_name]}"
        puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

        basic_clone_cmd = "git clone --mirror ssh://git@#{conf.bitbucket_host}:#{conf.bitbucket_port}/#{repo[:bitbucket_project]}/"
        clone_cmd = "#{basic_clone_cmd}#{repo[:repository_name]}.git #{local_repo_path}"
        puts "Local Repo Path =>> #{local_repo_path}"
        puts clone_cmd

        clone_output = %x[#{clone_cmd}];
        puts clone_output
        puts "Finished cloning #{repo[:github_prefix]}.#{repo[:repository_name]} at #{Migrate::TimeStamp.readable()}."

    end


    def create_github_repo_if_not_exists( access_token, github_repo_name )
        Github.create_repository( access_token, github_repo_name ) unless @dryrun
    end


    def set_origin_url( conf, repo, local_repo_path, github_repo_name )

        github_url_head = "https://#{conf.github_username}:"
        github_url_tail = "@github.com/#{conf.github_username}/#{github_repo_name}.git"
        puts "Github Origin Url =>> #{github_url_head}<GITHUB_ACCESS_TOKEN>#{github_url_tail}"
        GitApi.set_push_origin_url( local_repo_path, "#{github_url_head}#{conf.github_access_token}#{github_url_tail}" )

    end


    def push_to_remote_origin( local_repo_path )
        GitApi.push( local_repo_path ) unless @dryrun
    end


  end


end
