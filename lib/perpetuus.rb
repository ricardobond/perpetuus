require 'perpetuus/version'
require 'perpetuus/build'
require 'perpetuus/command'
require 'colored'

module Perpetuus

  def self.setup_git_repository(app_name)
  	system 'cd #{app_name}'
  	print "[GIT]".white_on_blue
  	puts "\tINITIALIZING GIT REPOSITORY...".green
  	system 'git init'
  	system 'git add .'
  	system 'git commit -m "Initial commit."'
  end

  def self.push_to_heroku(branch="master")
		system "git push heroku #{branch}"
	end

  def self.new_rails_app(name)
  	system "rails new #{name} -T"
  end
end