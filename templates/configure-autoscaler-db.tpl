#!/bin/bash

# Create database extensions
# Note: this can be run as many times as needed, the CREATE command is ignored if the extension
#       already exists.

set -x

psql "postgres://${master_username}:${master_password}@${host}/postgres"                 -c "CREATE USER ${autoscaler_username} WITH CREATEDB CREATEROLE PASSWORD '${autoscaler_password}';"

psql "postgres://${autoscaler_username}:${autoscaler_password}@${host}/postgres"         -c "CREATE DATABASE autoscaler;"

psql "postgres://${master_username}:${master_password}@${host}/autoscaler"               -c "CREATE EXTENSION IF NOT EXISTS citext;"

psql "postgres://${master_username}:${master_password}@${host}/autoscaler"               -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"

psql "postgres://${autoscaler_username}:${autoscaler_password}@${host}/autoscaler"       -c "SELECT 1;"
