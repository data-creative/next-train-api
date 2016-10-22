source 'https://rubygems.org'

ruby "2.2.3"

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'mysql2', '>= 0.3.18', '< 0.5'
gem 'puma', '~> 3.0'
#gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0' # heroku needs this
#gem 'coffee-rails', '~> 4.2'
# gem 'therubyracer', platforms: :ruby
#gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem

gem 'jquery-rails' # heroku needs this
gem 'turbolinks', '~> 5' # heroku needs this
gem 'jbuilder', '~> 2.5'

group :development, :test do
  gem 'pry'
  gem 'rspec-rails', '~> 3.5'
  gem 'factory_girl_rails', '~> 4.0'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  #gem 'web-console'
  gem 'listen', '~> 3.0.5' # dev webserver needs this
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  #gem 'spring'
  #gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'yard', group: :docs # run `bundle exec yard doc` to parse comments and/or `bundle exec yard server` to view documentation at *localhost:8808*
