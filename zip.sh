#!/bin/bash
set -e

make install
cd .venv/lib/python3.13/site-packages
zip -r ../../../../lambda.zip .
cd ../../../../
zip -g lambda.zip *.py
