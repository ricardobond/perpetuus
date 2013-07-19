require "travis"

module Perpetuus
  class Build < Travis::Client::Repository

    attr_accessor :username, :repository
    attr_reader :client

    def initialize
      @username = extract_user_from_git_url
      @repository = extract_repo_name_from_git_url
      @client = Travis::Client.new
    end

    def builded_with_success?
      self.is_valid? ? git_repo.green? : false 
    end

    def is_valid?
      git_repo ? true : false
    end

    def git_remote_url
      remote = `git remote -v`
      begin_of_url = "origin\t"
      end_of_url = " "
      remote[/#{begin_of_url}(.*?)#{end_of_url}/m, 1]
    end

    private

    def extract_user_from_git_url
      remote_url = git_remote_url
      begin_of_user = "https://github.com/"
      end_of_user = "/"
      remote_url[/#{begin_of_user}(.*?)#{end_of_user}/m, 1]
    end

    def extract_repo_name_from_git_url
      git_remote_url.split("/").last.sub(".git", "")
    end

    def git_repo
      begin
        @client.repo("#{@username}/#{@repository}")
      rescue Travis::Client::NotFound
        puts "Username or repository doesn't exist!"
      end
    end
  end
end