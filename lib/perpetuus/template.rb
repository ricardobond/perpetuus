initializer 'generators.rb', <<-RUBY
Rails.application.config.generators do |g|
end
RUBY

@recipes = ["activerecord", "git", "heroku", "rspec"] 

def recipes; @recipes end
def recipe?(name); @recipes.include?(name) end

def say_custom(tag, text); say "\033[1m\033[36m" + tag.to_s.rjust(10) + "\033[0m" + "  #{text}" end
def say_recipe(name); say "\033[1m\033[36m" + "recipe".rjust(10) + "\033[0m" + "  Running #{name} recipe..." end
def say_wizard(text); say_custom(@current_recipe || 'wizard', text) end

def ask_wizard(question)
  ask "\033[1m\033[30m\033[46m" + (@current_recipe || "prompt").rjust(10) + "\033[0m\033[36m" + "  #{question}\033[0m"
end

def yes_wizard?(question)
  answer = ask_wizard(question + " \033[33m(y/n)\033[0m")
  case answer.downcase
    when "yes", "y"
      true
    when "no", "n"
      false
    else
      yes_wizard?(question)
  end
end

def no_wizard?(question); !yes_wizard?(question) end

def multiple_choice(question, choices)
  say_custom('question', question)
  values = {}
  choices.each_with_index do |choice,i| 
    values[(i + 1).to_s] = choice[1]
    say_custom (i + 1).to_s + ')', choice[0]
  end
  answer = ask_wizard("Enter your selection:") while !values.keys.include?(answer)
  values[answer]
end

@current_recipe = nil
@configs = {}

@after_blocks = []
def after_bundler(&block); @after_blocks << [@current_recipe, block]; end
@after_everything_blocks = []
def after_everything(&block); @after_everything_blocks << [@current_recipe, block]; end
@before_configs = {}
def before_config(&block); @before_configs[@current_recipe] = block; end



# >-----------------------------[ ActiveRecord ]------------------------------<

@current_recipe = "activerecord"
@before_configs["activerecord"].call if @before_configs["activerecord"]
say_recipe 'ActiveRecord'

config = {}
config['database'] = multiple_choice("Which database are you using?", [["MySQL", "mysql"], ["Oracle", "oracle"], ["PostgreSQL", "postgresql"], ["SQLite", "sqlite3"], ["Frontbase", "frontbase"], ["IBM DB", "ibm_db"]]) if true && true unless config.key?('database')
config['auto_create'] = yes_wizard?("Automatically create database with default configuration?") if true && true unless config.key?('auto_create')
@configs[@current_recipe] = config

if config['database']
  say_wizard "Configuring '#{config['database']}' database settings..."
  old_gem = gem_for_database
  @options = @options.dup.merge(:database => config['database'])
  gsub_file 'Gemfile', "gem '#{old_gem}'", "gem '#{gem_for_database}'"
  template "config/databases/#{@options[:database]}.yml", "config/database.yml.new"
  run 'mv config/database.yml.new config/database.yml'
end

after_bundler do
  rake "db:create:all" if config['auto_create']
end


# >----------------------------------[ Git ]----------------------------------<

@current_recipe = "git"
@before_configs["git"].call if @before_configs["git"]
say_recipe 'Git'


@configs[@current_recipe] = config

after_everything do
  git :init
  git :add => '.'
  git :commit => '-m "Initial import."'
end


# >--------------------------------[ Heroku ]---------------------------------<

@current_recipe = "heroku"
@before_configs["heroku"].call if @before_configs["heroku"]
say_recipe 'Heroku'

config = {}
config['create'] = yes_wizard?("Automatically create appname.heroku.com?") if true && true unless config.key?('create')
config['staging'] = yes_wizard?("Create staging app? (appname-staging.heroku.com)") if config['create'] && true unless config.key?('staging')
config['domain'] = ask_wizard("Specify custom domain (or leave blank):") if config['create'] && true unless config.key?('domain')
config['deploy'] = yes_wizard?("Deploy immediately?") if config['create'] && true unless config.key?('deploy')
@configs[@current_recipe] = config

heroku_name = app_name.gsub('_','')

after_everything do
  if config['create']
    say_wizard "Creating Heroku app '#{heroku_name}.heroku.com'"  
    while !system("heroku create #{heroku_name}")
      heroku_name = ask_wizard("What do you want to call your app? ")
    end
  end

  if config['staging']
    staging_name = "#{heroku_name}-staging"
    say_wizard "Creating staging Heroku app '#{staging_name}.heroku.com'"
    while !system("heroku create #{staging_name}")
      staging_name = ask_wizard("What do you want to call your staging app?")
    end
    git :remote => "rm heroku"
    git :remote => "add production git@heroku.com:#{heroku_name}.git"
    git :remote => "add staging git@heroku.com:#{staging_name}.git"
    say_wizard "Created branches 'production' and 'staging' for Heroku deploy."
  end

  unless config['domain'].blank?
    run "heroku addons:add custom_domains"
    run "heroku domains:add #{config['domain']}"
  end

  git :push => "#{config['staging'] ? 'staging' : 'heroku'} master" if config['deploy']
end


# >---------------------------------[ RSpec ]---------------------------------<

@current_recipe = "rspec"
@before_configs["rspec"].call if @before_configs["rspec"]
say_recipe 'RSpec'


@configs[@current_recipe] = config

gem 'rspec-rails', '>= 2.0.1', :group => [:development, :test]

inject_into_file "config/initializers/generators.rb", :after => "Rails.application.config.generators do |g|\n" do
  "    g.test_framework = :rspec\n"
end

after_bundler do
  generate 'rspec:install'
end





@current_recipe = nil

# >-----------------------------[ Run Bundler ]-------------------------------<

say_wizard "Running Bundler install. This will take a while."
run 'bundle install'
say_wizard "Running after Bundler callbacks."
@after_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}

@current_recipe = nil
say_wizard "Running after everything callbacks."
@after_everything_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}