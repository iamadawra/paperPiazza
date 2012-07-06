set :default_environment, {
  'PATH' => "/usr/local/rvm/gems/ruby-1.9.3-p125/bin:/usr/local/rvm/gems/ruby-1.9.3-p125@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p125/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
  'RUBY_VERSION' => 'ruby-1.9.3-p125',
  'GEM_HOME'     => '/usr/local/rvm/gems/ruby-1.9.3-p125',
  'GEM_PATH'     => '/usr/local/rvm/gems/ruby-1.9.3-p125:/usr/local/rvm/gems/ruby-1.9.3-p125@global',
  'BUNDLE_PATH'  => '/usr/local/rvm/gems/ruby-1.9.3-p125/'  # If you are using bundler.
}

set :domain, 'paperpiazza.com'

role :app, domain  
role :web, domain 
role :db,  domain,  :primary => true
