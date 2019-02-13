#!/usr/bin/env bash
#
# Purpose: To bundle the output includes/libs from the build.sh command into a conan dependency and upload it to a binary repository
# Usage: 

conanFile="./conanfile.py"
projectName="conan-webrtc"

packageUser="smoothwall"
packageChannel="testing"
remoteName="smoothwall"

conan="conan"
builtTypes="Release Debug"

outDir="out"
pkgFile="$outDir/package_name.txt"
packageVersion="1.0.`cat "$pkgFile" | awk {'print $1'}`"
outputDirName="`cat "$pkgFile" | awk {'print $2'}`"

export CONAN_FILE_VERSION="$packageVersion"
ref="$projectName/$packageVersion@$packageUser/$packageChannel"

echo "INFO: Exporting conan package: $ref"

for buildType in $builtTypes
do
	"$conan" create . "$packageUser/$packageChannel" -s build_type="$buildType"

	[ "$?" != "0" ] && echo "ERROR in conan_create" && exit 1
	
	if [ "$TARGET_OS" == "Windows" ]; then
		"$conan" export-pkg "$conanfile" "$ref" -f -s os=Windows -s compiler="Visual Studio" -s compiler.version=15 -s build_type="$buildType"
	elif [ "$TARGET_OS" == "Macos" ]; then
		"$conan" export-pkg "$conanfile" "$ref" -f -s os=Macos -s compiler="Xcode" -s compiler.version=10.00 -s build_type="$buildType"
	fi
	[ "$?" != "0" ] && echo "ERROR in conan_export-pkg" && exit 1
	
	"$conan" upload "$ref" -c -r="$remoteName" --all --force
	[ "$?" != "0" ] && echo "ERROR in conan_upload" && exit 1
	
done