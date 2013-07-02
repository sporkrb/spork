#!/bin/sh
set -e
bundle exec rspec spec
bundle exec cucumber features
