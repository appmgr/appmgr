#!/bin/bash
VERSION=$1
gbp dch --debian-branch=debian/sid -R -N $VERSION --auto
