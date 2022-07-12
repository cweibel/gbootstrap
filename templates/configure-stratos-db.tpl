#!/bin/bash

# Create database extensions
# Note: this can be run as many times as needed, the CREATE command is ignored if the extension
#       already exists.

set -x


psql "postgres://${master_username}:${master_password}@${host}/postgres"                 -c "CREATE USER ${stratos_username} WITH CREATEDB CREATEROLE PASSWORD '${stratos_password}';"

psql "postgres://${stratos_username}:${stratos_password}@${host}/postgres"               -c "CREATE DATABASE console_db;"

psql "postgres://${master_username}:${master_password}@${host}/console_db"               -c "CREATE EXTENSION IF NOT EXISTS citext;"

psql "postgres://${master_username}:${master_password}@${host}/console_db"               -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
  
psql "postgres://${stratos_username}:${stratos_password}@${host}/console_db"             -c "SELECT 1;"
