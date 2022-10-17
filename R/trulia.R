check_pkg_deps <- function() {
  if(!require(tidyverse)) {
    message("loading the tidyverse package")
    library(tidyverse)
  }
  if(!require(rvest)) {
    message("loading the rvest package")
    library(rvest)
  }
  if(!require(polite)) {
    message("loading the polite package")
    library(polite)
  }
}

trulia <- function(state, city, k) {
  # to check for package dependencies
  check_pkg_deps()
  prop <- data.frame()
  # vacant lots are given /home/ in the url
  for (i in 1:k) {
    url = paste0("https://www.trulia.com/", state, "/", city, "/", i, "_p/")

    int <- scrape(bow(url)) %>%
      html_elements(".jYyvOn") %>%
      html_attr("href")

    links <- data.frame(x = paste0("https://www.trulia.com", int)[1:40])

    prop <- bind_rows(prop, links)
  }

  houses <- prop %>%
    filter(str_detect(x, "/p/"))

  trulia_list <- tibble()

  for (j in 1:dim(houses)[1]) {
    alt_session <- bow(houses$x[j])

    # interior_features table
    int_step <- data.frame(
      x = scrape(alt_session) %>%
        html_nodes(".gmLKqq") %>%
        html_text2())

    features <- data.frame(x = str_subset(int_step$x, ": ")) %>%
      separate(x, c("y", "z"), sep = ": ") %>%
      pivot_wider(names_from = y, values_from = z) %>%
      filter(`Property Type` == "Residential")

    location <- data.frame(x = scrape(alt_session) %>%
                             html_elements("img") %>%
                             html_attr("srcset")) %>%
      filter(!is.na(x), str_detect(x, "googleapis.com"))

    coord_step <- unlist(mutate(location,
      x = str_extract_all(x, "[:digit:]{2}.[:digit:]{14}")))

    lat <- as.double(coord_step[1])
    lon <- -as.double(coord_step[2])
    coord <- data.frame(lat, lon)

    desc <- data.frame(desc = scrape(alt_session) %>%
                         html_element(".GoKXY") %>%
                         html_text2())

    contents <- tibble(features, coord, desc) %>%
      janitor::clean_names()

    trulia_list <- bind_rows(trulia_list, contents) %>%
      janitor::clean_names()
  }
  write_csv(trulia_list, file = paste0(paste(
    "Trulia-listings", city, state, Sys.Date(), sep = "-"), ".csv")
    )
}
