require 'thor'

module Perpetuus
	class Command < Thor
		include Thor::Actions
		
		desc "setup", "Setup a new rails app ready to deploy in heroku"
		def setup
			@rails_app_name = ask_wizard("What's the name of rails project?", "rails")
			puts "CREATING RAILS APP...".green
			Perpetuus.new_rails_app(@rails_app_name)
			Perpetuus.setup_git_repository(@rails_app_name)
			unless (system "heroku create #{@heroku_app_name}")
				@heroku_app_name = ask_wizard("What's the app name?", "heroku")
			end
			system "git push heroku master"
		end

		desc "", ""
		def deploy
			
		end

		private

		def ask_wizard(question, label)
			ask "\033[1m\033[30m\033[46m" + (label.upcase || "label").rjust(10) + 
			"\033[0m\033[36m" + "  #{question}\033[0m"
		end

	end
end