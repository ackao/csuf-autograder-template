#!/bin/bash

cd /autograder/source
git init
git submodule add https://github.com/ackao/csuf-autograder-base.git csuf-autograder-base/

csuf-autograder-base/install_deps.sh
