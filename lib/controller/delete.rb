#!/usr/bin/ruby
	
module Migrate

  # You will never know why deleting migrated github repositories is a useful feature
  # until you have migrated 100 repositories - spotted a mistake - then spent the better
  # part of an evening clicking through the Github UI deleting the aforementioned repos.
  #
  # To guard against deleting repository assets in the destination added post migration
  # a bare clone is taken of the github repository before deletion.
  class Delete

    def delete

      conf = Migrate::Config.new()
      Dir.mkdir conf.cache_backup_dir

      conf.repositories.each do |repo|

        local_repo_path = "#{conf.cache_backup_dir}/#{repo[:github_prefix]}.#{repo[:repository_name]}"
        github_repository_name = "#{repo[:github_prefix]}#{conf.github_separator}#{repo[:repository_name]}"
        github_qualified_rname = "#{conf.github_organization}/#{github_repository_name}"

        repo_exists = Github.repository_exists?( conf.github_access_token, github_qualified_rname )

        print_skip_banner unless repo_exists
        puts "Repository #{github_repository_name} does NOT exist. Skipping it." unless repo_exists
        next unless repo_exists

        print_delete_banner
        puts "Repository #{github_repository_name} EXISTS. We shall delete it."
        github_repository_url = get_github_repo_url( conf, github_qualified_rname )
        clone_github_repository( local_repo_path, github_repository_name, github_repository_url )
        Github.delete_repository( conf.github_access_token, github_qualified_rname )
        puts "Deleted github repository #{github_repository_name}"


      end

      puts ""; puts "Repository deletion completed successfully."; puts "";

    end


    private


    def clone_github_repository( local_repo_path, github_repo_name, github_repo_url )

        puts "GitHub Repository =>> #{local_repo_path}/#{github_repo_name}"
        clone_command = "git clone --mirror #{github_repo_url} #{local_repo_path}"
        clone_output = %x[#{clone_command}];
        puts clone_output
        puts "Finished cloning to backup #{github_repo_name} at #{Migrate::TimeStamp.readable()}."

    end


    def get_github_repo_url( conf, github_qualified_repo_name )

        github_url_head = "https://#{conf.github_username}:"
        github_url_tail = "@github.com/#{github_qualified_repo_name}.git"
        return "#{github_url_head}#{conf.github_access_token}#{github_url_tail}"

    end


    def print_delete_banner

        puts ""
        puts "@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@"
        puts "@@@ Cloning to Back Up Repository then Deleting It @@@"
        puts "@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@"

    end


    def print_skip_banner

        puts ""
        puts "@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@"
        puts "@@@ Skipping Repository as it Does Not Exist @@@"
        puts "@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@"

    end


  end


end
