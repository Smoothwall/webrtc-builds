#!/usr/bin/env bash

echo "INFO: VSTSBUILD_DEBUG=$VSTSBUILD_DEBUG"
echo "INFO: VSTSBUILD_BUILD=$VSTSBUILD_BUILD"

[ "$VSTSBUILD_DEBUG" == "1" ] && set -x

ucgoCmd="./tools/ucgo.sh"
buildCmd="./tools/build.sh"

lastReturnCode=0

function ReturnCodeCheck {
   alias="$1"
   rc="$2"
   expectedRc="$3"

   if [ "$expectedRc" == "" ]
   then
       expectedRc=0
   fi

   if [ "$rc" -le "$expectedRc" ]
   then
       echo "INFO: OK - $alias - $rc <= $expectedRc - $rcPs"
   else
       echo "INFO: Error processing: $alias - $rc > $expectedRc"
       exit $rc
   fi
}

function StartBashProcess {
   alias="$1"
   process="$2"
   shift
   shift
   argList=("$@")

   if [ "$lastReturnCode" != "0" ]; then
      return;
   fi
   
   echo "INFO: Start process: $alias, process: $process $argList"
   "$process" "${argList[@]}"
   
   ReturnCodeCheck "$alias" "$?" "$expectedRc"
}

StartBashProcess "setupBuild" "$ucgoCmd" "setupBuild" # Setup conan remote/API key and hooks
StartBashProcess "prepare" "$ucgoCmd" "prepare" # Setup code, e.g set repo git hooks

if [ "$VSTSBUILD_BUILD" != "0" ]
then
	echo "INFO: Run build.sh from the original upstream repo"
	StartBashProcess "build" "./build.sh" # run upstream build.sh
fi

echo "INFO: Conan export"
StartBashProcess "export" "./conanExport.sh" # export output to conan repo
exit 0;
