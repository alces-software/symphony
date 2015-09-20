#!/bin/bash
hosttype=$1
if [ -z $hosttype ]; then
  echo "Please set hosttype!" >&2
  exit 1
fi

find $hosttype/ -type f | sed -e "s|^$hosttype/||g" | while read f; do echo "/$f ----> $f"; cp -v /$f ../$hosttype/$f; done
