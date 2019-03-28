#!/bin/bash -xl
bin/rails db:create
bin/rails db:environment:set RAILS_ENV=test
bin/rails db:drop db:create RAILS_ENV=test
bin/rails db:test:prepare RAILS_ENV=test || true
bin/rails db:migrate RAILS_ENV=test
