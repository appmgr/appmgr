#!/bin/bash

if [[ $OSTYPE = darwin* ]]; then
  brew update
  brew install xmlstarlet asciidoc
else
  sudo apt-get update -qq
  sudo apt-get install -qq xmlstarlet asciidoc
fi
