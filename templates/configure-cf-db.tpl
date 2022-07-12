#!/bin/bash

# Create database extensions
# Note: this can be run as many times as needed, the CREATE command is ignored if the extension
#       already exists.

set -x


psql "postgres://${master_username}:${master_password}@${host}/postgres"  -c "CREATE USER ${uaa_username} WITH CREATEDB CREATEROLE PASSWORD '${uaa_password}';"
psql "postgres://${master_username}:${master_password}@${host}/postgres"  -c "CREATE USER ${credhub_username} WITH CREATEDB CREATEROLE PASSWORD '${credhub_password}';"
psql "postgres://${master_username}:${master_password}@${host}/postgres"  -c "CREATE USER ${cloud_controller_username} CREATEDB CREATEROLE PASSWORD '${cloud_controller_password}';"
psql "postgres://${master_username}:${master_password}@${host}/postgres"  -c "CREATE USER ${diego_username} CREATEDB CREATEROLE PASSWORD '${diego_password}';"
psql "postgres://${master_username}:${master_password}@${host}/postgres"  -c "CREATE USER ${network_connectivity_username} CREATEDB CREATEROLE PASSWORD '${network_connectivity_password}';"
psql "postgres://${master_username}:${master_password}@${host}/postgres"  -c "CREATE USER ${network_policy_username} CREATEDB CREATEROLE PASSWORD '${network_policy_password}';"
psql "postgres://${master_username}:${master_password}@${host}/postgres"  -c "CREATE USER ${locket_username} CREATEDB CREATEROLE PASSWORD '${locket_password}';"
psql "postgres://${master_username}:${master_password}@${host}/postgres"  -c "CREATE USER ${routing_api_username} CREATEDB CREATEROLE PASSWORD '${routing_api_password}';"



psql "postgres://${uaa_username}:${uaa_password}@${host}/postgres"                                   -c "CREATE DATABASE uaa;"
psql "postgres://${credhub_username}:${credhub_password}@${host}/postgres"                           -c "CREATE DATABASE credhub ;"
psql "postgres://${cloud_controller_username}:${cloud_controller_password}@${host}/postgres"         -c "CREATE DATABASE cloud_controller ;"
psql "postgres://${diego_username}:${diego_password}@${host}/postgres"                               -c "CREATE DATABASE diego;"
psql "postgres://${network_connectivity_username}:${network_connectivity_password}@${host}/postgres" -c "CREATE DATABASE network_connectivity;"
psql "postgres://${network_policy_username}:${network_policy_password}@${host}/postgres"             -c "CREATE DATABASE network_policy;"
psql "postgres://${locket_username}:${locket_password}@${host}/postgres"                             -c "CREATE DATABASE locket;"
psql "postgres://${routing_api_username}:${routing_api_password}@${host}/postgres"                   -c 'CREATE DATABASE "routing-api";'


psql "postgres://${master_username}:${master_password}@${host}/uaa"                    -c "CREATE EXTENSION IF NOT EXISTS citext;"
psql "postgres://${master_username}:${master_password}@${host}/credhub"                -c "CREATE EXTENSION IF NOT EXISTS citext;"
psql "postgres://${master_username}:${master_password}@${host}/cloud_controller"       -c "CREATE EXTENSION IF NOT EXISTS citext;"
psql "postgres://${master_username}:${master_password}@${host}/diego"                  -c "CREATE EXTENSION IF NOT EXISTS citext;"
psql "postgres://${master_username}:${master_password}@${host}/network_connectivity"   -c "CREATE EXTENSION IF NOT EXISTS citext;"
psql "postgres://${master_username}:${master_password}@${host}/network_policy"         -c "CREATE EXTENSION IF NOT EXISTS citext;"
psql "postgres://${master_username}:${master_password}@${host}/locket"                 -c "CREATE EXTENSION IF NOT EXISTS citext;"
psql "postgres://${master_username}:${master_password}@${host}/routing-api"            -c "CREATE EXTENSION IF NOT EXISTS citext;"


psql "postgres://${master_username}:${master_password}@${host}/uaa"                  -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
psql "postgres://${master_username}:${master_password}@${host}/credhub"              -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
psql "postgres://${master_username}:${master_password}@${host}/cloud_controller"     -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
psql "postgres://${master_username}:${master_password}@${host}/diego"                -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
psql "postgres://${master_username}:${master_password}@${host}/network_connectivity" -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
psql "postgres://${master_username}:${master_password}@${host}/network_policy"       -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
psql "postgres://${master_username}:${master_password}@${host}/locket"               -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
psql "postgres://${master_username}:${master_password}@${host}/routing-api"          -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"


psql "postgres://${uaa_username}:${uaa_password}@${host}/uaa"                                                     -c "SELECT 1;"
psql "postgres://${credhub_username}:${credhub_password}@${host}/credhub"                                         -c "SELECT 1;"
psql "postgres://${cloud_controller_username}:${cloud_controller_password}@${host}/cloud_controller"              -c "SELECT 1;"
psql "postgres://${diego_username}:${diego_password}@${host}/diego"                                               -c "SELECT 1;"
psql "postgres://${network_connectivity_username}:${network_connectivity_password}@${host}/network_connectivity"  -c "SELECT 1;"
psql "postgres://${network_policy_username}:${network_policy_password}@${host}/network_policy"                    -c "SELECT 1;"
psql "postgres://${locket_username}:${locket_password}@${host}/locket"                                            -c "SELECT 1;"
psql "postgres://${routing_api_username}:${routing_api_password}@${host}/routing-api"                             -c "SELECT 1;"


