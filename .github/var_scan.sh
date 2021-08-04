bad_vars="$(ag -Rin "^( |\t)*(\w{1,3}|data) *(=|<-).*$" .)"
if ! test -z "$bad_vars"
then
  echo "Unsavory variable names found"
  touch ".github/linting_fail"
  echo "$bad_vars"
else
  echo "You chose quality variable names, nice!"
fi
