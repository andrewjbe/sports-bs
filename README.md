# sportsBs

*A package for sharing code from Drew's sports BS*

### Disclaimer

I'm putting this into package format to make sharing code easier, but I don't think I'm going to have the time to actually ensure this package will work / be installable on all setups, so I apologize if it doesn't work on yours. I'm currently using R 4.2.2 on Linux (Pop!\_OS 22.04 LTS x86\_64), for reference.

### Functionality

There are two main tasks I'm accomplishing with this code:

1. First, maps. The following files (located in `R/`) contain functions related to creating maps:
    - **cfb_generate_maps.R** houses functions for generating r/CFB maps. As of right now, I've only ported over my script for generating a .PNG image of a "Classic" Imperialism Map for any given season / week.
    - **cbb_generate_maps.R** is currently empty, but it will eventually house functions for generating r/CollegeBasketball related maps

2. Second, I've also got some code related to scraping sports-related social media data. The following files (located in `R/`) contain functions related to this:
    - **scrape_reddit_url.R** contains a function that scrapes the entire comment section of a given Reddit post. It uses a Python function (currently in `R/reddit_scraper.py`, I actually need to move that to `inst/` I think though) to accomplish this, since I don't like any of the Reddit API interfaces I've found in R. Note that it takes a super long time to scrape any thread with more than a few thousand comments due to the way Reddit's API works.
    - **generate_single_game_report.R** contains functions for generating "Game Thread" reports using Quarto (the code for the reports themselves can be found in `inst/reports/`). Currently supports comment data from r/CFB and r/NFL; r/CollegeBasketball is on the to-do list (hopefully before 2023 March Madness starts).

### To-Do List

1. I need to finish porting all my random scripts over. Including:
    - **CFB:** 1) a function to generate the CFB Power Projection map, and 2) a function to generate the CFB "Closest Undefeated" map
    - **CBB:** 1) Functions to create all three maps for College Basketball? 
    - **Dashboards:** 1) I need to clean up all my code on the map dashboards, and create seperate repos for those.
