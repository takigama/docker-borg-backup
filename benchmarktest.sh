#!/bin/bash

export BORG_PASSPHRASE=test

borg init --encryption repokey /tmp/test
borg benchmark crud /tmp/test /tmp/test
