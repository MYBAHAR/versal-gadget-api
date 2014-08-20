#!/bin/bash

set -e

git checkout bower

# The built directories
deps='eventEmitter normalize-css underscore versal-challenges-api versal-gadget-theme versal-player-api index.js index.css'

# Clean/rebuild
rm -rf deps
bower install

# Commit and push to bower (release) branch
git add -A .
git commit -m "Rebuilds bower for 'git log master -1 | head -1'"
git push origin bower

git checkout master
