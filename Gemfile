source 'http://rubygems.org'
ruby '2.0.0'
gem 'rails', '3.2.13'
#ruby-gemset=manjapra

gem 'blacklight'
gem 'hydra-head', '~> 6.0.0'
#gem 'tuftsification-hydra', :git => 'git@github.com:TuftsUniversity/tuftsification-hydra.git'
#gem 'tuftsification-hydra', :git => 'https://github.com/TuftsUniversity/tuftsification-hydra.git'
#gem 'tuftsification-hydra', :path => '/Users/smcdon08/Devel/dl/tuftsification-hydra'
gem 'tuftsification-hydra', :path => '/Users/mkorcy01/Documents/workspace/tuftsification-hydra'
gem "active-fedora", "~> 6.4.0"
gem 'om', "~> 3.0.0"
gem 'hydra-role-management'
gem 'delayed_job_active_record'

# We will assume that you're using sqlite3 for testing/demo,
# but in a production setup you probably want to use a real sql database like mysql or postgres
gem 'sqlite3'

# Rails uses asset pipeline.  You will need these gems for used your assets in development.
# However, you won't need them in production because they will be precompiled.
group :assets do
   gem 'sass-rails', '~> 3.2.3'
   gem 'jquery-rails'
   gem 'uglifier'
end

# You will probably want to use these to run the tests you write for your hyd   ra head
# For testing with rspec
group :development, :test do
   gem 'rspec-rails'
   gem 'jettywrapper'
end
group :tdldev do
  gem 'therubyracer'
  gem 'mysql2'
  gem 'activerecord-mysql-adapter'

end

gem "unicode", :platforms => [:mri_18, :mri_19]
gem "devise"
gem "devise-guests", "~> 0.3"
gem "bootstrap-sass"

gem "rails_admin"
gem 'rack-google-analytics', :require => 'rack/google-analytics'
