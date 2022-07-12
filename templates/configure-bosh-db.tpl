#!/bin/bash

# Create database extensions
# Note: this can be run as many times as needed, the CREATE command is ignored if the extension
#       already exists.

set -x

psql "postgres://${master_username}:${master_password}@${host}/postgres"  -c "CREATE USER ${uaa_username} WITH CREATEDB CREATEROLE PASSWORD '${uaa_password}';"
psql "postgres://${master_username}:${master_password}@${host}/postgres"  -c "CREATE USER ${credhub_username} WITH CREATEDB CREATEROLE PASSWORD '${credhub_password}';"
psql "postgres://${master_username}:${master_password}@${host}/postgres"  -c "CREATE USER ${bosh_username} CREATEDB CREATEROLE PASSWORD '${bosh_password}';"

psql "postgres://${uaa_username}:${uaa_password}@${host}/postgres"         -c "CREATE DATABASE uaa;"
psql "postgres://${credhub_username}:${credhub_password}@${host}/postgres" -c "CREATE DATABASE credhub ;"
psql "postgres://${bosh_username}:${bosh_password}@${host}/postgres"       -c "CREATE DATABASE bosh ;"

psql "postgres://${master_username}:${master_password}@${host}/uaa"         -c "CREATE EXTENSION IF NOT EXISTS citext;"
psql "postgres://${master_username}:${master_password}@${host}/credhub"     -c "CREATE EXTENSION IF NOT EXISTS citext;"
psql "postgres://${master_username}:${master_password}@${host}/bosh"        -c "CREATE EXTENSION IF NOT EXISTS citext;"

psql "postgres://${master_username}:${master_password}@${host}/uaa"         -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
psql "postgres://${master_username}:${master_password}@${host}/credhub"     -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
psql "postgres://${master_username}:${master_password}@${host}/bosh"        -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"


psql "postgres://${uaa_username}:${uaa_password}@${host}/uaa"              -c "SELECT 1;"
psql "postgres://${credhub_username}:${credhub_password}@${host}/credhub"  -c "SELECT 1;"
psql "postgres://${bosh_username}:${bosh_password}@${host}/bosh"           -c "SELECT 1;"
