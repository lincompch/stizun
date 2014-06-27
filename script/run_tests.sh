#!/bin/bash

bundle exec rake db:migrate:reset && \
bundle exec rake db:seed && \
bundle exec rake ts:configure && \
bundle exec rake ts:generate && \
bundle exec rspec --format d --format html --out tmp/rspec.html spec/ && \
bundle exec cucumber features

if [[ -f tmp/rerun.txt && -s tmp/rerun.txt && $? -ne 0 ]]; then
  echo "Rerun necessary, the first execution exited with non-0."
  bundle exec cucumber -p rerun
fi

exit $?
