applications:
  - name: apps
    memory: 1512M
    disk_quota: 1024M
    host: console
    timeout: 180
    buildpack: binary_buildpack 
    health-check-type: port
    env:
       CF_API_URL: https://${system_api_domain}
       CF_CLIENT: stratos
       CF_CLIENT_SECRET: stratos_client_secret_goes_here                                         #TODO 2
       SESSION_STORE_SECRET: totallymakingthisupsonoonecanguessitever198341575
       SSO_OPTIONS: "nosplash, logout"
       SSO_WHITELIST: "https://${stratos_domain}/*"
       SSO_LOGIN: "true"
       DB_SSL_MODE: "verify-ca"
    services:
    - console_db_tls_verify_ca