##############################################################################
###############    Example loading multiple files at a time   ################
##############################################################################


# Example of how to import many files at once
# Using DOC quality samples fro the BOREAL enclosures
# We are going to use some functional programming functions from {purrr} e.g. pmap()


# Packages needed ---------------------------------------------------------

library(tidyverse)
library(janitor)
library(lubridate)

# Loading the data --------------------------------------------------------


data_dir <- "data/" # directory where the data lives, it makes it easier to store like this in case it is a long address

dat_original <- tibble(files = fs::dir_ls(data_dir)) %>%  # we create a tibble of files in that folder
  mutate(data = purrr::pmap(list(files), ~ read_csv(..1, skip = 1, col_names = TRUE))) %>%  # We load each individual file as a tibble-within-a-tibble
  mutate(data = purrr::pmap(list(files, data), ~ mutate(..2, source_file = as.character(..1)))) %>% # To each individual dataset we add the name of the file it came from (for reference)
  select(data) %>% # select only the actual data tibbles
  purrr::map_df(bind_rows) %>%  # bind them all into one tibble
  janitor::clean_names() # clean the column names


# Usually the file name contains actual data that we want to keep, hence why i created a column for it.
# in this case, the file name has info about the sampling date and the enclosure number
# you can use the {stringr} package of the Tydiverse and some regular expresion (regex) work to split it into actual data columns

dat_original %>% 
  mutate(sampling_date = stringr::str_extract(source_file, "[:digit:]*(?=-)")) %>% # extract the date using regex
  mutate(sampling_date = lubridate::ymd(sampling_date)) %>% # use the lubridate package to make the date into a date
  mutate(enclosure = stringr::str_extract(source_file, "[:digit:]*(?=_)"))  %>%  # extract the date using regex
  select(-source_file) # we dont need it anymore


# NOTE: Yes, regex are evil... no doubt about it
  
  
  
