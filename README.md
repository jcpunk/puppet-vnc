# vnc

Manage tigervnc now that it expects systemd-logind support.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with vnc](#setup)
    * [What vnc affects](#what-vnc-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with vnc](#beginning-with-vnc)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module manages VNC servers utilizing the new tigervnc scripts
from tigervnc 1.11 and later.

Users can optionally be given rights to restart their own servers.

## Setup

### What vnc affects

This will impact your VNC sessions, configs in /etc/tigervnc (parameter),
and policykit for systemd (if user restart is granted).

### Setup Requirements **OPTIONAL**

If you wish to use the novnc client, you must setup a webserver to point
at the websocket.

There are too may ways folks may want to setup the webserver, so no attempt
is made here to provide hooks for the websockets proxy via `httpd` or `nginx`.

If you want to use the SSL wrapper for `websockify` you are responsible to
depoy the secrets and set the parameters you need.

### Beginning with vnc

## Usage

If the defaults are workable for you, basic usage is:

```puppet
class { 'vnc::server':
  vnc_servers => {
    'userA' => {
       'comment' => 'Optional comment',
       'displaynumber' => 1,
       'user_can_manage' =>  true,
    }
}
```
Or via hiera
```yaml
vnc::server::vnc_servers:
  userA:
    comment: Optional comment
    displaynumber: 1
    user_can_manage: true
```

The most interesting parameter is `vnc::server::vnc_servers`.

It has a structure of:

```yaml
username:
  comment: (optional) comment
  displaynumber: The VNC screen, like 1, 2, 3, etc
  ensure: service ensure, default is 'running'
  enable: service enable, default is 'true'
  user_can_manage: Boolean value to permit a user to run `systemctl restart vncserver@:#.service`
                   where the `#` is their listed displaynumber.
```

Similarly, VNC clients can be loaded with:

```puppet
class { 'vnc::client::gui': }
```

## Limitations

This requires the systemd units from tigervnc 1.11+.

You must provide your own webserver to connect to websockify.

You must provide your own ssl certificates for encrypted websockets.

## Development

See the linked repo in `metadata.json`
