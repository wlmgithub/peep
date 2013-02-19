#!/bin/sh
exec scala -savecompiled "$0" "$@"
!#

println("hello world")
