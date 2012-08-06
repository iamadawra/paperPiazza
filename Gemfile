source 'https://rubygems.org'

# Lets us see if a gem is installed
def gem_available?(name)
   Gem::Specification.find_by_name(name)
rescue Gem::LoadError
   false
rescue
   Gem.available?(name)
end

gem 'rails', '3.2.2'

gem 'will_paginate', '3.0'

gem "handles_sortable_columns"

gem 'activerecord-postgresql-adapter'

if gem_available?('pg')
  gem 'pg'
end

group :darwin do
    gem 'rb-inotify', :require => false
end

# Mini controllers for subviews
gem 'cells'

#Forum Gem
gem 'forum_monster'

# Authentication (has_secure_password)
gem 'bcrypt-ruby', '~> 3.0.0', :require => 'bcrypt'

gem 'ajaxful_rating', :git => 'git://github.com/edgarjs/ajaxful-rating.git', :branch => "rails3"


# Authorization
gem 'cancan'

# Time parsing
gem 'timeliness'

# Allows us to override validation error messages
gem 'custom_error_message', :git => 'git://github.com/arjun810/custom-err-msg.git'

# Required for processing questions. Note that you still need pandoc installed.
gem 'pandoc-ruby'

gem 'thin'

# Will want this again at some point for video chat.
#gem 'opentok'

# Comments
gem 'acts_as_commentable_with_threading'
# Gets our custom version in case things break.
#gem 'acts_as_commentable_with_threading', :git => 'https://github.com/arjun810/acts_as_commentable_with_threading.git'

# Tags
gem 'acts-as-taggable-on', '~> 2.2.2'

# Voting
gem 'thumbs_up'
# Gets our custom version in case things break.
#gem 'thumbs_up', :git => 'https://github.com/arjun810/thumbs_up.git'

# Lets us dump databases as YAML, convenient for getting production data into dev.
gem 'yaml_db'

# For deployment
gem 'capistrano'

gem 'haml'
gem 'haml-rails'
gem 'jquery-rails'

gem 'sass-rails',     '~> 3.2.3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do

  gem 'compass', '0.12'
  gem 'compass-rails', '1.0.0'

  gem 'bootstrap-sass'#, :git => 'https://github.com/thomas-mcdonald/bootstrap-sass.git', :branch => "2.0.2"#'~> 2.0.1'
  gem 'font-awesome-sass-rails'

  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'

end

group :development do
  # Refresh browser on save
  gem 'awesome_print'
  gem 'rack-livereload'
  gem 'guard-livereload'

  # Autorun tests on save
  gem 'guard-rspec'

  # Restart server when config changes
  if gem_available?('guard-rails')
    gem 'guard-rails'
  end

  # Faster than webrick and doesn't have annoying spam
  #gem 'thin'

  # For debugging
  gem 'pry'

  # Annotate models with schema info
  gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'

  # Color coding in irb and stuff
  gem 'brice'

  gem "rails-erd"
end

group :development, :test do
  gem 'sqlite3'
  # Allow for using pg if installed, but don't require.
  if gem_available?('pg')
    gem 'pg'
  end
  gem 'rspec-rails'
end

group :test do

  gem 'simplecov', :require => false

  # Instead of fixtures
  gem 'factory_girl_rails', :require => false

  # Simulate browser
  gem 'capybara'

  gem 'guard-spork', '0.3.2'
  gem 'spork', '0.9.0'

  gem 'launchy'

  #if gem_available?('rb-fsevent')
  #  gem 'rb-fsevent', '0.4.3.1', :require => false
  #end
  if gem_available?('growl')
    gem 'growl', '1.0.3'
  end

  if gem_available?('rb-inotify')
    gem 'rb-inotify'
  end

  if gem_available?('libnotify')
    gem 'libnotify'
  end

  # For changing the time in specs
  gem 'timecop'

  gem 'database_cleaner'

  if gem_available?('capybara-webkit')
    gem 'capybara-webkit'
  end
end

group :production do
  # We use gem_available? to allow dev machines to not require pg.
  # It's preferred that you use postgres, though.
  if gem_available?('pg')
    gem 'pg'
  end
end
