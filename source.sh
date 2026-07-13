#!/bin/bash

repo=$1;
branch=$2
dest=$3

if [ -d "../$dest" ]; then exit; fi;
git clone git@github.com:fervark/$repo.git ../$dest
cd ../$dest || exit;
git fetch origin "$branch"
git switch $branch
