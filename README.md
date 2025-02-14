[![Maintainability](https://api.codeclimate.com/v1/badges/bd4ed58b6b08523b837a/maintainability)](https://codeclimate.com/github/TallerWebSolutions/flow_climate/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/bd4ed58b6b08523b837a/test_coverage)](https://codeclimate.com/github/TallerWebSolutions/flow_climate/test_coverage)
![FlowClimateBuild](https://github.com/TallerWebSolutions/flow_climate/workflows/FlowClimateBuild/badge.svg)
[![sponsored by Taller](https://raw.githubusercontent.com/TallerWebSolutions/tallerwebsolutions.github.io/master/sponsored-by-taller.png)](https://taller.net.br/en/)

<p align="center">
# Flow Climate
</p>
<p align="center">
  <img src="https://img.shields.io/static/v1?logo=Ruby&label=&message=Ruby&color=111&logoColor=d20002&style=flat-square" />
  <img src="https://img.shields.io/static/v1?logo=GraphQL&label=&message=GraphQL&color=111&logoColor=DD34A6&style=flat-square" />
  <img src="https://img.shields.io/static/v1?logo=postgresql&label=&message=PostgreSQL&color=111&logoColor=31648C&style=flat-square" />
   <img src="https://img.shields.io/static/v1?logo=TypeScript&label=&message=TypeScript&color=111&logoColor=2F73BF&style=flat-square" />
</p>

Bringing the management to the next level.

Have the ultimate management tools in your hands!

## Using:

- Sendgrid to send emails
- Rollbar to monitor production errors
- RSpec as test framework
- Fabrication as factory for specs
- Faker to generate fake data
- Devise for authentication
- Rubocop for linting
- PostgreSQL
- React
- GraphQL
- Material UI - https://v5-0-6.mui.com/customization/default-theme/

## How to build the environment

- Install PostgreSQL v. 13.3
- Install ImageMagick `brew install imagemagick` or `apt install imagemagick`
- Configure pgsql
    - Start postgresql
        - Example on macOS (brew instalation): `pg_ctl -D /usr/local/var/postgres start`
    - psql postgres
    - run `CREATE USER postgres SUPERUSER;`
    - run `CREATE DATABASE postgres WITH OWNER postgres;`
    - run `\password postgres` and define _postgres_ as user password;
- Check `config/database.yml` for further information
- You may need to install the `lipq-dev` on Linux environments
    - `sudo apt install postgresql libpq-dev`
- Install rvm or rbenv - the main development team is using _rvm_
- If you choose rvm then - Install the correct version (the examples will use the ruby-3.2.2)
    - `rvm install ruby-3.2.2`
        - Create the gemset to the project under the correct version
    - In the project folder run:
    - `rvm use 3.2.2@flow_climate --create`
    - `gem install bundler`
    - `bundle install`
    - copy the application.yml.example to application.yml
- In the project folder run:

    - `rake db:create`
    - `rake db:migrate`
    - `RAILS_ENV=test rake db:migrate`

- CI/CD: Github actions

    - Check [Github Actions](https://github.com/TallerWebSolutions/flow_climate/tree/develop/.github/workflows)

- The build relies on `rspec` and `rubocop` success
- In the project folder you should be able to run and check the output of:

    - `rspec`
    - `rubocop -A`

- Run console: `rails c`
- Run server: `rails s`

\*\* Local debugging for Visual Studio Code
[See this article](https://rahul-arora.medium.com/debugging-ruby-on-rails-server-in-vs-code-819b45113e78)

## Build frontend environment

Always run build for spa components.

```
cd app/spa
npm run build
```

## Troubleshoot

### fe_sendauth: no password supplied

When syncing production database this error may occur. Check the following:

- /var/lib/pgsql/data/pg_hba.conf (may be another path in your OS) is set to use md5 in local and 127.0.0.1/32
- You have a postgres user with the same name as your OS user and all privileges.
- You have a password file in your home directory. https://www.postgresql.org/docs/current/libpq-pgpass.html

### NameError: uninitialized constant Jira - in LOCAL environment

Generate a new token at https://id.atlassian.com/manage-profile/security/api-tokens

Update the corresponding Jira::JiraAccount with the new token in the field `api_token`

## Docker development useful commands

### Start the development environment
- `docker compose up`

### Stop the development environment
- `docker compose down`

### Open a shell in the web container
- `docker compose exec web bash`

### Open a psql shell in the database container
- `docker compose exec db psql -U postgres -d flowcontrol_development`

### Restore the database from Heroku
- `heroku pg:backups:capture --app flowclimateapp` - to capture the database
- `heroku pg:backups:download --app flowclimateapp` - to download the database
- `docker compose down` - to stop the development environment
- `docker compose up -d db` - to start the database container
- `docker compose exec db dropdb -U postgres flowcontrol_development --if-exists` - to drop the database
- `docker compose exec db createdb -U postgres flowcontrol_development` - to create the database
- `docker compose cp latest.dump db:/tmp/latest.dump` - to copy the dump to the container
- `docker compose exec db pg_restore -U postgres -d flowcontrol_development /tmp/latest.dump` - to restore the database
- `docker compose up -d` - to start the development environment
- `docker compose run web rails db:migrate` - to run and apply pending migrations
