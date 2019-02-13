#!/usr/bin/env bash

echo "Build"
./build.sh
[ "$?" != "0" ] && echo "ERROR in conan_build" && exit 1

echo "Conan export"
./conanExport.sh
[ "$?" != "0" ] && echo "ERROR in conan_export" && exit 2