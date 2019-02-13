#!/usr/bin/env bash

./build.sh
[ "$?" != "0" ] && echo "ERROR in conan_build" && exit 1

./conanExport.sh
[ "$?" != "0" ] && echo "ERROR in conan_export" && exit 2