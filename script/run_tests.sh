#!/bin/bash

bundle exec rake db:migrate:reset && \
bundle exec rake db:seed && \
bundle exec rake ts:configure && \
bundle exec rake ts:index && \
bundle exec rspec --format d --format html --out tmp/rspec.html spec/ && \
bundle exec cucumber features
exit $?
