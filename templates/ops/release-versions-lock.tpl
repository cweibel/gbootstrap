- type: replace
  path: /releases/name=app-autoscaler
  value:
    name: app-autoscaler
    version: 4.0.0
    sha1: cb4fde237c835ca736721341867420d6050ba963
    url: file:///opt/bosh/releases/app-autoscaler-release-4.0.0.tgz

- type: replace
  path: /releases/name=bpm
  value:
    name: bpm
    version: 1.1.16
    sha1: 492f181f4efa08c5f0b45d22cbe54f0a20edf99e
    url: file:///opt/bosh/releases/bpm-release-1.1.16.tgz

- type: replace
  path: /releases/name=bosh-dns-aliases
  value:
    name: bosh-dns-aliases
    version: 0.0.4
    sha1: 55b3dced813ff9ed92a05cda02156e4b5604b273
    url: file:///opt/bosh/releases/bosh-dns-aliases-release-0.0.4.tgz

- type: replace
  path: /releases/name=routing
  value:
    name: routing
    version: 0.225.0
    url: file:///opt/bosh/releases/routing-release-0.225.0.tgz
    sha1: a5b7f3b746cfa169f466c2b682db296ab8dcd0ad

- type: replace
  path: /releases/name=postgres
  value:
    name: postgres
    version: 43
    url: file:///opt/bosh/releases/postgres-release-43.tgz
    sha1: e44bbe8f8a7cdde1cda67b202e399a239d104db6

- type: replace
  path: /releases/name=loggregator-agent
  value:
    name: loggregator-agent
    version: 6.3.4
    url: file:///opt/bosh/releases/loggregator-agent-release-6.3.4.tgz
    sha1: 9dd3ad00fb49bebd8290fad8ce7b2e4992dac31f
