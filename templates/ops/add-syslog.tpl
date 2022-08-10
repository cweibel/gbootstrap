
---
addons:
- name: syslog
  include:
    stemcell:
    - os: ubuntu-jammy
    - os: ubuntu-bionic
  jobs:
  - name: syslog_forwarder
    release: syslog
    properties:
      syslog:
        address: pcikles.elb.us-east-1.amazonaws.com
        port: 6514
        respect_file_permissions: false
        transport: tcp

- name: syslog
  include:
    stemcell:
    - os: windows2019
  jobs:
  - name: syslog_forwarder_windows
    release: windows-syslog
    properties:
      syslog:
        address: pickles.elb.us-east-1.amazonaws.com
        port: 6514
        respect_file_permissions: false
        transport: tcp

releases:
- name: "syslog"
  version: "11.7.9"
  url: "https://bosh.io/d/github.com/cloudfoundry/syslog-release?v=11.7.9"
  sha1: "1648c63555532c713793e13eb8a735fae4a92d7d"

- name: "windows-syslog"
  version: "1.1.6"
  url: "https://bosh.io/d/github.com/cloudfoundry/windows-syslog-release?v=1.1.6"
  sha1: "eeb2f3ab5f985a5e9ccf6e88977b0e20b0163595"