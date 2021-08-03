# load packages
library(magrittr) # for pipes
library(stringr) # for regex matching
library(lintr) # for linting (duh)

# get all R and R Markdown files in the directory
all_r_files = list.files(pattern = "(\\.R$)|(\\.Rmd$)", ignore.case = TRUE, recursive = TRUE)

# filter out any R files in the `renv` directory
files_to_lint = all_r_files %>% .[!str_detect(., "^renv/")]

print_lint_msg = function(lint_vect) {
  message(paste(lint_vect["message"], "in line", lint_vect["line_number"], "of", lint_vect["filename"], sep = " "))
}

lint_results = lapply(files_to_lint, lint) %>% unlist(recursive = FALSE) %>% lapply(unlist)

if (length(lint_results) > 0) {
  lint_results %>% lapply(print_lint_msg)
  file.create(file.path(".github", "linting_fail"))
}
