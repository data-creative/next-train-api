# Authentication

## Developer Accounts

### Installation

Add `gem 'devise'` to *Gemfile*, then:

```` sh
bundle install
rails generate devise:install
````

### Configuration

Follow post-installation instructions:

```` txt
Some setup you must do manually if you haven't yet:

  1. Ensure you have defined default url options in your environments files. Here
     is an example of default_url_options appropriate for a development environment
     in config/environments/development.rb:

       config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

     In production, :host should be set to the actual host of your application.

  2. Ensure you have defined root_url to *something* in your config/routes.rb.
     For example:

       root to: "home#index"

  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

  4. You can copy Devise views (for customization) to your app by running:

       rails g devise:views
````

Configure email settings, using `mailcatcher` in development and `sendgrid` in heroku production:

```` rb
# config/environments/development.rb

config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

# Send mail through smtp://localhost:1025 for 'mailcatcher' gem.
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {:address => "localhost", :port => 1025}
````

```` rb
# config/environments/production.rb

config.action_mailer.default_url_options = { host: 'next-train-production.herokuapp.com' }

# Send mail through sendgrid smtp on production.
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
 :address        => 'smtp.sendgrid.net',
 :port           => '587',
 :authentication => :plain,
 :user_name      => ENV['SENDGRID_USERNAME'], # set by sendgrid heroku addon
 :password       => ENV['SENDGRID_PASSWORD'], # set by sendgrid heroku addon
 :domain         => 'heroku.com',
 :enable_starttls_auto => true
}
````

```` rb
# config/environments/test.rb

config.action_mailer.default_url_options = { :host => 'localhost' }
````

### Generation

```` sh
rails generate devise developers
rails generate devise:controllers developers
rails generate devise:views developers
````
