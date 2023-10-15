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

So far, I’ve scraped 659 game threads with 1,001,197 total comments. I
actually also have the post game threads as well, which expands the
total number of comments to 1,120,736, but for now I’m just going to
focus on the game threads. In my mind it makes sense to treat them as
separate things, but if anyone wants to see any of this with the
combined / PGT-only data, just let me know.

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
| Texas vs Oklahoma         | 25,245         |
| Clemson @ Duke            | 25,009         |
| Colorado @ TCU            | 23,449         |
| Arizona @ USC             | 19,545         |

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
| #1   | [Ohio State](#f/ohiostate)               | Ohio State        | 1,659        | 47,948         | 28.90             | 3.89               | 10.24%                  | 2.58%                           | MD90\_\_ (1,061 comments)             |
| #2   | [Michigan](#f/michigan)                  | Michigan          | 1,614        | 50,506         | 31.29             | 3.98               | 9.01%                   | 1.77%                           | Elbit_Curt_Sedni (1,039 comments)     |
| #3   | [Georgia](#f/georgia)                    | Georgia           | 1,264        | 45,426         | 35.94             | 4.16               | 11.03%                  | 2.1%                            | DiarrheaForDays (1,357 comments)      |
| #4   | [Texas](#f/texas)                        | Texas             | 1,054        | 28,166         | 26.72             | 3.96               | 10.3%                   | 2.3%                            | cn0285 (702 comments)                 |
| #5   | [/r/CFB](#f//r/cfb)                      | /r/CFB            | 1,012        | 11,528         | 11.39             | 3.09               | 11.17%                  | 2.76%                           | IEatDeFish (661 comments)             |
| #6   | [Oklahoma](#f/oklahoma)                  | Oklahoma          | 947          | 35,490         | 37.48             | 4.58               | 11.31%                  | 2.96%                           | WanderLeft (1,064 comments)           |
| #7   | [Alabama](#f/alabama)                    | Alabama           | 941          | 24,688         | 26.24             | 3.63               | 11.39%                  | 2.32%                           | Dellav8r (624 comments)               |
| #8   | [Nebraska](#f/nebraska)                  | Nebraska          | 829          | 17,556         | 21.18             | 3.99               | 10.23%                  | 2%                              | Panchoisthedog (460 comments)         |
| #9   | [Notre Dame](#f/notredame)               | Notre Dame        | 797          | 25,371         | 31.83             | 4.47               | 11.26%                  | 3.44%                           | ddottay (749 comments)                |
| #10  | [Florida State](#f/floridastate)         | Florida State     | 773          | 29,549         | 38.23             | 3.91               | 11.04%                  | 2.93%                           | texas2089 (1,206 comments)            |
| #11  | [Texas A&M](#f/texasam)                  | Texas A&M         | 762          | 20,937         | 27.48             | 4.26               | 10.57%                  | 2.92%                           | FightingFarrier18 (1,215 comments)    |
| #12  | [Penn State](#f/pennstate)               | Penn State        | 727          | 18,609         | 25.60             | 4.55               | 7.61%                   | 1.77%                           | BikiniATroll (1,794 comments)         |
| #13  | [Florida](#f/florida)                    | Florida           | 662          | 12,988         | 19.62             | 4.16               | 10.38%                  | 2.16%                           | ElSorcho (524 comments)               |
| #14  | [Oregon](#f/oregon)                      | Oregon            | 654          | 21,751         | 33.26             | 3.66               | 10.28%                  | 2.58%                           | Sportacles (637 comments)             |
| #15  | [Tennessee](#f/tennessee)                | Tennessee         | 627          | 16,546         | 26.39             | 4.26               | 11.93%                  | 2.62%                           | EWall100 (622 comments)               |
| #16  | [LSU](#f/lsu)                            | LSU               | 591          | 15,536         | 26.29             | 3.75               | 13.72%                  | 2.75%                           | BobbyLite94 (578 comments)            |
| #17  | [Clemson](#f/clemson)                    | Clemson           | 568          | 16,646         | 29.31             | 4.27               | 9.14%                   | 2.1%                            | bigmike1877 (686 comments)            |
| #18  | [USC](#f/usc)                            | USC               | 564          | 18,752         | 33.25             | 3.93               | 9.8%                    | 2.41%                           | eosophobe (474 comments)              |
| #19  | [Iowa](#f/iowa)                          | Iowa              | 553          | 18,292         | 33.08             | 4.11               | 11.23%                  | 1.97%                           | elgenie (1,035 comments)              |
| #20  | [Michigan State](#f/michiganstate)       | Michigan State    | 510          | 15,480         | 30.35             | 4.46               | 9.79%                   | 1.08%                           | twat_swat22 (847 comments)            |
| #21  | [Wisconsin](#f/wisconsin)                | Wisconsin         | 487          | 10,633         | 21.83             | 4.14               | 9.76%                   | 2.97%                           | OldVeterinarian9 (352 comments)       |
| #22  | [Auburn](#f/auburn)                      | Auburn            | 480          | 12,141         | 25.29             | 3.99               | 9.46%                   | 1.7%                            | Kodyaufan2 (1,139 comments)           |
| #23  | [South Carolina](#f/southcarolina)       | South Carolina    | 436          | 12,435         | 28.52             | 3.92               | 9.59%                   | 1.81%                           | jthomas694 (573 comments)             |
| #24  | [Washington](#f/washington)              | Washington        | 428          | 12,108         | 28.29             | 4.18               | 9.42%                   | 2.1%                            | Pollaski (712 comments)               |
| #25  | [UCF](#f/ucf)                            | UCF               | 392          | 14,284         | 36.44             | 4.09               | 11.22%                  | 1.95%                           | Tarlcabot18 (1,098 comments)          |
| #26  | [Utah](#f/utah)                          | Utah              | 392          | 16,009         | 40.84             | 4.31               | 11.67%                  | 2.17%                           | NeuroTheManiacal (949 comments)       |
| #27  | [Colorado](#f/colorado)                  | Colorado          | 386          | 8,746          | 22.66             | 3.76               | 11.33%                  | 1.5%                            | N3phewJemima (716 comments)           |
| #28  | [Virginia Tech](#f/virginiatech)         | Virginia Tech     | 377          | 12,835         | 34.05             | 4.25               | 7.64%                   | 2.22%                           | macncheeseface (594 comments)         |
| #29  | [Arkansas](#f/arkansas)                  | Arkansas          | 365          | 8,412          | 23.05             | 4.11               | 11.52%                  | 3.32%                           | CommodoreN7 (403 comments)            |
| #30  | [Minnesota](#f/minnesota)                | Minnesota         | 317          | 6,058          | 19.11             | 4.49               | 10.65%                  | 1.62%                           | bringbacktheaxe2 (364 comments)       |
| #31  | [Oklahoma State](#f/oklahomastate)       | Oklahoma State    | 309          | 8,504          | 27.52             | 3.93               | 9.38%                   | 1.13%                           | huttts999 (589 comments)              |
| #32  | [Texas Tech](#f/texastech)               | Texas Tech        | 307          | 11,173         | 36.39             | 4.20               | 11.79%                  | 3.15%                           | FuckTheLonghorns (444 comments)       |
| #33  | [Purdue](#f/purdue)                      | Purdue            | 291          | 7,997          | 27.48             | 3.87               | 10.59%                  | 2.55%                           | CoachRyanWalters (617 comments)       |
| #34  | [Kentucky](#f/kentucky)                  | Kentucky          | 285          | 11,102         | 38.95             | 3.70               | 13.42%                  | 2.16%                           | leakymemo (1,142 comments)            |
| #35  | [Kansas](#f/kansas)                      | Kansas            | 283          | 8,794          | 31.07             | 4.03               | 12.34%                  | 3.04%                           | jayhawk_cowboy (512 comments)         |
| #36  | [West Virginia](#f/westvirginia)         | West Virginia     | 281          | 7,891          | 28.08             | 4.42               | 12.76%                  | 1.89%                           | fuckconcrete (833 comments)           |
| #37  | [Washington State](#f/washingtonstate)   | Washington State  | 280          | 11,177         | 39.92             | 3.91               | 10.99%                  | 2.03%                           | F-18EBestHornet (1,385 comments)      |
| #38  | [Georgia Tech](#f/georgiatech)           | Georgia Tech      | 277          | 7,290          | 26.32             | 4.64               | 10.82%                  | 2.09%                           | thank_burdell (445 comments)          |
| #39  | [Iowa State](#f/iowastate)               | Iowa State        | 277          | 8,079          | 29.17             | 3.82               | 8.87%                   | 1.41%                           | loyalsons4evertrue (1,211 comments)   |
| #40  | [Oregon State](#f/oregonstate)           | Oregon State      | 266          | 8,613          | 32.38             | 4.58               | 10.67%                  | 2.26%                           | Training-Joke-2120 (653 comments)     |
| #41  | [Miami](#f/miami)                        | Miami             | 252          | 7,618          | 30.23             | 3.72               | 11.47%                  | 2.97%                           | TheBoook (871 comments)               |
| #42  | [North Carolina](#f/northcarolina)       | North Carolina    | 244          | 7,272          | 29.80             | 3.94               | 10.92%                  | 2.41%                           | MayeForTheWin (527 comments)          |
| #43  | [Illinois](#f/illinois)                  | Illinois          | 231          | 5,786          | 25.05             | 4.00               | 9.52%                   | 2.47%                           | Puzzleheaded-Sky-111 (414 comments)   |
| #44  | [NC State](#f/ncstate)                   | NC State          | 226          | 7,866          | 34.81             | 4.12               | 12.52%                  | 2.05%                           | D1N2Y (736 comments)                  |
| #45  | [Baylor](#f/baylor)                      | Baylor            | 219          | 8,318          | 37.98             | 3.86               | 10.77%                  | 1.76%                           | thebaylorweedinhaler (1,461 comments) |
| #46  | [Missouri](#f/missouri)                  | Missouri          | 217          | 5,934          | 27.35             | 3.78               | 9.93%                   | 2.31%                           | superworriedspursfan (674 comments)   |
| #47  | [Cincinnati](#f/cincinnati)              | Cincinnati        | 214          | 6,216          | 29.05             | 3.82               | 10.14%                  | 2.08%                           | Pitiful-Bumblebee775 (662 comments)   |
| #48  | [Kansas State](#f/kansasstate)           | Kansas State      | 214          | 4,791          | 22.39             | 4.11               | 10.75%                  | 2.38%                           | theurge14 (343 comments)              |
| #49  | [BYU](#f/byu)                            | BYU               | 210          | 8,300          | 39.52             | 4.21               | 4.39%                   | 1.54%                           | AeroStatikk (1,017 comments)          |
| #50  | [UCLA](#f/ucla)                          | UCLA              | 196          | 5,276          | 26.92             | 4.04               | 9.65%                   | 2.43%                           | bruhstevenson (428 comments)          |
| #51  | [California](#f/california)              | California        | 192          | 4,224          | 22.00             | 4.65               | 9.66%                   | 3.43%                           | FrivolousMe (327 comments)            |
| #52  | [Arizona State](#f/arizonastate)         | Arizona State     | 181          | 4,750          | 26.24             | 3.96               | 9.07%                   | 1.77%                           | DillyDillySzn (529 comments)          |
| #53  | [Maryland](#f/maryland)                  | Maryland          | 180          | 4,796          | 26.64             | 3.87               | 9.76%                   | 1.73%                           | SEND_ME_YOUR_CAULK (456 comments)     |
| #54  | [Rutgers](#f/rutgers)                    | Rutgers           | 176          | 5,570          | 31.65             | 4.07               | 8.24%                   | 2.44%                           | thibbs23 (739 comments)               |
| #55  | [Ole Miss](#f/olemiss)                   | Ole Miss          | 173          | 5,904          | 34.13             | 3.55               | 12.4%                   | 2.76%                           | HopefulReb76 (629 comments)           |
| #56  | [Pittsburgh](#f/pittsburgh)              | Pittsburgh        | 167          | 4,019          | 24.07             | 3.88               | 10.13%                  | 1.57%                           | Lovelylives (307 comments)            |
| #57  | [Louisville](#f/louisville)              | Louisville        | 150          | 5,870          | 39.13             | 3.88               | 10.02%                  | 2.4%                            | LukarWarrior (623 comments)           |
| #58  | [Indiana](#f/indiana)                    | Indiana           | 147          | 4,124          | 28.05             | 3.91               | 11.74%                  | 1.87%                           | spacewalk\_\_ (267 comments)          |
| #59  | [TCU](#f/tcu)                            | TCU               | 144          | 3,766          | 26.15             | 4.06               | 11.6%                   | 1.83%                           | an0m_x (316 comments)                 |
| #60  | [Virginia](#f/virginia)                  | Virginia          | 137          | 3,260          | 23.80             | 4.60               | 9.29%                   | 1.84%                           | Eight_Trace (730 comments)            |
| #61  | [Boise State](#f/boisestate)             | Boise State       | 134          | 6,084          | 45.40             | 3.55               | 11.7%                   | 1.38%                           | -Gnostic28 (527 comments)             |
| #62  | [Syracuse](#f/syracuse)                  | Syracuse          | 134          | 2,749          | 20.51             | 4.02               | 11.97%                  | 4.55%                           | JohnWickisBehindU (228 comments)      |
| #63  | [Arizona](#f/arizona)                    | Arizona           | 132          | 3,892          | 29.48             | 3.66               | 12%                     | 3.34%                           | crownebeach (338 comments)            |
| #64  | [Appalachian State](#f/appalachianstate) | Appalachian State | 130          | 3,683          | 28.33             | 3.74               | 10.72%                  | 1.47%                           | ChonkyWumpus (334 comments)           |
| #65  | [Houston](#f/houston)                    | Houston           | 130          | 3,839          | 29.53             | 4.03               | 11.38%                  | 1.69%                           | Key_Spinach (500 comments)            |
| #66  | [Mississippi State](#f/mississippistate) | Mississippi State | 115          | 3,468          | 30.16             | 3.79               | 9.08%                   | 2.16%                           | Ok_Swimmer634 (460 comments)          |
| #67  | [Paper Bag](#f/paperbag)                 | Paper Bag         | 99           | 7,922          | 80.02             | 3.57               | 9.71%                   | 2.26%                           | aMiracleAtJordanHare (1,441 comments) |
| #68  | [Duke](#f/duke)                          | Duke              | 97           | 2,114          | 21.79             | 4.78               | 7.38%                   | 1.51%                           | AnotherUnfunnyName (168 comments)     |
| #69  | [USF](#f/usf)                            | USF               | 97           | 1,673          | 17.25             | 4.32               | 8.79%                   | 1.26%                           | NebraskaAvenue (151 comments)         |
| #70  | [Team Chaos](#f/teamchaos)               | Team Chaos        | 91           | 2,249          | 24.71             | 3.87               | 11.34%                  | 1.69%                           | UniqueTonight (177 comments)          |
| #71  | [Colorado State](#f/coloradostate)       | Colorado State    | 84           | 2,424          | 28.86             | 6.06               | 14.48%                  | 0.83%                           | Staind075 (328 comments)              |
| #72  | [James Madison](#f/jamesmadison)         | James Madison     | 72           | 1,364          | 18.94             | 4.89               | 8.06%                   | 3.74%                           | AnarchNova (154 comments)             |
| #73  | [Stanford](#f/stanford)                  | Stanford          | 68           | 2,571          | 37.81             | 4.15               | 6.88%                   | 1.36%                           | InVodkaVeritas (809 comments)         |
| #74  | [Boston College](#f/bostoncollege)       | Boston College    | 62           | 1,499          | 24.18             | 3.57               | 8.54%                   | 0.53%                           | AchtungKessel (266 comments)          |
| #75  | [Northwestern](#f/northwestern)          | Northwestern      | 61           | 1,161          | 19.03             | 3.51               | 7.41%                   | 1.72%                           | BabyFaceIT (160 comments)             |
| #76  | [SMU](#f/smu)                            | SMU               | 58           | 1,394          | 24.03             | 3.76               | 9.4%                    | 1.15%                           | virus_apparatus (724 comments)        |
| #77  | [Wyoming](#f/wyoming)                    | Wyoming           | 58           | 1,613          | 27.81             | 3.41               | 14.45%                  | 1.43%                           | AZBiGii (383 comments)                |
| #78  | [Tulane](#f/tulane)                      | Tulane            | 57           | 1,033          | 18.12             | 3.36               | 9.87%                   | 3.1%                            | jdprager (291 comments)               |
| #79  | [Fresno State](#f/fresnostate)           | Fresno State      | 53           | 1,587          | 29.94             | 3.93               | 10.33%                  | 0.88%                           | eagledog (401 comments)               |
| #80  | [UTSA](#f/utsa)                          | UTSA              | 50           | 1,109          | 22.18             | 3.44               | 15.42%                  | 2.71%                           | TheReal210Kiddd (277 comments)        |


## Top 10 most / least chatty flair

| Rank | Logo                                   | Flair            | Total Comments | Comments per User |
|:-----|:----------------|:----------------|:--------------|:-----------------|
| #1   | [Paper Bag](#f/paperbag)               | Paper Bag        | 7,922          | 80.0              |
| #2   | [Boise State](#f/boisestate)           | Boise State      | 6,084          | 45.4              |
| #3   | [Utah](#f/utah)                        | Utah             | 16,009         | 40.8              |
| #4   | [Washington State](#f/washingtonstate) | Washington State | 11,177         | 39.9              |
| #5   | [BYU](#f/byu)                          | BYU              | 8,300          | 39.5              |
| #6   | [Louisville](#f/louisville)            | Louisville       | 5,870          | 39.1              |
| #7   | [Kentucky](#f/kentucky)                | Kentucky         | 11,102         | 39.0              |
| #8   | [Florida State](#f/floridastate)       | Florida State    | 29,549         | 38.2              |
| #9   | [Baylor](#f/baylor)                    | Baylor           | 8,318          | 38.0              |
| #10  | [Stanford](#f/stanford)                | Stanford         | 2,571          | 37.8              |

| Rank | Logo                             | Flair         | Total Comments | Comments per User |
|:------|:---------------|:---------------|:----------------|:-------------------|
| #1   | 🤡                               | Unflaired     | 77,789         | 7.1               |
| #2   | [/r/CFB](#f//r/cfb)              | /r/CFB        | 11,528         | 11.4              |
| #3   | [USF](#f/usf)                    | USF           | 1,673          | 17.2              |
| #4   | [Tulane](#f/tulane)              | Tulane        | 1,033          | 18.1              |
| #5   | [James Madison](#f/jamesmadison) | James Madison | 1,364          | 18.9              |
| #6   | [Northwestern](#f/northwestern)  | Northwestern  | 1,161          | 19.0              |
| #7   | [Minnesota](#f/minnesota)        | Minnesota     | 6,058          | 19.1              |
| #8   | [Florida](#f/florida)            | Florida       | 12,988         | 19.6              |
| #9   | [Syracuse](#f/syracuse)          | Syracuse      | 2,749          | 20.5              |
| #10  | [Nebraska](#f/nebraska)          | Nebraska      | 17,556         | 21.2              |

## Top 10 most / least swears

| Rank | Logo                               | Flair          | Total Comments | % Comments w/ Swears |
|:-----|:--------------|:--------------|:--------------|:--------------------|
| #1   | [UTSA](#f/utsa)                    | UTSA           | 1,109          | 15.42%               |
| #2   | [Colorado State](#f/coloradostate) | Colorado State | 2,424          | 14.48%               |
| #3   | [Wyoming](#f/wyoming)              | Wyoming        | 1,613          | 14.45%               |
| #4   | [LSU](#f/lsu)                      | LSU            | 15,536         | 13.72%               |
| #5   | [Kentucky](#f/kentucky)            | Kentucky       | 11,102         | 13.42%               |
| #6   | [West Virginia](#f/westvirginia)   | West Virginia  | 7,891          | 12.76%               |
| #7   | [NC State](#f/ncstate)             | NC State       | 7,866          | 12.52%               |
| #8   | [Ole Miss](#f/olemiss)             | Ole Miss       | 5,904          | 12.4%                |
| #9   | [Kansas](#f/kansas)                | Kansas         | 8,794          | 12.34%               |
| #10  | [Arizona](#f/arizona)              | Arizona        | 3,892          | 12%                  |

| Rank | Logo                               | Flair          | Total Comments | % Comments w/ Swears |
|:-----|:--------------|:--------------|:--------------|:--------------------|
| #1   | [BYU](#f/byu)                      | BYU            | 8,300          | 4.39%                |
| #2   | [Stanford](#f/stanford)            | Stanford       | 2,571          | 6.88%                |
| #3   | [Duke](#f/duke)                    | Duke           | 2,114          | 7.38%                |
| #4   | [Northwestern](#f/northwestern)    | Northwestern   | 1,161          | 7.41%                |
| #5   | [Penn State](#f/pennstate)         | Penn State     | 18,609         | 7.61%                |
| #6   | [Virginia Tech](#f/virginiatech)   | Virginia Tech  | 12,835         | 7.64%                |
| #7   | [James Madison](#f/jamesmadison)   | James Madison  | 1,364          | 8.06%                |
| #8   | [Rutgers](#f/rutgers)              | Rutgers        | 5,570          | 8.24%                |
| #9   | [Boston College](#f/bostoncollege) | Boston College | 1,499          | 8.54%                |
| #10  | [USF](#f/usf)                      | USF            | 1,673          | 8.79%                |


## Most ref complaints per comment

| Rank | Logo                             | Flair         | Total Comments | % Comments w/ Ref Mentions |
|:-----|:-------------|:-------------|:--------------|:------------------------|
| #1   | [Syracuse](#f/syracuse)          | Syracuse      | 2,749          | 4.55%                      |
| #2   | [James Madison](#f/jamesmadison) | James Madison | 1,364          | 3.74%                      |
| #3   | [Notre Dame](#f/notredame)       | Notre Dame    | 25,371         | 3.44%                      |
| #4   | [California](#f/california)      | California    | 4,224          | 3.43%                      |
| #5   | [Arizona](#f/arizona)            | Arizona       | 3,892          | 3.34%                      |
| #6   | [Arkansas](#f/arkansas)          | Arkansas      | 8,412          | 3.32%                      |
| #7   | [Texas Tech](#f/texastech)       | Texas Tech    | 11,173         | 3.15%                      |
| #8   | [Tulane](#f/tulane)              | Tulane        | 1,033          | 3.1%                       |
| #9   | [Kansas](#f/kansas)              | Kansas        | 8,794          | 3.04%                      |
| #10  | [Wisconsin](#f/wisconsin)        | Wisconsin     | 10,633         | 2.97%                      |

I actually checked before last week, and Oklahoma rocketed up from ~50th
place to the top ten in the Cincinnati game alone.

# r/CFB 2023 Leaderboards

And finally, the big reveal: who is in the lead to claim this year’s
National Champion of posting? Here are the top 25 so far this season:

| Rank | Poster               | Primary Flair    | Total Comments | Unique Threads | % Comments w/ Swears | % Comments w/ Ref Complaints |
|:---|:-----------|:---------|:--------|--------:|:-----------|:----------------|
| #1   | BikiniATroll         | Penn State       | 1,794          |             87 | 6.58%                | 1.45%                        |
| #2   | thebaylorweedinhaler | Baylor           | 1,461          |             80 | 10.68%               | 1.23%                        |
| #3   | aMiracleAtJordanHare | Paper Bag        | 1,441          |             68 | 10.69%               | 2.85%                        |
| #4   | F-18EBestHornet      | Washington State | 1,385          |             49 | 17.69%               | 1.59%                        |
| #5   | DiarrheaForDays      | Georgia          | 1,357          |             46 | 7.96%                | 2.28%                        |
| #6   | FightingFarrier18    | Texas A&M        | 1,215          |             27 | 5.68%                | 2.55%                        |
| #7   | loyalsons4evertrue   | Iowa State       | 1,211          |             87 | 3.8%                 | 0.83%                        |
| #8   | texas2089            | Florida State    | 1,206          |             51 | 18.41%               | 1.24%                        |
| #9   | Ajp_iii              | Florida State    | 1,164          |             30 | 5.41%                | 7.47%                        |
| #10  | leakymemo            | Kentucky         | 1,142          |             58 | 30.56%               | 3.15%                        |
| #11  | Kodyaufan2           | Auburn           | 1,139          |             66 | 0.09%                | 1.93%                        |
| #12  | Competitive-Rise-789 | Georgia          | 1,099          |             40 | 10.1%                | 2.64%                        |
| #13  | Tarlcabot18          | UCF              | 1,098          |             29 | 6.83%                | 1.64%                        |
| #14  | Jonjon428            | Unflaired        | 1,083          |             41 | 18.01%               | 2.95%                        |
| #15  | WanderLeft           | Oklahoma         | 1,064          |             41 | 5.26%                | 0.19%                        |
| #16  | MD90\_\_             | Ohio State       | 1,061          |             18 | 2.07%                | 0.28%                        |
| #17  | Elbit_Curt_Sedni     | Michigan         | 1,039          |             45 | 1.73%                | 4.43%                        |
| #18  | elgenie              | Iowa             | 1,035          |             39 | 3.77%                | 1.26%                        |
| #19  | indreams159          | Unflaired        | 1,031          |             76 | 5.72%                | 0.97%                        |
| #20  | MrNudeGuy            | Oklahoma         | 1,026          |             68 | 8.77%                | 2.44%                        |
| #21  | AeroStatikk          | BYU              | 1,017          |             48 | 1.57%                | 0.79%                        |
| #22  | The_Soccer_Heretic   | Oklahoma         | 1,002          |             59 | 9.98%                | 2.89%                        |
| #23  | fightin_blue_hens    | Delaware         | 1,002          |             58 | 4.69%                | 2.69%                        |
| #24  | StoopSign            | Paper Bag        | 999            |             61 | 4.9%                 | 2.8%                         |
| #25  | Dead_Baby_Kicker     | Ohio State       | 997            |             38 | 3.71%                | 1.2%                         |

Additionally, here’s the official Sicko Award Top Ten, as it stands now:

| rank | author               | counted_flair | n_unique_threads | n_comments |
|:-----|:---------------------|:--------------|-----------------:|-----------:|
| #1   | zenverak             | Georgia       |              114 |        910 |
| #2   | Muffinnnnnnn         | Florida State |              111 |        531 |
| #3   | Sportacles           | Oregon        |               96 |        637 |
| #4   | BikiniATroll         | Penn State    |               87 |       1794 |
| #5   | loyalsons4evertrue   | Iowa State    |               87 |       1211 |
| #6   | ddottay              | Notre Dame    |               86 |        749 |
| #7   | Zloggt               | Illinois      |               83 |        300 |
| #8   | thebaylorweedinhaler | Baylor        |               80 |       1461 |
| #9   | Please_PM_me_Uranus  | Michigan      |               77 |        397 |
| #10  | indreams159          | Unflaired     |               76 |       1031 |

------------------------------------------------------------------------

I hope you found this interesting! I’m going to keep this going for the
rest of the season, so please let me know if there’s anything else you’d
like me to track. Thanks for reading!
