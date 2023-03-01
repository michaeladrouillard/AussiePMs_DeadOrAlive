library(rvest)
library(tidyverse)
library(xml2)
library(dplyr)
library(janitor)


parse_data_selector_gadget <- readRDS(here::here("inputs/data/parse_data_selector_gadget.rds"))
colnames(parse_data_selector_gadget)


parsed_data <- clean_names(parse_data_selector_gadget)

parsed_data <- parsed_data %>%
  select(name_birth_death_constituency) %>%
  rename(raw_text = name_birth_death_constituency) %>%
  filter(raw_text != "name_birth_death_constituency") %>%
  distinct()

parsed_data <- parsed_data %>%
  slice(-1)

head(parsed_data)

initial_clean <-
  parsed_data |>
  separate(
    raw_text,
    into = c("name", "not_name"),
    sep = "\\(",
    extra = "merge",
  ) |> 
  mutate(date = str_extract(not_name, "[[:digit:]]{4}–[[:digit:]]{4}"),
         born = str_extract(not_name, "b.[[:space:]][[:digit:]]{4}"),
  ) |> # Alive PMs have slightly different format and only have born
  select(name, date, born)

head(initial_clean)

cleaned_data <-
  initial_clean |>
  separate(date, into = c("birth", "died"), 
           sep = "–") |> 
  mutate(
    born = str_remove_all(born, "b.[[:space:]]"),
    birth = if_else(!is.na(born), born, birth)
  ) |> 
  select(-born) |>
  rename(born = birth) |> 
  mutate(across(c(born, died), as.integer)) |> 
  mutate(Age_at_Death = died - born) |> 
  distinct() 

saveRDS(cleaned_data, "inputs/data/cleaned_data.rds")





library(ggplot2)
library(dplyr)

cleaned_data |>
  mutate(
    still_alive = if_else(is.na(died), "Yes", "No"),
    died = if_else(is.na(died), as.integer(2023), died)
  ) |>
  mutate(name = as_factor(name)) |>
  ggplot(aes(
    x = born,
    xend = died,
    y = name,
    yend = name,
    color = still_alive
  )) +
  geom_segment() +
  labs(
    x = "Year of birth",
    y = "Prime minister",
    color = "PM is currently alive",
    title = "How long each Aussie Prime Minister lived, by year of birth"
  ) +
  theme_minimal() +
  scale_color_brewer(palette = "Set1") +
  theme(legend.position = "bottom")
