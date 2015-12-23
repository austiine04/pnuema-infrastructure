#!/bin/bash

set -xe

# migrate db
service postgresql start
rake db:migrate
rake db:seed
service postgresql stop

# rail secret key base
SECRET_KEY_BASE=$(rake secret)
echo "SECRET_KEY_BASE=$SECRET_KEY_BASE" >> .env

# set up front end vars depending on which are deploying to
grunt "ngconstant:$DEPLOY_ENV"
