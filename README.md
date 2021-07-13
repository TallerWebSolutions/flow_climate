[![Maintainability](https://api.codeclimate.com/v1/badges/bd4ed58b6b08523b837a/maintainability)](https://codeclimate.com/github/TallerWebSolutions/flow_climate/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/bd4ed58b6b08523b837a/test_coverage)](https://codeclimate.com/github/TallerWebSolutions/flow_climate/test_coverage)
![FlowClimateBuild](https://github.com/TallerWebSolutions/flow_climate/workflows/FlowClimateBuild/badge.svg)
[![sponsored by Taller](https://raw.githubusercontent.com/TallerWebSolutions/tallerwebsolutions.github.io/master/sponsored-by-taller.png)](https://taller.net.br/en/)


# Flow Climate
Bringing the management to the next level.

Have the ultimate management tools in your hands!

## Using:
- Sendgrid to send emails
- Rollbar to monitor production errors
- RSpec as test framework
- Fabrication as factory for specs
- Faker to generate fake data

## How to build the environment

- Install PostgreSQL v. 13.3
- Start postgresql
    - Example on macOS (brew instalation): `pg_ctl -D /usr/local/var/postgres start`
- Check `config/database.yml` for further information
- You may need to install the `lipq-dev` on Linux environments
    - `sudo apt install postgresql libpq-dev`
- Install rvm or rbenv - the main development team is using *rvm*
- If you choose rvm then 
      - Install the correct version (the examples will use the ruby-3.0.1)
  - `rvm install ruby-3.0.1` 
      - Create the gemset to the project under the correct version
  - In the project folder run: 
  - `rvm use 3.0.1@flow_climate --create`
  - `rvm --ruby-version use 3.0.1`
  - `gem install bundler`
  - `bundle install`
- In the project folder run:
    - `rake db:create`
    - `rake db:migrate`
    - `rake db:create RAILS_ENV=test`
    - `rake db:migrate RAILS_ENV=test`

- CI/CD: Github actions
    - Check [Github Actions](https://github.com/TallerWebSolutions/flow_climate/tree/develop/.github/workflows)     
    
- The build relies on `rspec` and `rubocop` success
- In the project folder you should be able to run and check the output of:
    - `rspec`
    - `rubocop -DR`

- Run console: `rails c`
- Run server: `rails s`
