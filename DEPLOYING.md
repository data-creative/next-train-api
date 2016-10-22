# Deploying

## Setting Up Servers from Scratch

```` sh
heroku login

heroku create next-train-staging
heroku git:remote -a next-train-staging
git remote rename heroku heroku-staging
heroku config:set BUNDLE_WITHOUT="development:test:docs" -a next-train-staging

heroku create next-train-production
heroku git:remote -a next-train-production
git remote rename heroku heroku-production
heroku config:set BUNDLE_WITHOUT="development:test:docs" -a next-train-production
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
