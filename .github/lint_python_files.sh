python_scripts=$(git ls-files | grep -v 'venv' | egrep -v '^\.' | egrep '\.(py)$')
jupyter_notebooks=$(git ls-files | grep -v 'venv' | egrep -v '^\.' | egrep '\.(ipynb)$')
issues=''

if ! test -z "$python_scripts" # check if variable is not empty
then
  echo -n "Linting python scripts"
  for py_sc in $python_scripts
  do
    cur_iss=$(pylint --score='no' $py_sc | egrep -v '\*\*\*\*\*\*\*\*\*\*\*\*\* Module .*$') # remove header text from results
    if ! test -z "$cur_iss" # check if variable is not empty
    then
      issues="$issues"$'\n'"$cur_iss" # newline needed for proper formatting
    fi
  done
  echo " - complete!"
else
  echo "No python scripts found!"
fi

if ! test -z "$jupyter_notebooks" # check if variable is not empty
then
  echo -n "Linting jupyter notebooks"
  for jup_nb in $jupyter_notebooks
  do
    cur_iss=$(nbqa pylint --score='no' $jup_nb | egrep -v '\*\*\*\*\*\*\*\*\*\*\*\*\* Module .*$') # remove header text from results
    if ! test -z "$cur_iss" # check if variable is not empty
    then
      issues="$issues"$'\n'"$cur_iss" # newline needed for proper formatting
    fi
  done
  echo " - complete"
else
  echo "No jupyter notebooks found!"
fi

if ! test -z "$issues" # check if variable is not empty
then
  echo $'\nIssues in python code found'
  echo "$issues" # print out output from linting tools - listing code issues
  exit 1 # exit with error to trigger test failure
fi
