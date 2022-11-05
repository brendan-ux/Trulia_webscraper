# Trulia_webscraper
An _extremely_ crude wrapper for a trulia.com webscraper that collects residential home listings and downloads them to the active directory. 
It requires the `rvest`, `polite`, and `tidyverse` packages to run, and will load them into your environment for you. There is also a 5 second delay on scraping each page, so it will take some time if iterating over multiple pages.

**Currently**- documentation is absent, but `trulia.webscraper::trulia(city, state, page)` is pretty self-explanatory. 
Where `page` is the number of pages from Trulia for the function to iterate over and `state` is the abbreviation of the state name.

**Example** `trulia("vero_beach", "fl", 5)` would scrape the first five pages of the Trulia.com for residential homes in _Vero Beach, FL_
