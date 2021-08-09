import sys
import json
import pandas as pd
import re

json_text = ''
for line in sys.stdin:
        json_text = json_text + line # get json piped in from cloc
parsed_json = json.loads(json_text)

total_comment_ratio = parsed_json['SUM']['comment']

results_df = pd.DataFrame(parsed_json)
cleaned_results = results_df[results_df['header'].isna()].drop(columns='header').drop(labels='nFiles').rename_axis('new_head').reset_index()
cleaned_results['new_head'] = cleaned_results['new_head'].str.replace('_pct', '')
pivot_results = cleaned_results.pivot_table(columns='new_head').applymap(lambda x: str(round(x, 1)) + '%')

print("All values are percents of total number of code lines + comment lines")
# requires tabulate
print(pivot_results.to_markdown(tablefmt="grid"))

if total_comment_ratio < 50:
    exit("Comment to code ratio too low!")
exit(0)
