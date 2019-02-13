#!/usr/bin/env bash

echo "INFO: VSTSBUILD_DEBUG=$VSTSBUILD_DEBUG"

if [ "$VSTSBUILD_DEBUG" != "0" ]
then
	echo "Build"
	./build.sh
	[ "$?" != "0" ] && echo "ERROR in conan_build" && exit 1
fi

echo "Conan export"
./conanExport.sh
[ "$?" != "0" ] && echo "ERROR in conan_export" && exit 2