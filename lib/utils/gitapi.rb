#!/usr/bin/ruby

module Migrate

    # The Git API takes care of common git operations on a repository that
    # is available locally at a pather (not necessarily the present working directory).
    class GitApi

        # Set only the origin url to push to. This command leaves the fetch
        # url as is. The push_origin_url is assumed sensitive as it may
        # contain either passwords or access tokens. As such it is not logged.
        #
        # The remote origin must be set before calling this method. If no origin
        # is set this will throw a "no origin" error.
        #
        # @param repo_path [String] folder path to the desired git repository
        # @param push_origin_url [String] the push URL of the remote origin
        def self.set_push_origin_url( repo_path, push_origin_url )

            git_loggable_cmd = "git --git-dir=#{repo_path} --work-tree=#{repo_path} remote set-url --push origin"
            git_set_push_origin_url_cmd = "#{git_loggable_cmd} #{push_origin_url}"
            %x[#{git_set_push_origin_url_cmd}];

        end


        # Push the commit bundles to the remote git repository. This push is
        # deep and carries all the branches and references with it.
        #
        # @param repo_path [String] folder path to the desired git repository
        def self.push( repo_path )

            git_push_cmd = "git --git-dir=#{repo_path} --work-tree=#{repo_path} push --mirror"
            system git_push_cmd

        end

    end

end
