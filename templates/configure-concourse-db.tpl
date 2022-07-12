#!/bin/bash

# Create database extensions
# Note: this can be run as many times as needed, the CREATE command is ignored if the extension
#       already exists.

set -x


psql "postgres://${master_username}:${master_password}@${host}/postgres"                 -c "CREATE USER ${concourse_username} WITH CREATEDB CREATEROLE PASSWORD '${concourse_password}';"

psql "postgres://${concourse_username}:${concourse_password}@${host}/postgres"           -c "CREATE DATABASE ats;"

psql "postgres://${master_username}:${master_password}@${host}/ats"                      -c "CREATE EXTENSION IF NOT EXISTS citext;"

psql "postgres://${master_username}:${master_password}@${host}/ats"                      -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
  
psql "postgres://${concourse_username}:${concourse_password}@${host}/ats"                -c "SELECT 1;"
