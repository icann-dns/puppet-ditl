[![Build Status](https://travis-ci.org/icann-ditl/puppet-ditl.svg?branch=master)](https://travis-ci.org/icann-ditl/puppet-ditl)
[![Puppet Forge](https://img.shields.io/puppetforge/v/icann/ditl.svg?maxAge=2592000)](https://forge.puppet.com/icann/ditl)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/icann/ditl.svg?maxAge=2592000)](https://forge.puppet.com/icann/ditl)
# ditl

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with ditl](#setup)
    * [What ditl affects](#what-ditl-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ditl](#beginning-with-ditl)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module installs ditl and can also manage the custom scripts, host script and custom modules directories

## Setup

### What ditl affects

* installs ssh key to the root user 
* install a bash sctip to upload bcaps
* install a cron job to upload bcaps

### Setup Requirements

* puppetlabs-stdlib 4.12.0
* icann-tea 0.2.4

### Beginning with ditl

just add the ditl class

```puppet
class {'::ditl' }
```

## Usage

### Add custom modules and scripts

You can pass URI's which will be handed to puppet and passed to a file type source parameter.

```puppet
class {'::ditl' 
  hosts_script => 'puppet:///modules/submodule/my_ditl_scripts,
  scripts => 'puppet:///modules/submodule/my_ditl_scripts,
  modules => 'puppet:///modules/submodule/my_ditl_modules,
}
```

of with hiera

```yaml
ditl::hosts_script: 'puppet:///modules/submodule/my_ditl_scripts,
ditl::scripts: 'puppet:///modules/submodule/my_ditl_scripts,
ditl::modules: 'puppet:///modules/submodule/my_ditl_modules,
```

## Reference

### Classes

#### Public Classes

* [`ditl`](#class-ditl)

#### Private Classes

* [`ditl::params`](#class-ditlparams)

#### Class: `ditl`

Main class, includes all other classes

##### Parameters 

* `upload_key_source` (Tea::Puppetsource, Default: undef): This is a string which will be passed the file type source paramter to be treated as a ssh private key to use for uploads top ditl
* `upload_user` (String, Default: undef): The remote username to use for uploads
* `enabled` (Boolean Default: true): Whether to enable this module
* `pcap_dir` (Tea::Absolutepath, Default: '/opt/pcap'): The location of pcap files toupload
* `upload_host` (Tea::Fqdn, Default: capture.ditl.dns-oarc.net): The host to upload DITL data to
* `upload_key_file` (Tea::Absolutepath, Default: /root/.ssh/oarc_id_dsa): The location to stor the rsa private key
* `clean_known_hosts` (Boolean Default: false): WARNING changing this value is a security risk effectivly meaning that the upload script will trust any host fingerprint its given and therefore sceseptible to MITM attacks.  Only change this value if you know what yuo are doing

## Limitations

This module is tested on Ubuntu 12.04, and 14.04 and FreeBSD 10 
