rm(list = ls())

# Load libraries ----------------------------------------------------------

library(shiny)
library(shinythemes)
library(jsonlite)
library(dplyr)
library(tidyr)
library(tidytext)
library(forcats)
library(plotly)
library(DT)
library(ggplot2)
library(wordcloud)

# Read data from json file ------------------------------------------------

recipes <- jsonlite::fromJSON("data/train.json")

# Preprocess data ---------------------------------------------------------

# Make long format data
recipes$ingredients <- sapply(recipes$ingredients, function(x) { paste(unlist(x), collapse = ",") })
recipes <- tidyr::separate_rows(recipes, .data$ingredients, sep = ",")

print(head(recipes))

# Compute TFIDF -----------------------------------------------------------

recipes_enriched <- recipes %>%
    dplyr::count(.data$cuisine, .data$ingredients, name = "nb_recipes") %>%
    tidytext::bind_tf_idf(
        tbl = ., 
        term = .data$ingredients, 
        document = .data$cuisine, 
        n = .data$nb_recipes
    )

print(head(recipes_enriched))
