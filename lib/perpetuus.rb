require 'perpetuus/version'
require 'perpetuus/build'
require 'perpetuus/command'
require 'colored'

module Perpetuus

  def self.setup
  	setup_rails_app
  	setup_git_repository
  	setup_heroku_app
  	puts "APP #{@rails_app_name} CREATED WITH SUCCESS!".green
  end

  def self.deploy_to_heroku
  	build = Perpetuus::Build.new
  	unless build.builded_with_success?
  		puts "Build Fail!".red
  		return false
  	end
  	push_to_heroku
  end

  def self.setup_git_repository(app_name)
  	system 'cd #{app_name}'
  	print "[GIT]".white_on_blue
  	puts "\tINITIALIZING GIT REPOSITORY...".green
  	system 'git init'
  	system 'git add .'
  	system 'git commit -m "Initial commit."'
  end

  def self.setup_heroku_app
  	unless system('heroku create #{@heroku_app_name}')
  		show_message("heroku", "give a name to heroku project")
  		@heroku_app_name = gets.strip.chomp
  	end
  	print "DEPLOYING HEROKU APP...\n".green
  	system 'git push heroku master'
  end

  def self.show_message(question_label, question_text)
  	print(("[" + question_label.upcase + "]").white_on_red)
  	puts("\t" + question_text.upcase.yellow)
  end

  def self.push_to_heroku(branch="master")
		system "git push heroku #{branch}"
	end

  def self.new_rails_app(name)
  	system "rails new #{name} -T"
  end
end