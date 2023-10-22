# What is this?

As a side project, I decided to scrape every comment from every game
thread this season. I decided to use the data to do a “r/CFB census” to
see what I could learn about the different fanbases, and I posted the
first update
[here](https://old.reddit.com/r/CFB/comments/16srlyr/cfb_flair_census_update_scraping_every_game/)
earlier in the season. Now that we’re getting into the latter half, I
thought I’d post another update.

# The data

So far, I’ve scraped 742 game threads with 1,133,846 total comments. I
actually also have the post game threads as well, which expands the
total number of comments to 1,274,841, but for now I’m just going to
focus on the game threads. If you want to see what this post would look
like if I included the PGTs too, you can see that [here]().

Here’s a fun graph that shows how many comments people left per hour
throughout the whole season: [GRAPH: comments per hour]()

Here’s a table with the top ten game threads so far this year by total
comments. Colorado seems to be popular for some reason, not sure why.

| Rank | Thread                    | Total Comments |
|:-----|:--------------------------|:---------------|
| #1   | Colorado State @ Colorado | 52,055         |
| #2   | Colorado @ Oregon         | 28,412         |
| #3   | Florida State vs LSU      | 26,206         |
| #4   | Ohio State @ Notre Dame   | 25,801         |
| #5   | Texas @ Alabama           | 25,407         |
| #6   | Nebraska @ Colorado       | 25,254         |
| #7   | Texas vs Oklahoma         | 25,245         |
| #8   | Clemson @ Duke            | 25,009         |
| #9   | Colorado @ TCU            | 23,449         |
| #10  | Oregon @ Washington       | 22,062         |

This time, I also added up the total number of comments in all of each
team’s game threads this year in order to find the most talked-about
team on r/CFB this year. The top team will absolutely shock you!

| Rank | Team           | Avg. Comments per Game Thread | Total Comments | Total Threads |
|:-----|:-------------|:--------------------------|:-------------|------------:|
| #1   | Colorado       | 23,633.29                     | 165,433        |             7 |
| #2   | Texas          | 10,636.33                     | 63,818         |             6 |
| #3   | USC            | 10,498.57                     | 73,490         |             7 |
| #4   | Notre Dame     | 10,193.88                     | 81,551         |             8 |
| #5   | Oregon         | 9,954.17                      | 59,725         |             6 |
| #6   | Ohio State     | 9,858.00                      | 59,148         |             6 |
| #7   | Florida State  | 9,480.17                      | 56,881         |             6 |
| #8   | Colorado State | 9,366.00                      | 56,196         |             6 |
| #9   | Alabama        | 8,477.00                      | 59,339         |             7 |
| #10  | Nebraska       | 8,262.67                      | 49,576         |             6 |

Colorado has had exactly one (1) game thread so far with less than 15k
comments (@ ASU). Here is their full slate thus far:

``` r
gt_data_clean |> 
  filter(home == "Colorado" | away == "Colorado") |> 
  count("Thread" = title_clean) |> 
  arrange(desc(n)) |> 
  mutate(n = format(n, big.mark = ",")) |> 
  rename("Total Comments" = n)
```

    ## # A tibble: 7 × 2
    ##   Thread                    `Total Comments`
    ##   <chr>                     <chr>           
    ## 1 Colorado State @ Colorado "52,055"        
    ## 2 Colorado @ Oregon         "28,412"        
    ## 3 Nebraska @ Colorado       "25,254"        
    ## 4 Colorado @ TCU            "23,449"        
    ## 5 USC @ Colorado            "18,905"        
    ## 6 Stanford @ Colorado       "15,369"        
    ## 7 Colorado @ Arizona State  " 1,989"

# r/CFB flair census

The first question I wanted to answer was “how big is each fanbase?” To
determine this, I took every username that left a comment in a game
thread this year, and classified them by their most recent primary
flair. Also, just to save space, I cut it off at flairs with 50+ unique
users. Feel free to ask if you’re curious about a smaller school’s
numbers.

The first table here shows the results, sorted by total unique users:

## Flair census

| Rank | Logo                                     | Primary Flair     | Unique Users | Total Comments | Comments per User | Avg. Comment Score | % of Comments w/ Swears | % of Comments w/ Ref Complaints | Top Poster                            |
|:--|:------|:------|:----|:-----|:------|:------|:--------|:----------|:------------|
| #1   | [Ohio State](#f/ohiostate)               | Ohio State        | 1,729        | 53,803         | 31.12             | 3.93               | 9.96%                   | 2.45%                           | Dead_Baby_Kicker (1,159 comments)     |
| #2   | [Michigan](#f/michigan)                  | Michigan          | 1,670        | 56,842         | 34.04             | 3.93               | 8.99%                   | 1.77%                           | Elbit_Curt_Sedni (1,118 comments)     |
| #3   | [Georgia](#f/georgia)                    | Georgia           | 1,300        | 50,216         | 38.63             | 4.25               | 11.09%                  | 2.09%                           | DiarrheaForDays (1,661 comments)      |
| #4   | [/r/CFB](#f//r/cfb)                      | /r/CFB            | 1,100        | 13,862         | 12.60             | 3.18               | 11.39%                  | 2.92%                           | IEatDeFish (667 comments)             |
| #5   | [Texas](#f/texas)                        | Texas             | 1,066        | 28,235         | 26.49             | 3.98               | 10.69%                  | 2.36%                           | cn0285 (783 comments)                 |
| #6   | [Oklahoma](#f/oklahoma)                  | Oklahoma          | 999          | 38,522         | 38.56             | 4.75               | 11.1%                   | 2.72%                           | MrNudeGuy (1,151 comments)            |
| #7   | [Alabama](#f/alabama)                    | Alabama           | 961          | 26,963         | 28.06             | 3.65               | 11.24%                  | 2.31%                           | Dellav8r (746 comments)               |
| #8   | [Nebraska](#f/nebraska)                  | Nebraska          | 824          | 17,602         | 21.36             | 4.00               | 10.28%                  | 1.92%                           | Panchoisthedog (528 comments)         |
| #9   | [Notre Dame](#f/notredame)               | Notre Dame        | 824          | 28,945         | 35.13             | 4.49               | 11.24%                  | 3.21%                           | ddottay (791 comments)                |
| #10  | [Texas A&M](#f/texasam)                  | Texas A&M         | 782          | 23,059         | 29.49             | 4.24               | 10.8%                   | 3.02%                           | FightingFarrier18 (1,333 comments)    |
| #11  | [Florida State](#f/floridastate)         | Florida State     | 778          | 32,750         | 42.10             | 3.95               | 11.02%                  | 2.8%                            | Ajp_iii (1,515 comments)              |
| #12  | [Oregon](#f/oregon)                      | Oregon            | 751          | 27,113         | 36.10             | 3.57               | 11.05%                  | 2.77%                           | mechnick2 (651 comments)              |
| #13  | [Penn State](#f/pennstate)               | Penn State        | 746          | 20,612         | 27.63             | 4.49               | 7.53%                   | 1.67%                           | BikiniATroll (2,083 comments)         |
| #14  | [Florida](#f/florida)                    | Florida           | 689          | 14,569         | 21.15             | 4.11               | 10.14%                  | 2.31%                           | ElSorcho (524 comments)               |
| #15  | [Tennessee](#f/tennessee)                | Tennessee         | 656          | 19,319         | 29.45             | 4.31               | 12.14%                  | 2.9%                            | EWall100 (659 comments)               |
| #16  | [LSU](#f/lsu)                            | LSU               | 605          | 18,266         | 30.19             | 3.77               | 13.18%                  | 2.49%                           | indreams159 (1,083 comments)          |
| #17  | [USC](#f/usc)                            | USC               | 586          | 20,664         | 35.26             | 3.89               | 10.01%                  | 2.38%                           | eosophobe (601 comments)              |
| #18  | [Clemson](#f/clemson)                    | Clemson           | 574          | 17,339         | 30.21             | 4.26               | 9.16%                   | 2.08%                           | bigmike1877 (686 comments)            |
| #19  | [Iowa](#f/iowa)                          | Iowa              | 572          | 20,699         | 36.19             | 4.12               | 11.15%                  | 1.86%                           | elgenie (1,102 comments)              |
| #20  | [Michigan State](#f/michiganstate)       | Michigan State    | 540          | 17,315         | 32.06             | 4.41               | 9.71%                   | 1.29%                           | twat_swat22 (847 comments)            |
| #21  | [Washington](#f/washington)              | Washington        | 538          | 14,123         | 26.25             | 4.26               | 9.93%                   | 2%                              | Pollaski (835 comments)               |
| #22  | [Wisconsin](#f/wisconsin)                | Wisconsin         | 514          | 11,900         | 23.15             | 4.09               | 10.03%                  | 2.87%                           | OldVeterinarian9 (414 comments)       |
| #23  | [Auburn](#f/auburn)                      | Auburn            | 489          | 12,963         | 26.51             | 3.98               | 9.6%                    | 1.69%                           | Kodyaufan2 (1,297 comments)           |
| #24  | [South Carolina](#f/southcarolina)       | South Carolina    | 447          | 14,037         | 31.40             | 3.95               | 9.68%                   | 1.76%                           | jthomas694 (657 comments)             |
| #25  | [Utah](#f/utah)                          | Utah              | 400          | 17,691         | 44.23             | 4.44               | 11.69%                  | 2.2%                            | NeuroTheManiacal (1,029 comments)     |
| #26  | [Colorado](#f/colorado)                  | Colorado          | 393          | 9,734          | 24.77             | 3.77               | 10.73%                  | 1.62%                           | N3phewJemima (727 comments)           |
| #27  | [UCF](#f/ucf)                            | UCF               | 389          | 14,339         | 36.86             | 4.07               | 10.82%                  | 1.87%                           | Tarlcabot18 (1,159 comments)          |
| #28  | [Virginia Tech](#f/virginiatech)         | Virginia Tech     | 383          | 14,286         | 37.30             | 4.33               | 7.71%                   | 2.69%                           | macncheeseface (641 comments)         |
| #29  | [Arkansas](#f/arkansas)                  | Arkansas          | 375          | 9,242          | 24.65             | 4.08               | 11.55%                  | 3.17%                           | fancycheesus (427 comments)           |
| #30  | [Oklahoma State](#f/oklahomastate)       | Oklahoma State    | 319          | 9,998          | 31.34             | 3.89               | 9.85%                   | 1.21%                           | huttts999 (653 comments)              |
| #31  | [Minnesota](#f/minnesota)                | Minnesota         | 318          | 6,207          | 19.52             | 4.44               | 10.57%                  | 1.66%                           | bringbacktheaxe2 (369 comments)       |
| #32  | [Texas Tech](#f/texastech)               | Texas Tech        | 315          | 12,769         | 40.54             | 4.13               | 12.51%                  | 2.98%                           | FuckTheLonghorns (539 comments)       |
| #33  | [West Virginia](#f/westvirginia)         | West Virginia     | 310          | 9,180          | 29.61             | 4.44               | 12.88%                  | 2.1%                            | fuckconcrete (973 comments)           |
| #34  | [Kansas](#f/kansas)                      | Kansas            | 300          | 10,176         | 33.92             | 4.00               | 13.1%                   | 3.37%                           | jayhawk_cowboy (512 comments)         |
| #35  | [Kentucky](#f/kentucky)                  | Kentucky          | 298          | 12,199         | 40.94             | 3.72               | 13.95%                  | 2.31%                           | leakymemo (1,327 comments)            |
| #36  | [Purdue](#f/purdue)                      | Purdue            | 297          | 8,891          | 29.94             | 3.84               | 10.76%                  | 2.4%                            | CoachRyanWalters (617 comments)       |
| #37  | [Iowa State](#f/iowastate)               | Iowa State        | 292          | 9,528          | 32.63             | 3.82               | 8.46%                   | 1.44%                           | loyalsons4evertrue (1,570 comments)   |
| #38  | [Washington State](#f/washingtonstate)   | Washington State  | 290          | 12,291         | 42.38             | 3.93               | 11.15%                  | 1.9%                            | F-18EBestHornet (1,432 comments)      |
| #39  | [Oregon State](#f/oregonstate)           | Oregon State      | 287          | 9,946          | 34.66             | 4.86               | 11%                     | 2.87%                           | Training-Joke-2120 (721 comments)     |
| #40  | [Georgia Tech](#f/georgiatech)           | Georgia Tech      | 278          | 7,609          | 27.37             | 4.59               | 10.75%                  | 2.14%                           | thank_burdell (445 comments)          |
| #41  | [Miami](#f/miami)                        | Miami             | 265          | 8,261          | 31.17             | 3.67               | 11.84%                  | 3.05%                           | TheBoook (1,012 comments)             |
| #42  | [North Carolina](#f/northcarolina)       | North Carolina    | 260          | 8,450          | 32.50             | 4.10               | 10.73%                  | 2.85%                           | MayeForTheWin (715 comments)          |
| #43  | [Illinois](#f/illinois)                  | Illinois          | 243          | 6,717          | 27.64             | 3.99               | 9.33%                   | 2.49%                           | Puzzleheaded-Sky-111 (478 comments)   |
| #44  | [Missouri](#f/missouri)                  | Missouri          | 236          | 6,698          | 28.38             | 3.95               | 9.9%                    | 2.48%                           | superworriedspursfan (750 comments)   |
| #45  | [NC State](#f/ncstate)                   | NC State          | 230          | 8,672          | 37.70             | 4.18               | 12.71%                  | 2.34%                           | D1N2Y (838 comments)                  |
| #46  | [Kansas State](#f/kansasstate)           | Kansas State      | 226          | 5,499          | 24.33             | 4.07               | 10.15%                  | 2.27%                           | theurge14 (372 comments)              |
| #47  | [Cincinnati](#f/cincinnati)              | Cincinnati        | 222          | 6,875          | 30.97             | 3.81               | 10.3%                   | 2.15%                           | Pitiful-Bumblebee775 (662 comments)   |
| #48  | [BYU](#f/byu)                            | BYU               | 220          | 9,569          | 43.50             | 4.24               | 4.45%                   | 1.52%                           | AeroStatikk (1,201 comments)          |
| #49  | [Baylor](#f/baylor)                      | Baylor            | 219          | 8,582          | 39.19             | 3.93               | 10.66%                  | 1.9%                            | thebaylorweedinhaler (1,539 comments) |
| #50  | [UCLA](#f/ucla)                          | UCLA              | 208          | 6,545          | 31.47             | 3.99               | 9.75%                   | 2.43%                           | JoshFB4 (549 comments)                |
| #51  | [California](#f/california)              | California        | 195          | 4,675          | 23.97             | 4.64               | 9.45%                   | 3.21%                           | FrivolousMe (327 comments)            |
| #52  | [Rutgers](#f/rutgers)                    | Rutgers           | 186          | 6,330          | 34.03             | 4.22               | 8.72%                   | 2.84%                           | thibbs23 (782 comments)               |
| #53  | [Maryland](#f/maryland)                  | Maryland          | 183          | 5,323          | 29.09             | 3.77               | 10.31%                  | 1.93%                           | SEND_ME_YOUR_CAULK (476 comments)     |
| #54  | [Arizona State](#f/arizonastate)         | Arizona State     | 182          | 5,013          | 27.54             | 3.94               | 9.08%                   | 1.8%                            | DillyDillySzn (654 comments)          |
| #55  | [Pittsburgh](#f/pittsburgh)              | Pittsburgh        | 176          | 4,265          | 24.23             | 3.96               | 10.29%                  | 1.64%                           | Lovelylives (310 comments)            |
| #56  | [Ole Miss](#f/olemiss)                   | Ole Miss          | 174          | 6,174          | 35.48             | 3.56               | 12.33%                  | 2.64%                           | HopefulReb76 (706 comments)           |
| #57  | [Louisville](#f/louisville)              | Louisville        | 156          | 6,544          | 41.95             | 3.84               | 10.02%                  | 2.52%                           | LukarWarrior (684 comments)           |
| #58  | [Indiana](#f/indiana)                    | Indiana           | 155          | 5,209          | 33.61             | 3.74               | 11.5%                   | 2.03%                           | JonnyTactical (349 comments)          |
| #59  | [TCU](#f/tcu)                            | TCU               | 151          | 4,317          | 28.59             | 4.19               | 11.17%                  | 1.97%                           | an0m_x (341 comments)                 |
| #60  | [Appalachian State](#f/appalachianstate) | Appalachian State | 142          | 4,604          | 32.42             | 3.91               | 11.38%                  | 1.74%                           | ChonkyWumpus (380 comments)           |
| #61  | [Houston](#f/houston)                    | Houston           | 139          | 4,532          | 32.60             | 3.98               | 11.41%                  | 1.59%                           | Key_Spinach (571 comments)            |
| #62  | [Arizona](#f/arizona)                    | Arizona           | 138          | 4,731          | 34.28             | 3.75               | 11.33%                  | 2.96%                           | GracefulFaller (449 comments)         |
| #63  | [Boise State](#f/boisestate)             | Boise State       | 138          | 7,289          | 52.82             | 3.62               | 11.96%                  | 1.76%                           | -Gnostic28 (653 comments)             |
| #64  | [Virginia](#f/virginia)                  | Virginia          | 138          | 3,297          | 23.89             | 4.56               | 9.43%                   | 1.85%                           | Eight_Trace (730 comments)            |
| #65  | [Syracuse](#f/syracuse)                  | Syracuse          | 136          | 2,921          | 21.48             | 4.05               | 11.95%                  | 4.55%                           | JohnWickisBehindU (240 comments)      |
| #66  | [Mississippi State](#f/mississippistate) | Mississippi State | 114          | 3,685          | 32.32             | 3.78               | 9.12%                   | 2.09%                           | Ok_Swimmer634 (498 comments)          |
| #67  | [Duke](#f/duke)                          | Duke              | 102          | 2,326          | 22.80             | 4.68               | 7.65%                   | 1.81%                           | AnotherUnfunnyName (175 comments)     |
| #68  | [Paper Bag](#l/paperbag)                 | Paper Bag         | 102          | 7,756          | 76.04             | 3.73               | 10.22%                  | 2.49%                           | aMiracleAtJordanHare (1,637 comments) |
| #69  | [USF](#f/usf)                            | USF               | 98           | 2,122          | 21.65             | 4.28               | 8.86%                   | 1.32%                           | United_Energy_7503 (229 comments)     |
| #70  | [Team Chaos](#l/chaos)                   | Team Chaos        | 93           | 2,471          | 26.57             | 3.80               | 11.66%                  | 1.58%                           | Doomas\_ (261 comments)               |
| #71  | [Colorado State](#f/coloradostate)       | Colorado State    | 85           | 2,964          | 34.87             | 6.03               | 14.98%                  | 1.05%                           | Staind075 (379 comments)              |
| #72  | [James Madison](#f/jamesmadison)         | James Madison     | 76           | 1,542          | 20.29             | 4.74               | 8.11%                   | 3.89%                           | AnarchNova (161 comments)             |
| #73  | [Stanford](#f/stanford)                  | Stanford          | 75           | 3,331          | 44.41             | 3.97               | 7.6%                    | 1.53%                           | InVodkaVeritas (936 comments)         |
| #74  | [Northwestern](#f/northwestern)          | Northwestern      | 66           | 1,243          | 18.83             | 3.46               | 7.48%                   | 1.85%                           | BabyFaceIT (181 comments)             |
| #75  | [Boston College](#f/bostoncollege)       | Boston College    | 64           | 1,562          | 24.41             | 3.56               | 8.32%                   | 0.51%                           | AchtungKessel (266 comments)          |
| #76  | [SMU](#f/smu)                            | SMU               | 63           | 1,565          | 24.84             | 3.87               | 9.2%                    | 1.15%                           | virus_apparatus (766 comments)        |
| #77  | [Tulane](#f/tulane)                      | Tulane            | 63           | 1,220          | 19.37             | 3.61               | 10.08%                  | 2.87%                           | jdprager (304 comments)               |
| #78  | [Wyoming](#f/wyoming)                    | Wyoming           | 62           | 1,956          | 31.55             | 3.37               | 15.29%                  | 1.58%                           | AZBiGii (552 comments)                |
| #79  | [Fresno State](#f/fresnostate)           | Fresno State      | 52           | 1,839          | 35.37             | 3.79               | 10.44%                  | 0.87%                           | eagledog (492 comments)               |
| #80  | [Georgia Southern](#f/georgiasouthern)   | Georgia Southern  | 52           | 977            | 18.79             | 3.99               | 13.2%                   | 2.76%                           | Gre-er (218 comments)                 |
| #81  | [San Diego State](#f/sandiegostate)      | San Diego State   | 51           | 1,342          | 26.31             | 4.07               | 7.23%                   | 2.16%                           | Brady_Hokes_Headset (343 comments)    |
| #82  | [UTSA](#f/utsa)                          | UTSA              | 51           | 1,231          | 24.14             | 3.50               | 15.27%                  | 2.44%                           | TheReal210Kiddd (277 comments)        |

## Top 10 most / least chatty flair

| Rank | Logo                                   | Flair            | Total Comments | Comments per User |
|:-----|:----------------|:----------------|:--------------|:-----------------|
| #1   | [Paper Bag](#l/paperbag)               | Paper Bag        | 7,756          | 76.0              |
| #2   | [Boise State](#f/boisestate)           | Boise State      | 7,289          | 52.8              |
| #3   | [Stanford](#f/stanford)                | Stanford         | 3,331          | 44.4              |
| #4   | [Utah](#f/utah)                        | Utah             | 17,691         | 44.2              |
| #5   | [BYU](#f/byu)                          | BYU              | 9,569          | 43.5              |
| #6   | [Washington State](#f/washingtonstate) | Washington State | 12,291         | 42.4              |
| #7   | [Florida State](#f/floridastate)       | Florida State    | 32,750         | 42.1              |
| #8   | [Louisville](#f/louisville)            | Louisville       | 6,544          | 41.9              |
| #9   | [Kentucky](#f/kentucky)                | Kentucky         | 12,199         | 40.9              |
| #10  | [Texas Tech](#f/texastech)             | Texas Tech       | 12,769         | 40.5              |

| Rank | Logo                                   | Flair            | Total Comments | Comments per User |
|:-----|:----------------|:----------------|:--------------|:-----------------|
| #1   | 🤡                                     | Unflaired        | 106,378        | 8.7               |
| #2   | [/r/CFB](#f//r/cfb)                    | /r/CFB           | 13,862         | 12.6              |
| #3   | [Georgia Southern](#f/georgiasouthern) | Georgia Southern | 977            | 18.8              |
| #4   | [Northwestern](#f/northwestern)        | Northwestern     | 1,243          | 18.8              |
| #5   | [Tulane](#f/tulane)                    | Tulane           | 1,220          | 19.4              |
| #6   | [Minnesota](#f/minnesota)              | Minnesota        | 6,207          | 19.5              |
| #7   | [James Madison](#f/jamesmadison)       | James Madison    | 1,542          | 20.3              |
| #8   | [Florida](#f/florida)                  | Florida          | 14,569         | 21.1              |
| #9   | [Nebraska](#f/nebraska)                | Nebraska         | 17,602         | 21.4              |
| #10  | [Syracuse](#f/syracuse)                | Syracuse         | 2,921          | 21.5              |

## Top 10 most / least swears

I scanned each comment for swear words, including all variations of
“fuck”, “wtf”, “ass”, “damn”, “shit”, “hell”, “bitch”, and “bastard”. I
also limited this to include only flairs with at least 2,500 total
comments in the dataset. Here are the most and least foul-mouthed
fanbases:

| Rank | Logo                               | Flair          | Total Comments | % Comments w/ Swears |
|:-----|:--------------|:--------------|:--------------|:--------------------|
| #1   | [Colorado State](#f/coloradostate) | Colorado State | 2,964          | 14.98%               |
| #2   | [Kentucky](#f/kentucky)            | Kentucky       | 12,199         | 13.95%               |
| #3   | [LSU](#f/lsu)                      | LSU            | 18,266         | 13.18%               |
| #4   | [Kansas](#f/kansas)                | Kansas         | 10,176         | 13.1%                |
| #5   | [West Virginia](#f/westvirginia)   | West Virginia  | 9,180          | 12.88%               |
| #6   | [NC State](#f/ncstate)             | NC State       | 8,672          | 12.71%               |
| #7   | [Texas Tech](#f/texastech)         | Texas Tech     | 12,769         | 12.51%               |
| #8   | [Ole Miss](#f/olemiss)             | Ole Miss       | 6,174          | 12.33%               |
| #9   | [Tennessee](#f/tennessee)          | Tennessee      | 19,319         | 12.14%               |
| #10  | [Boise State](#f/boisestate)       | Boise State    | 7,289          | 11.96%               |

| Rank | Logo                                     | Flair             | Total Comments | % Comments w/ Swears |
|:-----|:----------------|:----------------|:-------------|:-------------------|
| #1   | [BYU](#f/byu)                            | BYU               | 9,569          | 4.45%                |
| #2   | [Penn State](#f/pennstate)               | Penn State        | 20,612         | 7.53%                |
| #3   | [Stanford](#f/stanford)                  | Stanford          | 3,331          | 7.6%                 |
| #4   | [Virginia Tech](#f/virginiatech)         | Virginia Tech     | 14,286         | 7.71%                |
| #5   | [Iowa State](#f/iowastate)               | Iowa State        | 9,528          | 8.46%                |
| #6   | [Rutgers](#f/rutgers)                    | Rutgers           | 6,330          | 8.72%                |
| #7   | [Michigan](#f/michigan)                  | Michigan          | 56,842         | 8.99%                |
| #8   | [Arizona State](#f/arizonastate)         | Arizona State     | 5,013          | 9.08%                |
| #9   | [Mississippi State](#f/mississippistate) | Mississippi State | 3,685          | 9.12%                |
| #10  | [Clemson](#f/clemson)                    | Clemson           | 17,339         | 9.16%                |

Classic BYU.

## Most ref complaints per comment

I used a similar approach for this, scanning each comment for words
indicating a ref complaint. This isn’t perfect, because it misses
vaguely worded things like “oh, come on” and can include some false
positives like “the refs are doing a great job and I love them”, but
it’s close enough to do the job. Includes variations of terms like
“refs” (including “referees”, “refball”, etc.), “officials”, “flag”,
“whistle”, “the fix”, “rig”, etc. I also limited this to include only
flairs with at least 2,500 total comments in the dataset.

| Rank | Logo                        | Flair      | Total Comments | % Comments w/ Ref Mentions |
|:-----|:-----------|:-----------|:---------------|:--------------------------|
| #1   | [Syracuse](#f/syracuse)     | Syracuse   | 2,921          | 4.55%                      |
| #2   | [Kansas](#f/kansas)         | Kansas     | 10,176         | 3.37%                      |
| #3   | [Notre Dame](#f/notredame)  | Notre Dame | 28,945         | 3.21%                      |
| #4   | [California](#f/california) | California | 4,675          | 3.21%                      |
| #5   | [Arkansas](#f/arkansas)     | Arkansas   | 9,242          | 3.17%                      |
| #6   | [Miami](#f/miami)           | Miami      | 8,261          | 3.05%                      |
| #7   | [Texas A&M](#f/texasam)     | Texas A&M  | 23,059         | 3.02%                      |
| #8   | [Texas Tech](#f/texastech)  | Texas Tech | 12,769         | 2.98%                      |
| #9   | [Arizona](#f/arizona)       | Arizona    | 4,731          | 2.96%                      |
| #10  | [/r/CFB](#f//r/cfb)         | /r/CFB     | 13,862         | 2.92%                      |

# r/CFB 2023 Leaderboards

And finally, the big reveal: who is in the lead to claim this year’s
National Champion of posting? Here are the top 25 so far this season:

| Rank | Poster               | Primary Flair    | Total Comments | Unique Threads | % Comments w/ Swears | % Comments w/ Ref Complaints |
|:---|:-----------|:---------|:--------|--------:|:-----------|:----------------|
| #1   | BikiniATroll         | Penn State       | 2,083          |             94 | 6.1%                 | 1.58%                        |
| #2   | DiarrheaForDays      | Georgia          | 1,661          |             53 | 8.25%                | 2.71%                        |
| #3   | aMiracleAtJordanHare | Paper Bag        | 1,637          |             81 | 10.63%               | 2.87%                        |
| #4   | loyalsons4evertrue   | Iowa State       | 1,570          |            110 | 3.63%                | 0.96%                        |
| #5   | thebaylorweedinhaler | Baylor           | 1,539          |             90 | 10.79%               | 1.43%                        |
| #6   | Ajp_iii              | Florida State    | 1,515          |             35 | 5.02%                | 7.13%                        |
| #7   | F-18EBestHornet      | Washington State | 1,432          |             53 | 18.16%               | 1.54%                        |
| #8   | texas2089            | Florida State    | 1,373          |             58 | 17.84%               | 1.17%                        |
| #9   | FightingFarrier18    | Texas A&M        | 1,333          |             28 | 5.63%                | 2.48%                        |
| #10  | leakymemo            | Kentucky         | 1,327          |             68 | 30.75%               | 3.39%                        |
| #11  | Kodyaufan2           | Auburn           | 1,297          |             73 | 0.08%                | 1.77%                        |
| #12  | AeroStatikk          | BYU              | 1,201          |             57 | 1.5%                 | 1%                           |
| #13  | StoopSign            | Paper Bag        | 1,197          |             71 | 5.01%                | 2.67%                        |
| #14  | Jonjon428            | Unflaired        | 1,188          |             45 | 17.76%               | 2.95%                        |
| #15  | Competitive-Rise-789 | Georgia          | 1,160          |             46 | 10.43%               | 2.5%                         |
| #16  | Dead_Baby_Kicker     | Ohio State       | 1,159          |             42 | 3.71%                | 1.12%                        |
| #17  | Tarlcabot18          | UCF              | 1,159          |             31 | 6.82%                | 1.64%                        |
| #18  | MrNudeGuy            | Oklahoma         | 1,151          |             77 | 8.69%                | 2.43%                        |
| #19  | zenverak             | Georgia          | 1,150          |            128 | 3.83%                | 0.7%                         |
| #20  | WanderLeft           | Oklahoma         | 1,145          |             46 | 5.15%                | 0.17%                        |
| #21  | fightin_blue_hens    | Delaware         | 1,139          |             64 | 4.65%                | 2.55%                        |
| #22  | MD90\_\_             | Ohio State       | 1,124          |             19 | 2.14%                | 0.36%                        |
| #23  | Elbit_Curt_Sedni     | Michigan         | 1,118          |             51 | 1.7%                 | 4.29%                        |
| #24  | elgenie              | Iowa             | 1,102          |             41 | 3.72%                | 1.36%                        |
| #25  | indreams159          | LSU              | 1,083          |             80 | 5.36%                | 0.92%                        |

BikiniATroll maintains a comfortable lead, and is on pace to close out
the victory unless someone steps up. Special shoutout to leakymemo for
the impressive swear rate.

Additionally, here’s the official Sicko Award Top Ten, as it stands now:

| rank | author               | counted_flair      | n_unique_threads | n_comments |
|:-----|:-------------------|:------------------|----------------:|:----------|
| #1   | zenverak             | Georgia            |              128 | 1,150      |
| #2   | Muffinnnnnnn         | Florida State      |              123 | 623        |
| #3   | loyalsons4evertrue   | Iowa State         |              110 | 1,570      |
| #4   | Zloggt               | Illinois           |              104 | 381        |
| #5   | Sportacles           | Oregon             |               96 | 637        |
| #6   | BikiniATroll         | Penn State         |               94 | 2,083      |
| #7   | ddottay              | Notre Dame         |               93 | 791        |
| #8   | thebaylorweedinhaler | Baylor             |               90 | 1,539      |
| #9   | Treehumper69         | Jacksonville State |               85 | 238        |
| #10  | Please_PM_me_Uranus  | Michigan           |               84 | 433        |

This is still anyone’s game!

# Special research question – why are you so obsessed with us?

I got a few requests to get some numbers on how specific rivalries
manifest in game threads. Specifically, USC / OU fans and Notre Dame /
LSU fans wanted to know who was showing up to the others’ game threads
to talk shit more often.

I decided to calculate this with comments “per capita”, i.e. looking at
all of each team’s game threads and finding the flair which left the
most comments per unique users in the census. I’ve filtered out comments
from non-neutrals and the unflaired, and also limited it to just flairs
with at least 50 unique users.

## USC vs. Oklahoma

Here are the top 10 most common neutral commenters in USC threads:

``` r
rivals_sum |>
  filter(Team == "USC") |>
  knitr::kable(format = "pipe")
```

| Rank | Team | Commentor Flair                                     | Total Comments | Unique Users | Comments per Capita |
|:----|:----|:------------------------|:-----------|:----------|---------------:|
| #1   | USC  | [Oklahoma](#f/oklahoma) Oklahoma                    | 5,315          | 999          |                5.32 |
| #2   | USC  | [Oregon](#f/oregon) Oregon                          | 3,705          | 751          |                4.93 |
| #3   | USC  | [Utah](#f/utah) Utah                                | 1,717          | 400          |                4.29 |
| #4   | USC  | [UCLA](#f/ucla) UCLA                                | 701            | 208          |                3.37 |
| #5   | USC  | [Stanford](#f/stanford) Stanford                    | 244            | 75           |                3.25 |
| #6   | USC  | [San Diego State](#f/sandiegostate) San Diego State | 143            | 51           |                2.80 |
| #7   | USC  | [Paper Bag](#l/paperbag) Paper Bag                  | 268            | 102          |                2.63 |
| #8   | USC  | [Team Chaos](#l/chaos) Team Chaos                   | 242            | 93           |                2.60 |
| #9   | USC  | [Washington](#f/washington) Washington              | 1,180          | 538          |                2.19 |
| #10  | USC  | [Ohio State](#f/ohiostate) Ohio State               | 3,723          | 1,729        |                2.15 |

Here are the top 10 most common neutral commenters in Oklahoma threads:

``` r
rivals_sum |>
  filter(Team == "Oklahoma") |>
  knitr::kable(format = "pipe")
```

| Rank | Team     | Commentor Flair                                   | Total Comments | Unique Users | Comments per Capita |
|:----|:-------|:----------------------|:-----------|:----------|---------------:|
| #1   | Oklahoma | [Paper Bag](#l/paperbag) Paper Bag                | 317            | 102          |                3.11 |
| #2   | Oklahoma | [Baylor](#f/baylor) Baylor                        | 381            | 219          |                1.74 |
| #3   | Oklahoma | [TCU](#f/tcu) TCU                                 | 230            | 151          |                1.52 |
| #4   | Oklahoma | [Oklahoma State](#f/oklahomastate) Oklahoma State | 460            | 319          |                1.44 |
| #5   | Oklahoma | [UTSA](#f/utsa) UTSA                              | 71             | 51           |                1.39 |
| #6   | Oklahoma | [SMU](#f/smu) SMU                                 | 80             | 63           |                1.27 |
| #7   | Oklahoma | [Team Chaos](#l/chaos) Team Chaos                 | 98             | 93           |                1.05 |
| #8   | Oklahoma | [Texas Tech](#f/texastech) Texas Tech             | 280            | 315          |                0.89 |
| #9   | Oklahoma | [Miami](#f/miami) Miami                           | 219            | 265          |                0.83 |
| #10  | Oklahoma | [Florida State](#f/floridastate) Florida State    | 639            | 778          |                0.82 |

## LSU vs. Notre Dame

Here are the top 10 most common commenters in LSU threads:

``` r
rivals_sum |>
  filter(Team == "LSU") |>
  knitr::kable(format = "pipe")
```

| Rank | Team | Commentor Flair                                            | Total Comments | Unique Users | Comments per Capita |
|:----|:----|:-------------------------|:-----------|:---------|--------------:|
| #1   | LSU  | [Paper Bag](#l/paperbag) Paper Bag                         | 417            | 102          |                4.09 |
| #2   | LSU  | [Ole Miss](#f/olemiss) Ole Miss                            | 457            | 174          |                2.63 |
| #3   | LSU  | [Alabama](#f/alabama) Alabama                              | 1,781          | 961          |                1.85 |
| #4   | LSU  | [Tennessee](#f/tennessee) Tennessee                        | 1,169          | 656          |                1.78 |
| #5   | LSU  | [San Diego State](#f/sandiegostate) San Diego State        | 84             | 51           |                1.65 |
| #6   | LSU  | [Notre Dame](#f/notredame) Notre Dame                      | 1,316          | 824          |                1.60 |
| #7   | LSU  | [Georgia](#f/georgia) Georgia                              | 2,055          | 1,300        |                1.58 |
| #8   | LSU  | [Mississippi State](#f/mississippistate) Mississippi State | 171            | 114          |                1.50 |
| #9   | LSU  | [Florida](#f/florida) Florida                              | 1,001          | 689          |                1.45 |
| #10  | LSU  | [Miami](#f/miami) Miami                                    | 381            | 265          |                1.44 |

Here are the top 10 most common commenters in Notre Dame threads:

``` r
rivals_sum |>
  filter(Team == "Notre Dame") |>
  knitr::kable(format = "pipe")
```

| Rank | Team       | Commentor Flair                                   | Total Comments | Unique Users | Comments per Capita |
|:----|:--------|:---------------------|:-----------|:---------|--------------:|
| #1   | Notre Dame | [Paper Bag](#l/paperbag) Paper Bag                | 653            | 102          |                6.40 |
| #2   | Notre Dame | [Team Chaos](#l/chaos) Team Chaos                 | 362            | 93           |                3.89 |
| #3   | Notre Dame | [Michigan](#f/michigan) Michigan                  | 5,845          | 1,670        |                3.50 |
| #4   | Notre Dame | [Indiana](#f/indiana) Indiana                     | 491            | 155          |                3.17 |
| #5   | Notre Dame | [Oklahoma](#f/oklahoma) Oklahoma                  | 2,659          | 999          |                2.66 |
| #6   | Notre Dame | [Ohio State](#f/ohiostate) Ohio State             | 4,142          | 1,729        |                2.40 |
| #7   | Notre Dame | [Illinois](#f/illinois) Illinois                  | 479            | 243          |                1.97 |
| #8   | Notre Dame | [North Carolina](#f/northcarolina) North Carolina | 500            | 260          |                1.92 |
| #9   | Notre Dame | [Arizona State](#f/arizonastate) Arizona State    | 336            | 182          |                1.85 |
| #10  | Notre Dame | [Florida State](#f/floridastate) Florida State    | 1,399          | 778          |                1.80 |

------------------------------------------------------------------------

I hope you found this interesting! I’m going to keep this going for the
rest of the season, so please let me know if there’s anything else you’d
like me to track. Thanks for reading!
