#!/bin/bash

set -e

# always change the working directory to the project's root directory
cd $(dirname $0)/..

# pass a $NODE environment variable from something like Makefile
# it should point to either ./node or ./node.exe, depending on the platform
if [ -z $NODE ]; then
  echo "No node executable provided. Bailing." >&2
  exit 0
fi

rm -rf test-npm

# make a copy of deps/npm to run the tests on
cp -r deps/npm test-npm

cd test-npm

# do a rm first just in case deps/npm contained these
rm -rf npm-cache npm-tmp npm-prefix
mkdir npm-cache npm-tmp npm-prefix

# set some npm env varibles to point to our new temporary folders
export npm_config_cache="npm-cache"
export npm_config_prefix="npm-prefix"
export npm_config_tmp="npm-tmp"

# install npm devDependencies and run npm's tests
NODEPATH="$(../$NODE -p 'require("path").resolve("..")')"
PATH="$NODEPATH:$PATH" ../$NODE cli.js install --ignore-scripts
PATH="$NODEPATH:$PATH" ../$NODE test/run.js
PATH="$NODEPATH:$PATH" ../$NODE cli.js run-script tap -- "test/tap/*.js"

# clean up everything one single shot
cd .. && rm -rf test-npm
