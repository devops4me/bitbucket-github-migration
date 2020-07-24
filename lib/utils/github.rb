#!/usr/bin/ruby

module Migrate

    # The Github class uses the REST API to talk to Github and create, query,
    # change and delete assets within a specified hosted git repository.
    #
    # Note that you can ply the new github repository with a SSH public key
    # so that those who know the corresponding private key can post to it. To do
    # this a repository ID in the format user_name/repository_name must be
    # provided.
    #
    #    repository_id = "#{github_user[:login]}/#{repository_name}"
    #    github_client.add_deploy_key( repository_id, "key description", repo_public_key )
    #
    class Github

        require "etc"
        require "socket"
        require "octokit"

        # Create a github git repository when given an access token and the
        # required repository name.
        #
        # @param conf [Map] map of configuration values
        # @param repository_name [String] name of the non-existent repository to create
        # @return [String] name of the github user
        def self.create_repository( conf, repository_name )

            github_client = Octokit::Client.new( :access_token => conf.github_access_token )
            github_user = github_client.user
            repo_creator = "#{ENV[ "USER" ]}@#{Socket.gethostname()}"
            repo_description = "This github repository was auto-created by a migration script on #{TimeStamp.readable()}."
            repo_homepage = "https://github.com"

            puts ""
            puts "Repository Name  =>  #{repository_name}"
            puts "Github Company   =>  #{github_user[:company]}"
            puts "Account Owner    =>  #{github_user[:name]}"
            puts "Github User ID   =>  #{github_user[:id]}"
            puts "Github Username  =>  #{github_user[:login]}"
            puts "Github Org Name  =>  #{conf.github_organization}"
            puts "Github Team Id   =>  #{conf.github_team_id}"

            puts "Creation Entity  =>  #{repo_creator}"
            puts "Repo Descriptor  =>  #{repo_description}"
            puts "Repo Homepage    =>  #{repo_homepage}"
            puts ""

            options_hash =
              {
                :description => repo_description,
                :repo_homepage => repo_homepage,
                :organization => conf.github_organization,
                :private => true,
                :has_issues => false,
                :has_wiki => false,
                :has_downloads => false,
                :auto_init => false
              }

            # Only add the team ID to the options hash if it is provided
            team_id_nil_or_empty = conf.github_team_id.nil? || conf.github_team_id.to_s.chomp.strip.empty?
            options_hash[ :team_id ] = conf.github_team_id unless team_id_nil_or_empty

            github_client.create_repository( repository_name, options_hash  )
            return github_user[:login]

        end


        # Create a github git repository when given an access token and the
        # required repository name.
        #
        # @param conf [Map] map of configuration values
        # @param repository_name [String] name of the non-existent repository to create
        # @return [String] name of the github user
        def self.create_repository( conf, repository_name )

            github_client = Octokit::Client.new( :access_token => conf.github_access_token )
            github_user = github_client.user
            repo_creator = "#{ENV[ "USER" ]}@#{Socket.gethostname()}"
            repo_description = "This github repository was auto-created by a migration script on #{TimeStamp.readable()}."
            repo_homepage = "https://github.com"

            puts ""
            puts "Repository Name  =>  #{repository_name}"
            puts "Github Company   =>  #{github_user[:company]}"
            puts "Account Owner    =>  #{github_user[:name]}"
            puts "Github User ID   =>  #{github_user[:id]}"
            puts "Github Username  =>  #{github_user[:login]}"
            puts "Github Org Name  =>  #{conf.github_organization}"
            puts "Github Team Id   =>  #{conf.github_team_id}"

            puts "Creation Entity  =>  #{repo_creator}"
            puts "Repo Descriptor  =>  #{repo_description}"
            puts "Repo Homepage    =>  #{repo_homepage}"
            puts ""

            options_hash =
              {
                :description => repo_description,
                :repo_homepage => repo_homepage,
                :organization => conf.github_organization,
                :private => true,
                :has_issues => false,
                :has_wiki => false,
                :has_downloads => false,
                :auto_init => false
              }

            # Only add the team ID to the options hash if it is provided
            team_id_nil_or_empty = conf.github_team_id.nil? || conf.github_team_id.to_s.chomp.strip.empty?
            options_hash[ :team_id ] = conf.github_team_id unless team_id_nil_or_empty

            github_client.create_repository( repository_name, options_hash  )
            return github_user[:login]

        end


        # Create a github git repository when given an access token and the
        # required repository name.
        #
        # @param conf [Map] map of configuration values
        # @param repository_name [String] name of the non-existent repository to create
        # @return [String] name of the github user
        def self.create_repository_with_curl( conf, repository_name )

            github_client = Octokit::Client.new( :access_token => conf.github_access_token )
            github_user = github_client.user
            repo_creator = "#{ENV[ "USER" ]}@#{Socket.gethostname()}"
            repo_description = "This github repository was auto-created by a migration script on #{TimeStamp.readable()}."
            repo_homepage = "https://github.com"

            puts ""
            puts "Repository Name  =>  #{repository_name}"
            puts "Github Company   =>  #{github_user[:company]}"
            puts "Account Owner    =>  #{github_user[:name]}"
            puts "Github User ID   =>  #{github_user[:id]}"
            puts "Github Username  =>  #{github_user[:login]}"
            puts "Github Org Name  =>  #{conf.github_organization}"
            puts "Github Team Id   =>  #{conf.github_team_id}"

            puts "Creation Entity  =>  #{repo_creator}"
            puts "Repo Descriptor  =>  #{repo_description}"
            puts "Repo Homepage    =>  #{repo_homepage}"
            puts ""

            options_hash =
              {
                :description => repo_description,
                :repo_homepage => repo_homepage,
                :organization => conf.github_organization,
                :private => true,
                :has_issues => false,
                :has_wiki => false,
                :has_downloads => false,
                :auto_init => false
              }

            # Only add the team ID to the options hash if it is provided
            team_id_nil_or_empty = conf.github_team_id.nil? || conf.github_team_id.to_s.chomp.strip.empty?
            options_hash[ :team_id ] = conf.github_team_id unless team_id_nil_or_empty

curl_cmd = "curl -H \"Accept: application/vnd.github.nebula-preview+json\" -H \"Authorization: token #{conf.github_access_token}\" -d \'{\"name\": \"#{repository_name}\", \"owner\": \"#{conf.github_organization}\", \"description\": \"#{repo_description}\", \"visibility\":\"internal\"}\' -X POST \"https://api.github.com/orgs/#{conf.github_organization}/repos\""

## with team id
## curl_cmd = "curl -H "Accept: application/vnd.github.nebula-preview+json" -H \"Authorization: token #{conf.github_access_token}\" -d \'{\"name\": \"#{repository_name}\", \"owner\": \"#{conf.github_organization}\", \"team_id\": \"#{conf.github_team_id}\", \"description\": \"#{repo_description}\", \"visibility\":\"internal\"}\' -X POST \"https://api.github.com/orgs/#{conf.github_organization}/repos\""

##curl -s -H "Content-Type:application/json" -H "Authorization: token v1.58dba9f897463cd86406ad05d4fe7bc8d1a986fe" -H "Accept: application/vnd.github.nebula-preview+json" -X POST 'https://api.github.com/orgs/Ahold-Delhaize-Sandbox/repos' -d $json
 

#puts ""
#puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
#puts curl_cmd
#puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
#puts ""

            %x[#{curl_cmd}];

####            return github_user[:login]

        end


        # Return a boolean representing whether the specified repository exists.
        #
        # @param github_access_token [String] hexadecimal github access token
        # @param repository_name [String] name of the repository to look for
        # @return [Boolean] true if the repository exists, false otherwise
        def self.repository_exists?( github_access_token, repository_name )

            github_client = Octokit::Client.new( :access_token => github_access_token )
            return github_client.repository?( repository_name )

        end


        # Delete the Github repository specified in the parameter.
        #
        # @param github_access_token [String] hexadecimal github access token
        # @param repository_name [String] name of the repository to delete
        def self.delete_repository( github_access_token, repository_name )

            github_client = Octokit::Client.new( :access_token => github_access_token )
            github_client.delete_repository( repository_name )

        end


    end


end
