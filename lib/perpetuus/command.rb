require 'thor'

module Perpetuus
	class Command < Thor
		include Thor::Actions
		
		desc "setup", "Setup a new rails app ready to deploy in heroku"
		def setup
			@rails_app_name = ask_wizard("What's the name of rails project?", "rails")
			puts "CREATING RAILS APP...".green
			Perpetuus.new_rails_app(@rails_app_name)
		end

		desc "deploy", "Deploy your local branch to heroku if build passes"
		def deploy
			synchronize_changes_with_remote_repository
			build = Perpetuus::Build.new
  		if build.builded_with_success?
  			puts "Build Success!".green
  			puts "Remote url: #{build.git_remote_url}"
  		else
  			puts "Build Fail!".red
  			puts "Your code can't be deployed!"
  			puts "Check the status at https://travis-ci.org/#{build.username}/#{build.repository}"
  			puts build.last_build
  			return false
  		end
  		Perpetuus.push_to_heroku
		end

		private

		def ask_wizard(question, label)
			ask "\033[1m\033[30m\033[46m" + (label.upcase || "label").rjust(10) + 
			"\033[0m\033[36m" + "  #{question}\033[0m"
		end

		def synchronize_changes_with_remote_repository
			git_pull unless all_up_to_date?
			git_push unless nothing_to_commit?
		end

		def all_up_to_date?
			`git pull`.include? "Already up-to-date"
		end

		def nothing_to_commit?
			`git status`.include? "nothing to commit"
		end

		def git_pull
			system "git pull"
		end

		def git_push
			system "git push"
		end

	end
end