#!/usr/bin/env bash
#
# Purpose: To bundle the output includes/libs from the build.sh command into a conan dependency and upload it to a binary repository
# Usage: 

echo "INFO: CONAN_CHANNEL=$CONAN_CHANNEL"
echo "INFO: REPO_REMOTE_NAME=$REPO_REMOTE_NAME"

[ "$VSTSBUILD_DEBUG" == "1" ] && set -x

conanFile="./conanfile.py"
projectName="conan-webrtc"

packageUser="smoothwall"
packageChannel="$CONAN_CHANNEL"
remoteName="$REPO_REMOTE_NAME"

builtTypes="release debug"

outDir="out"
pkgFile="$outDir/package_name.txt"
packageVersion="1.0.`cat "$pkgFile" | awk {'print $1'}`"
outputDirName="`cat "$pkgFile" | awk {'print $2'}`"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/util.sh"

detect-platform
TARGET_OS=${TARGET_OS:-$PLATFORM}

if [ "$TARGET_OS" == "win" ]
then
	conan="/c/Program Files/Conan/conan/conan.exe"
else
	conan="conan"
fi

export CONAN_FILE_VERSION="$packageVersion"
ref="$projectName/$packageVersion@$packageUser/$packageChannel"

echo "INFO: Exporting conan package: $ref"

for buildType in $builtTypes
do
	echo "INFO: Exporting conan package: $ref - $buildType"
#	"$conan" create . "$packageUser/$packageChannel" -s build_type="$buildType"

	[ "$?" != "0" ] && echo "ERROR in conan_create" && exit 1
	
	if [ "$TARGET_OS" == "win" ]; then
		"$conan" export-pkg "$conanfile" "$ref" -f -s os=Windows -s compiler="Visual Studio" -s compiler.version=15 -s build_type="$buildType"
	elif [ "$TARGET_OS" == "mac" ]; then
		"$conan" export-pkg "$conanfile" "$ref" -f -s os=Macos -s compiler="Xcode" -s compiler.version=10.00 -s build_type="$buildType"
	fi
	ret=$?
	[ "$ret" != "0" ] && echo "ERROR in conan_export-pkg: $ret" && exit 1
	
	"$conan" upload "$ref" -c -r="$remoteName" --all --force
	ret=$?
	[ "$ret" != "0" ] && echo "ERROR in conan_upload: $ret" && exit 1
	
done

exit 0