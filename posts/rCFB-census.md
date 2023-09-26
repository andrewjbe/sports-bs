# What is this?

As a side project, I decided to scrape every comment from every game
thread this season. I’ve done this here and there in the past, but I’ve
never done it over a whole season. I’ve got my setup fully automated to
scrape every thread with “\[Game Thread\]” in the title at 4AM every
night, and it’s been a success over the first few weeks.

So, I thought it would be fun to share what I’ve got so far. I used the
data to come up with two things that I thought were kinda fun:

-   A “r/CFB flair census”, which counts the number of unique users with
    each primary flair (i.e. how big is each fanbase on the sub). I’ve
    always wondered about this.
    -   I also used the data to see which fanbase swears the least/most,
        who comments the most often, and a few other honorifics that you
        can either take pride in or mock your rivals for.
    -   You can also see each flair’s #1 most talkative fan! If you work
        hard, you could see your name up there at the end of the season.
-   A “r/CFB posting leaderboard”, which tracks which individual poster
    has commented in game threads the most throughout the whole season.
    Sadly I did not make the top 25.
    -   I also crowned the #1 sicko, as measured by unique number of
        threads participated in. Something else to aspire to!

# The data

So far, I’ve scraped 467 game threads with 721,132 total comments. I
actually also have the post game threads as well, which expands the
total number of comments to 806,595, but for now I’m just going to focus
on the game threads. In my mind it makes sense to treat them as separate
things, but if anyone wants to see any of this with the combined /
PGT-only data, just let me know.

Here’s a fun graph that shows how many comments people left per hour
throughout the whole season: [GRAPH: comments per
hour](https://imgur.com/8jnETSl)

Here’s a table with the top ten game threads so far this year by total
comments. Colorado seems to be popular for some reason, not sure why.

| Thread                    | Total Comments |
|:--------------------------|:---------------|
| Colorado State @ Colorado | 52,055         |
| Colorado @ Oregon         | 28,412         |
| Florida State vs LSU      | 26,206         |
| Ohio State @ Notre Dame   | 25,801         |
| Texas @ Alabama           | 25,407         |
| Nebraska @ Colorado       | 25,254         |
| Clemson @ Duke            | 25,009         |
| Colorado @ TCU            | 23,449         |
| Florida @ Utah            | 17,390         |
| Florida State @ Clemson   | 15,987         |

# r/CFB flair census

The first question I wanted to answer was “how big is each fanbase?” To
determine this, I took every username that left a comment in a game
thread this year, and classified them by their most recent primary
flair. Also, just to save space, I cut it off at flairs with 50+ unique
users. Feel free to ask if you’re curious about a smaller school’s
numbers.

The first table here shows the results, sorted by total unique users:

## Flair census

| Rank | Primary Flair     | Unique Users | Total Comments | Comments per User | Avg. Comment Score | % of Comments w/ Swears | % of Comments w/ Ref Complaints | Top Poster                            |
|:--|:-------|:-----|:------|:-------|:-------|:---------|:-----------|:-------------|
| #1   | Ohio State        | 1,472        | 34,168         | 23.21             | 3.98               | 7.97%                   | 2.3%                            | MD90\_\_ (737 comments)               |
| #2   | Michigan          | 1,351        | 34,084         | 25.23             | 4.02               | 7.62%                   | 1.95%                           | Elbit_Curt_Sedni (798 comments)       |
| #3   | Georgia           | 1,095        | 30,225         | 27.60             | 4.25               | 8.63%                   | 1.91%                           | Competitive-Rise-789 (836 comments)   |
| #4   | Texas             | 898          | 19,311         | 21.50             | 4.11               | 7.98%                   | 2.26%                           | StarvedRock314 (480 comments)         |
| #5   | /r/CFB            | 845          | 8,238          | 9.75              | 3.25               | 8.57%                   | 2.83%                           | IEatDeFish (645 comments)             |
| #6   | Alabama           | 818          | 17,300         | 21.15             | 3.58               | 8.83%                   | 1.84%                           | \_Suzushi (430 comments)              |
| #7   | Florida State     | 740          | 23,938         | 32.35             | 3.96               | 8.71%                   | 2.75%                           | texas2089 (945 comments)              |
| #8   | Oklahoma          | 740          | 20,551         | 27.77             | 4.65               | 8.73%                   | 3.35%                           | WanderLeft (770 comments)             |
| #9   | Nebraska          | 728          | 12,290         | 16.88             | 3.96               | 8%                      | 2.22%                           | daNish_brUin (363 comments)           |
| #10  | Notre Dame        | 721          | 19,290         | 26.75             | 4.69               | 8.21%                   | 3.74%                           | ddottay (604 comments)                |
| #11  | Penn State        | 664          | 14,274         | 21.50             | 4.66               | 6.34%                   | 1.85%                           | BikiniATroll (1,392 comments)         |
| #12  | Texas A&M         | 638          | 13,884         | 21.76             | 4.41               | 7.95%                   | 2.22%                           | FightingFarrier18 (838 comments)      |
| #13  | Florida           | 608          | 10,431         | 17.16             | 4.15               | 8.01%                   | 1.97%                           | ElSorcho (524 comments)               |
| #14  | Oregon            | 591          | 14,932         | 25.27             | 3.64               | 8.22%                   | 2.69%                           | Sportacles (478 comments)             |
| #15  | Tennessee         | 571          | 13,412         | 23.49             | 4.25               | 9.11%                   | 2.71%                           | EWall100 (521 comments)               |
| #16  | Clemson           | 526          | 12,013         | 22.84             | 4.27               | 7.34%                   | 2.03%                           | TigerTerrier (505 comments)           |
| #17  | LSU               | 502          | 9,340          | 18.61             | 3.87               | 9.09%                   | 2.22%                           | neovenator250 (425 comments)          |
| #18  | Iowa              | 497          | 13,026         | 26.21             | 4.16               | 8.94%                   | 2.24%                           | elgenie (673 comments)                |
| #19  | Michigan State    | 474          | 11,591         | 24.45             | 4.57               | 7.67%                   | 1.04%                           | twat_swat22 (565 comments)            |
| #20  | USC               | 470          | 12,688         | 27.00             | 4.29               | 8.03%                   | 2.12%                           | eosophobe (392 comments)              |
| #21  | Wisconsin         | 458          | 8,769          | 19.15             | 4.32               | 8.02%                   | 3.1%                            | guitmusic12 (256 comments)            |
| #22  | Auburn            | 442          | 9,889          | 22.37             | 4.00               | 7.84%                   | 1.81%                           | Kodyaufan2 (891 comments)             |
| #23  | South Carolina    | 404          | 9,418          | 23.31             | 4.05               | 7.68%                   | 1.84%                           | jthomas694 (447 comments)             |
| #24  | Washington        | 388          | 8,407          | 21.67             | 4.26               | 7.7%                    | 1.96%                           | TheGeeMan360 (504 comments)           |
| #25  | Colorado          | 356          | 7,405          | 20.80             | 3.95               | 9.22%                   | 1.26%                           | N3phewJemima (598 comments)           |
| #26  | Utah              | 352          | 11,647         | 33.09             | 4.57               | 9.14%                   | 1.98%                           | LogicianMission22 (697 comments)      |
| #27  | UCF               | 346          | 10,941         | 31.62             | 4.06               | 8.34%                   | 1.99%                           | Tarlcabot18 (1,000 comments)          |
| #28  | Virginia Tech     | 343          | 9,302          | 27.12             | 4.27               | 6.29%                   | 2.02%                           | macncheeseface (484 comments)         |
| #29  | Arkansas          | 328          | 6,168          | 18.80             | 4.24               | 8.88%                   | 3.53%                           | CommodoreN7 (306 comments)            |
| #30  | Minnesota         | 302          | 5,326          | 17.64             | 4.57               | 7.96%                   | 1.61%                           | bringbacktheaxe2 (339 comments)       |
| #31  | Oklahoma State    | 277          | 6,833          | 24.67             | 3.87               | 7.73%                   | 1.11%                           | huttts999 (408 comments)              |
| #32  | Texas Tech        | 276          | 8,192          | 29.68             | 4.17               | 9.09%                   | 3.53%                           | vassago77379 (384 comments)           |
| #33  | Purdue            | 272          | 6,132          | 22.54             | 3.90               | 8.22%                   | 2.64%                           | CoachRyanWalters (373 comments)       |
| #34  | Kansas            | 258          | 7,117          | 27.59             | 4.21               | 9.41%                   | 3.29%                           | indreams159 (861 comments)            |
| #35  | West Virginia     | 250          | 6,055          | 24.22             | 4.45               | 9.74%                   | 1.8%                            | fuckconcrete (638 comments)           |
| #36  | Washington State  | 246          | 8,063          | 32.78             | 4.08               | 8.22%                   | 1.86%                           | F-18EBestHornet (979 comments)        |
| #37  | Iowa State        | 245          | 5,622          | 22.95             | 3.86               | 7.15%                   | 1.41%                           | loyalsons4evertrue (646 comments)     |
| #38  | Georgia Tech      | 244          | 5,144          | 21.08             | 4.60               | 7.93%                   | 2.33%                           | kelsnuggets (350 comments)            |
| #39  | Miami             | 238          | 6,528          | 27.43             | 3.61               | 7.81%                   | 2.21%                           | TheBoook (695 comments)               |
| #40  | Oregon State      | 231          | 5,519          | 23.89             | 4.89               | 7.99%                   | 2.05%                           | Training-Joke-2120 (356 comments)     |
| #41  | North Carolina    | 230          | 5,859          | 25.47             | 4.03               | 8.91%                   | 2.22%                           | MayeForTheWin (358 comments)          |
| #42  | Illinois          | 211          | 4,220          | 20.00             | 3.98               | 7.91%                   | 2.42%                           | Puzzleheaded-Sky-111 (301 comments)   |
| #43  | NC State          | 206          | 5,751          | 27.92             | 4.18               | 9.29%                   | 2.02%                           | D1N2Y (570 comments)                  |
| #44  | Kentucky          | 201          | 7,330          | 36.47             | 3.66               | 10.57%                  | 2.4%                            | leakymemo (847 comments)              |
| #45  | Kansas State      | 196          | 3,581          | 18.27             | 4.18               | 8.57%                   | 2.65%                           | theurge14 (277 comments)              |
| #46  | Baylor            | 195          | 6,239          | 31.99             | 3.96               | 8.35%                   | 1.88%                           | thebaylorweedinhaler (1,152 comments) |
| #47  | Cincinnati        | 195          | 4,949          | 25.38             | 3.85               | 7.54%                   | 2.38%                           | Pitiful-Bumblebee775 (662 comments)   |
| #48  | BYU               | 186          | 6,058          | 32.57             | 4.57               | 3.98%                   | 1.63%                           | AeroStatikk (762 comments)            |
| #49  | California        | 174          | 3,512          | 20.18             | 4.89               | 7.32%                   | 3.76%                           | FrivolousMe (249 comments)            |
| #50  | Missouri          | 172          | 3,526          | 20.50             | 4.04               | 7.71%                   | 1.3%                            | superworriedspursfan (495 comments)   |
| #51  | UCLA              | 172          | 3,641          | 21.17             | 3.94               | 7.5%                    | 1.62%                           | bruhstevenson (421 comments)          |
| #52  | Arizona State     | 165          | 3,579          | 21.69             | 3.99               | 7.07%                   | 1.31%                           | DillyDillySzn (322 comments)          |
| #53  | Rutgers           | 165          | 4,447          | 26.95             | 4.23               | 6.7%                    | 2.65%                           | thibbs23 (578 comments)               |
| #54  | Pittsburgh        | 163          | 3,356          | 20.59             | 3.85               | 7.96%                   | 1.73%                           | Lovelylives (268 comments)            |
| #55  | Ole Miss          | 154          | 3,981          | 25.85             | 3.81               | 8.31%                   | 1.41%                           | HopefulReb76 (348 comments)           |
| #56  | Maryland          | 141          | 2,739          | 19.43             | 3.94               | 7.81%                   | 2.08%                           | Trujiogriz (352 comments)             |
| #57  | Indiana           | 139          | 3,202          | 23.04             | 4.03               | 8.84%                   | 1.56%                           | spacewalk\_\_ (223 comments)          |
| #58  | Virginia          | 125          | 2,645          | 21.16             | 4.43               | 7.33%                   | 1.7%                            | Eight_Trace (612 comments)            |
| #59  | Appalachian State | 123          | 2,987          | 24.28             | 3.87               | 8.5%                    | 1.67%                           | ChonkyWumpus (310 comments)           |
| #60  | TCU               | 123          | 2,615          | 21.26             | 4.15               | 8.49%                   | 2.1%                            | blakethegr8 (198 comments)            |
| #61  | Houston           | 120          | 3,062          | 25.52             | 4.45               | 8.88%                   | 1.53%                           | Key_Spinach (378 comments)            |
| #62  | Boise State       | 118          | 4,392          | 37.22             | 3.39               | 9.77%                   | 1.64%                           | -Gnostic28 (354 comments)             |
| #63  | Louisville        | 116          | 3,696          | 31.86             | 4.17               | 6.87%                   | 2.73%                           | LukarWarrior (358 comments)           |
| #64  | Syracuse          | 109          | 1,705          | 15.64             | 4.32               | 7.39%                   | 4.05%                           | JohnWickisBehindU (154 comments)      |
| #65  | Mississippi State | 105          | 2,650          | 25.24             | 3.76               | 7.81%                   | 2.3%                            | Ok_Swimmer634 (270 comments)          |
| #66  | Arizona           | 104          | 2,191          | 21.07             | 3.79               | 7.9%                    | 2.28%                           | crownebeach (270 comments)            |
| #67  | Paper Bag         | 93           | 5,097          | 54.81             | 3.93               | 7.46%                   | 2.35%                           | aMiracleAtJordanHare (869 comments)   |
| #68  | Duke              | 88           | 1,640          | 18.64             | 5.06               | 5.73%                   | 1.28%                           | theiwc0303 (153 comments)             |
| #69  | USF               | 87           | 1,126          | 12.94             | 4.41               | 7.02%                   | 1.24%                           | NebraskaAvenue (94 comments)          |
| #70  | Team Chaos        | 82           | 1,513          | 18.45             | 4.12               | 9.78%                   | 1.65%                           | Live_Mathematician43 (159 comments)   |
| #71  | Colorado State    | 81           | 2,079          | 25.67             | 6.12               | 11.26%                  | 0.91%                           | Staind075 (259 comments)              |
| #72  | James Madison     | 67           | 1,161          | 17.33             | 5.02               | 6.89%                   | 3.36%                           | AnarchNova (123 comments)             |
| #73  | Stanford          | 64           | 2,061          | 32.20             | 4.21               | 6.11%                   | 1.55%                           | InVodkaVeritas (590 comments)         |
| #74  | Boston College    | 60           | 1,136          | 18.93             | 3.80               | 7.83%                   | 0.53%                           | AchtungKessel (202 comments)          |
| #75  | SMU               | 57           | 1,185          | 20.79             | 3.96               | 7.93%                   | 1.35%                           | virus_apparatus (499 comments)        |
| #76  | Northwestern      | 56           | 873            | 15.59             | 3.62               | 5.73%                   | 1.72%                           | KushDingies (121 comments)            |
| #77  | Tulane            | 54           | 929            | 17.20             | 3.48               | 7.64%                   | 2.91%                           | jdprager (286 comments)               |
| #78  | Wyoming           | 53           | 1,017          | 19.19             | 3.30               | 11.31%                  | 1.28%                           | amoss_303 (145 comments)              |

Alabama is only putting up a paltry 3.58 upvotes per post. Is the Saban
era finally over?

## Top 10 most / least chatty flair

| Rank | Flair            | Total Comments | Comments per User |
|:-----|:-----------------|:---------------|:------------------|
| #1   | Paper Bag        | 5,097          | 54.8              |
| #2   | Boise State      | 4,392          | 37.2              |
| #3   | Kentucky         | 7,330          | 36.5              |
| #4   | Utah             | 11,647         | 33.1              |
| #5   | Washington State | 8,063          | 32.8              |
| #6   | BYU              | 6,058          | 32.6              |
| #7   | Florida State    | 23,938         | 32.3              |
| #8   | Stanford         | 2,061          | 32.2              |
| #9   | Baylor           | 6,239          | 32.0              |
| #10  | Louisville       | 3,696          | 31.9              |

| Rank | Flair         | Total Comments | Comments per User |
|:-----|:--------------|:---------------|:------------------|
| #1   | Unflaired     | 55,996         | 6.1               |
| #2   | /r/CFB        | 8,238          | 9.7               |
| #3   | USF           | 1,126          | 12.9              |
| #4   | Northwestern  | 873            | 15.6              |
| #5   | Syracuse      | 1,705          | 15.6              |
| #6   | Nebraska      | 12,290         | 16.9              |
| #7   | Florida       | 10,431         | 17.2              |
| #8   | Tulane        | 929            | 17.2              |
| #9   | James Madison | 1,161          | 17.3              |
| #10  | Minnesota     | 5,326          | 17.6              |

## Top 10 most / least swears

| Rank | Flair          | Total Comments | % Comments w/ Swears |
|:-----|:---------------|:---------------|:---------------------|
| #1   | Wyoming        | 1,017          | 11.31%               |
| #2   | Colorado State | 2,079          | 11.26%               |
| #3   | Kentucky       | 7,330          | 10.57%               |
| #4   | Team Chaos     | 1,513          | 9.78%                |
| #5   | Boise State    | 4,392          | 9.77%                |
| #6   | West Virginia  | 6,055          | 9.74%                |
| #7   | Kansas         | 7,117          | 9.41%                |
| #8   | NC State       | 5,751          | 9.29%                |
| #9   | Colorado       | 7,405          | 9.22%                |
| #10  | Utah           | 11,647         | 9.14%                |

| Rank | Flair         | Total Comments | % Comments w/ Swears |
|:-----|:--------------|:---------------|:---------------------|
| #1   | BYU           | 6,058          | 3.98%                |
| #2   | Northwestern  | 873            | 5.73%                |
| #3   | Duke          | 1,640          | 5.73%                |
| #4   | Stanford      | 2,061          | 6.11%                |
| #5   | Virginia Tech | 9,302          | 6.29%                |
| #6   | Penn State    | 14,274         | 6.34%                |
| #7   | Rutgers       | 4,447          | 6.7%                 |
| #8   | Louisville    | 3,696          | 6.87%                |
| #9   | James Madison | 1,161          | 6.89%                |
| #10  | USF           | 1,126          | 7.02%                |

Classic BYU.

## Most ref complaints per comment

| Rank | Flair         | Total Comments | % Comments w/ Ref Mentions |
|:-----|:--------------|:---------------|:---------------------------|
| #1   | Syracuse      | 1,705          | 4.05%                      |
| #2   | California    | 3,512          | 3.76%                      |
| #3   | Notre Dame    | 19,290         | 3.74%                      |
| #4   | Arkansas      | 6,168          | 3.53%                      |
| #5   | Texas Tech    | 8,192          | 3.53%                      |
| #6   | James Madison | 1,161          | 3.36%                      |
| #7   | Oklahoma      | 20,551         | 3.35%                      |
| #8   | Kansas        | 7,117          | 3.29%                      |
| #9   | Wisconsin     | 8,769          | 3.1%                       |
| #10  | Tulane        | 929            | 2.91%                      |

I actually checked before last week, and Oklahoma rocketed up from ~50th
place to the top ten in the Cincinnati game alone.

# r/CFB 2023 Leaderboards

And finally, the big reveal: who is in the lead to claim this year’s
National Champion of posting? Here are the top 25 so far this season:

| Rank | Poster               | Primary Flair    | Total Comments | Unique Threads | % Comments w/ Swears | % Comments w/ Ref Complaints |
|:---|:-----------|:---------|:--------|--------:|:-----------|:----------------|
| #1   | BikiniATroll         | Penn State       | 1,392          |             66 | 6.47%                | 1.22%                        |
| #2   | thebaylorweedinhaler | Baylor           | 1,152          |             61 | 8.77%                | 1.04%                        |
| #3   | Tarlcabot18          | UCF              | 1,000          |             23 | 6%                   | 1.8%                         |
| #4   | F-18EBestHornet      | Washington State | 979            |             36 | 11.54%               | 1.43%                        |
| #5   | texas2089            | Florida State    | 945            |             35 | 12.28%               | 1.27%                        |
| #6   | Kodyaufan2           | Auburn           | 891            |             48 | 0.11%                | 2.13%                        |
| #7   | aMiracleAtJordanHare | Paper Bag        | 869            |             32 | 8.75%                | 3.11%                        |
| #8   | Ajp_iii              | Florida State    | 867            |             16 | 4.04%                | 5.54%                        |
| #9   | indreams159          | Kansas           | 861            |             60 | 4.76%                | 0.7%                         |
| #10  | leakymemo            | Kentucky         | 847            |             38 | 25.74%               | 3.07%                        |
| #11  | FightingFarrier18    | Texas A&M        | 838            |             18 | 4.06%                | 2.03%                        |
| #12  | Competitive-Rise-789 | Georgia          | 836            |             33 | 6.1%                 | 2.15%                        |
| #13  | DiarrheaForDays      | Georgia          | 813            |             32 | 6.64%                | 1.72%                        |
| #14  | Elbit_Curt_Sedni     | Michigan         | 798            |             33 | 2.01%                | 5.14%                        |
| #15  | WanderLeft           | Oklahoma         | 770            |             27 | 2.86%                | 0.13%                        |
| #16  | AeroStatikk          | BYU              | 762            |             29 | 1.57%                | 0.66%                        |
| #17  | dankblonde           | Kentucky         | 745            |             12 | 6.04%                | 2.01%                        |
| #18  | Jonjon428            | Unflaired        | 742            |             23 | 17.12%               | 2.83%                        |
| #19  | MD90\_\_             | Ohio State       | 737            |             12 | 2.31%                | 0.14%                        |
| #20  | avboden              | Washington State | 730            |              8 | 12.05%               | 1.51%                        |
| #21  | fightin_blue_hens    | Delaware         | 730            |             40 | 3.56%                | 2.6%                         |
| #22  | LogicianMission22    | Utah             | 697            |             49 | 14.06%               | 0.29%                        |
| #23  | TheBoook             | Miami            | 695            |             20 | 12.52%               | 4.6%                         |
| #24  | StoopSign            | Paper Bag        | 684            |             41 | 5.7%                 | 3.22%                        |
| #25  | Dead_Baby_Kicker     | Ohio State       | 682            |             26 | 3.67%                | 1.61%                        |
| #26  | thefishwhisperer1    | UCF              | 682            |             26 | 4.84%                | 1.32%                        |

Additionally, here’s the official Sicko Award Top Ten, as it stands now:

| rank | author               | counted_flair | n_unique_threads | n_comments |
|:-----|:---------------------|:--------------|-----------------:|-----------:|
| #1   | Muffinnnnnnn         | Florida State |               79 |        375 |
| #2   | BikiniATroll         | Penn State    |               66 |       1392 |
| #3   | Sportacles           | Oregon        |               63 |        478 |
| #4   | Zloggt               | Illinois      |               62 |        222 |
| #5   | thebaylorweedinhaler | Baylor        |               61 |       1152 |
| #6   | ddottay              | Notre Dame    |               61 |        604 |
| #7   | indreams159          | Kansas        |               60 |        861 |
| #8   | loyalsons4evertrue   | Iowa State    |               59 |        646 |
| #9   | zenverak             | Georgia       |               59 |        525 |
| #10  | Mythrandir24         | Delta Bowl    |               59 |        144 |

------------------------------------------------------------------------

I hope you found this interesting! I’m going to keep this going for the
rest of the season, so please let me know if there’s anything else you’d
like me to track. Thanks for reading!
