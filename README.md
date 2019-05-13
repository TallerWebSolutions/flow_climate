[![Maintainability](https://api.codeclimate.com/v1/badges/bd4ed58b6b08523b837a/maintainability)](https://codeclimate.com/github/TallerWebSolutions/flow_climate/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/bd4ed58b6b08523b837a/test_coverage)](https://codeclimate.com/github/TallerWebSolutions/flow_climate/test_coverage)
[![Build Status](https://travis-ci.org/TallerWebSolutions/flow_climate.svg?branch=develop)](https://travis-ci.org/TallerWebSolutions/flow_climate)
[![sponsored by Taller](https://raw.githubusercontent.com/TallerWebSolutions/tallerwebsolutions.github.io/master/sponsored-by-taller.png)](https://taller.net.br/en/)


# Flow Climate
Bringing the management to the next level.

Have the ultimate management tools in your hands!

## Using:
- Sendgrid to send emails
- Airbrake to monitor production errors
- RSpec as test framework
- Fabrication as factory for specs
- Faker to generate fake data

## How to build the environment

- Install rvm or rbenv - the main development team is using *rvm*
- If you choose rvm then 
    - Install the correct version (the examples will use the ruby-2.6.3)
        - `rvm install ruby-2.6.3` 
    - Create the gemset to the project under the correct version
        - In the project folder run: 
            - `rvm use 2.6.3@flow_climate --create`
            - `rvm --ruby-version use 2.6.3`
            - `gem install bundler -v 1.17.3`
            - `bundle install`
- Install PostgreSQL v. 10
- Start postgresql
    - Example on macOS (brew instalation): `pg_ctl -D /usr/local/var/postgres start`
- In the project folder run:
    - `rake db:create`
    - `rake db:migrate`
    - `rake db:create RAILS_ENV=test`
    - `rake db:migrate RAILS_ENV=test`

- CI: Travis
    - Check `travis.yml`
    
- The build relies on `rspec` and `rubocop` success
- In the project folder you should be able to run and check the output of:
    - `rspec`
    - `rubocop -DR`

- Run console: `rails c`
- Run server: `rails s`
