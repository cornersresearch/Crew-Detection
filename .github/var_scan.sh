#!/usr/bin/env bash

# run silversearcher-ag to search for regex matches in files
# searches for a 3-letter variable name or 'data' before an assignment operator
bad_vars="$(ag -rio --numbers --filename --ignore={.github,renv,venv} "(^(\(| |\t)*(def)?(\(| |\t)*(\w{1,3}|data) *(=|<-|\(.*\)\s*:).*)(?![^\(]*\))" .)"
if ! test -z "$bad_vars"
then
  # fail test if any bad variables are found
  echo "Unsavory variable names found"
  echo "$bad_vars"
  exit 1
else
  # pass test if no bad variable names are found
  echo "You chose quality variable names, nice!"
  exit 0
fi
