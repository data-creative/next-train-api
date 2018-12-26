source 'https://rubygems.org'

ruby "2.2.3"

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'mysql2', '>= 0.3.18', '< 0.5'
gem 'puma', '~> 3.0'
gem 'uglifier', '>= 1.3.0' # heroku needs this
gem 'jquery-rails' # heroku needs this
gem 'turbolinks', '~> 5' # heroku needs this
gem 'jbuilder', '~> 2.5'

#gem 'devise_token_auth'
#gem 'omniauth' # for future use with devise_token_auth
gem 'devise', '~> 4.2.0'
gem 'httparty', '~> 0.13.3'
gem 'rubyzip', '>= 1.0.0'

gem 'yard', group: :docs # run `bundle exec yard doc` to parse comments and/or `bundle exec yard server` to view documentation at *localhost:8808*

group :development, :test do
  gem 'pry'
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 3.5'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'capybara', '~> 2.10.1'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'webmock', '~> 2.3.1'
end

group :development do
  gem 'listen', '~> 3.0.5' # dev webserver needs this
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  #gem 'spring'
  #gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem "timecop"
  gem "simplecov", "~> 0.16"
  gem "simplecov-console", "~> 0.4"
end
