library(rvest)
library(tidyverse)
library(xml2)

raw_data <-
  read_html(
    "https://en.wikipedia.org/wiki/List_of_prime_ministers_of_Australia"
  )
write_html(raw_data, "pms.html")
raw_data <- read_html("pms.html")
parse_data_selector_gadget <-
  raw_data |>
  html_element(".wikitable") |>
  html_table()

head(parse_data_selector_gadget)


saveRDS(raw_data, "inputs/data/raw_data.rds")
saveRDS(parse_data_selector_gadget, "inputs/data/parse_data_selector_gadget.rds")
