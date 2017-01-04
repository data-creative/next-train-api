# Contributing

## Development Environment Setup

### Prerequisites

Install dependencies for a Ruby on Rails application:

 + `ruby` (install via rbenv the version specified in the Gemfile)
 + `bundler`
 + `rails`
 + `mysql`
 + `mailcatcher`

### Installation

Obtain source code:

```` sh
git clone git@github.com:data-creative/next-train.git
cd next-train
````

Install gem dependencies.

```` sh
bundle install --without production
````

### Database

Create database user:

```` sh
mysql -uroot -p
mysql> CREATE USER 'next_train'@'localhost' IDENTIFIED BY 'next_train';
mysql> GRANT ALL ON *.* to 'next_train'@'localhost';
mysql> exit
````

Create database:

```` sh
bundle exec rake db:create
bundle exec rake db:migrate
````

Populate database:

```` sh
bundle exec rake db:seed
bundle exec rake gtfs:import
````

### Webserver

Start development web server:

```` sh
rails s
````

Then view in browser at [localhost:3000](localhost:3000).

### Console

Start development console:

```` sh
rails c
````

## Testing

Prepare test environment database:

```` sh
bundle exec rake db:test:prepare
````

Run tests:

```` sh
bundle exec rspec spec/
````
