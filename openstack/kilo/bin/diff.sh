#!/bin/bash
cd /var/lib/symphony/openstack/kilo/
hosttype=$1
if [ -z $hosttype ]; then
  echo "Please set hosttype!" >&2
  exit 1
fi

find $hosttype/ -type f | sed -e "s|^$hosttype/||g" | while read f; do echo "/$f ----> $f"; diff -uNr /$f $hosttype/$f; done
