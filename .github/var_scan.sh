bad_vars="$(ag -Rin "^( |\t)*(\w{1,3}|data) *(=|<-).*$" .)"
if ! test -z "$bad_vars"
then
  echo "Unsavory variable names found"
  echo "$bad_vars"
  exit 1
else
  echo "You chose quality variable names, nice!"
  exit 0
fi
