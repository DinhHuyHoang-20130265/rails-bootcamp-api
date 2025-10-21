#!/usr/bin/env bash

set -o errexit

bundle install
rails db:migrate:up VERSION=20251009091949