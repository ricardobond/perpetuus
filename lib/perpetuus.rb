require 'perpetuus/version'
require 'perpetuus/build'
require 'perpetuus/command'
require 'colored'

module Perpetuus

  def self.push_to_heroku(branch="master")
		system "git push heroku #{branch}"
	end

  def self.new_rails_app(name)
  	system "rails new #{name} -m http://railswizard.org/004803ab3742bc49840c.rb -T"
  end
end