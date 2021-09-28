"""
This script removes code in nested parenthesis to prepare for variable scanning
R and Python both also use assignment operators to specify named arguments/paramaters in functions
Since these arguments are specified by other functions that are likely
...outside of our control, they should not be flagged
"""
import re
import subprocess

# this regex captures only the innermost pair of parenthesis and its contents
PARENTHESES_REGEX = r'\([^()]*\)'
# command to get a list of files that contain parenthesis to clean using ag silver searcher
# we don't want to process files in .github so the scripts that are being run remain unmodified
AG_CMD = f'ag -rl --ignore=".github" "{PARENTHESES_REGEX}" .'
files_to_preprocess = subprocess.run(AG_CMD,
                                     shell=True, check=True, capture_output=True).stdout.decode('utf-8').split('\n')

print('Cleaning files for variable scanning')
# loop through each file identified as needing cleaning
for file_path in files_to_preprocess:
    # omit file paths that are empty
    if file_path is not None and file_path != '':
        # open file to read and process
        with open(file_path, 'r') as cur_file:
            # apply regex recursively to get all nested parenthesis
            new_file_contents = re.subn(PARENTHESES_REGEX, '', cur_file.read())
        # overwrite file with parenthesis removed
        # this is okay because it will run on copies of files in its own container
        with open(file_path, 'w') as cleaned_file:
            cleaned_file.write(new_file_contents[0])
