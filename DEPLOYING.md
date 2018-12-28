# Deploying

## Prerequisites

Login to heroku with your credentials:

```` sh
heroku login
````

## Setting Up Servers from Scratch

In addition to the steps below, for each environment, set an environment variable called `DATABASE_URL`,
  the value of which should reflect the environment's `CLEARDB_DATABASE_URL`,
  except it should use `mysql2:` instead of `mysql:`.

### Staging

```` sh
heroku create next-train-staging
heroku git:remote -a next-train-staging
git remote rename heroku heroku-staging
heroku config:set BUNDLE_WITHOUT="development:test:docs" -a next-train-staging
heroku config:set GTFS_SOURCE_URL="http://www.shorelineeast.com/google_transit.zip" -a next-train-staging
heroku config:set MAILER_HOST="next-train-staging.herokuapp.com" -a next-train-staging
heroku config:set ADMIN_EMAIL="someone@gmail.com" -a next-train-staging
heroku addons:create cleardb:ignite -a next-train-staging
heroku addons:create sendgrid:starter -a next-train-staging
heroku addons:create scheduler:standard -a next-train-staging
````

### Production

```` sh
heroku create next-train-production
heroku git:remote -a next-train-production
git remote rename heroku heroku-production
heroku config:set BUNDLE_WITHOUT="development:test:docs" -a next-train-production
heroku config:set GTFS_SOURCE_URL="http://www.shorelineeast.com/google_transit.zip" -a next-train-production
heroku config:set MAILER_HOST="next-train-production.herokuapp.com" -a next-train-production
heroku config:set ADMIN_EMAIL="someone@gmail.com" -a next-train-production
heroku addons:create cleardb:ignite -a next-train-production
heroku addons:create sendgrid:starter -a next-train-production
heroku addons:create scheduler:standard -a next-train-production
````

## Deploying

Deploy from master branch:

```` sh
git push heroku-staging master
git push heroku-production master
````

Deploy from a different branch:

```` sh
git push heroku-staging my-branch:master
git push heroku-production my-branch:master
````

## Scheduled Jobs

Both production and staging environment should schedule the following tasks:

task | frequency
--- | ---
`rake gtfs:import` | once per hour
