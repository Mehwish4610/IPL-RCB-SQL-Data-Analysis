/* =====================================================================
   RCB IPL STRATEGY — STUDENT ANSWER TEMPLATE
   ===================================================================== */

USE ipl;

SHOW tables;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ipl'
ORDER BY TABLE_NAME, ORDINAL_POSITION;


/* =====================================================================
   OBJECTIVE QUESTIONS
   ===================================================================== */

-- O1.
-- List the different dtypes of columns in table "ball_by_ball" (using
-- information schema)
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ipl' AND TABLE_NAME = 'ball_by_ball'
ORDER BY ORDINAL_POSITION;


-- O2.
-- What is the total number of runs scored in 1st season by RCB (bonus: also
-- include the extra runs using the extra runs table)

-- Identify RCB's Team ID
SELECT *
FROM team
WHERE Team_Name LIKE '%Royal Challengers%';

-- Identify the seasons
SELECT
    Season_Id,
    Season_Year
FROM season
ORDER BY Season_Year;

-- Check available matches by season
SELECT
    s.Season_Id,
    s.Season_Year,
    COUNT(m.Match_Id) AS total_matches
FROM season s
JOIN matches m
    ON s.Season_Id = m.Season_Id
GROUP BY
    s.Season_Id,
    s.Season_Year
ORDER BY s.Season_Year;

-- Verify RCB's batting records
SELECT
    Team_Batting,
    COUNT(*) AS total_balls,
    SUM(Runs_Scored) AS total_runs
FROM ball_by_ball
WHERE Team_Batting = 2
GROUP BY Team_Batting;

-- Calculate RCB's runs by season
SELECT
    m.Season_Id,
    COUNT(*) AS balls,
    SUM(b.Runs_Scored) AS bat_runs
FROM ball_by_ball b
JOIN matches m
    ON b.Match_Id = m.Match_Id
WHERE b.Team_Batting = 2
GROUP BY m.Season_Id
ORDER BY m.Season_Id;

-- Calculate batting runs for 2013 only
SELECT
    SUM(COALESCE(b.Runs_Scored, 0)) AS bat_runs
FROM ball_by_ball b
JOIN matches m
    ON b.Match_Id = m.Match_Id
WHERE m.Season_Id = 6
  AND b.Team_Batting = 2;
  
-- Examine the extra runs table
SELECT *
FROM extra_runs
LIMIT 10;

-- Calculate RCB's extra runs in 2013
SELECT
    COALESCE(SUM(e.Extra_Runs), 0) AS extra_runs
FROM extra_runs e
JOIN ball_by_ball b
    ON e.Match_Id = b.Match_Id
   AND e.Over_Id = b.Over_Id
   AND e.Ball_Id = b.Ball_Id
   AND e.Innings_No = b.Innings_No
JOIN matches m
    ON b.Match_Id = m.Match_Id
WHERE m.Season_Id = 6
  AND b.Team_Batting = 2;

-- final query for q2 answer
SELECT
    SUM(COALESCE(b.Runs_Scored, 0)) AS bat_runs,
    SUM(COALESCE(e.extra_total, 0)) AS extra_runs,
    SUM( COALESCE(b.Runs_Scored, 0) + COALESCE(e.extra_total, 0) ) AS total_with_extras
FROM ball_by_ball b
JOIN matches m
    ON b.Match_Id = m.Match_Id
LEFT JOIN (
    SELECT
        Match_Id,
        Over_Id,
        Ball_Id,
        Innings_No,
        SUM(Extra_Runs) AS extra_total
    FROM extra_runs
    GROUP BY
        Match_Id, Over_Id, Ball_Id, Innings_No
) e
    ON b.Match_Id = e.Match_Id
   AND b.Over_Id = e.Over_Id
   AND b.Ball_Id = e.Ball_Id
   AND b.Innings_No = e.Innings_No
WHERE m.Season_Id = 6
  AND b.Team_Batting = 2;

-- O3.
-- How many players were more than the age of 25 during season 2014?
-- Inspect player information
SELECT
    Player_Id,
    Player_Name,
    DOB
FROM player
LIMIT 10;

-- players who participated in 2014
SELECT
    COUNT(DISTINCT pm.Player_Id) AS total_players_2014
FROM player_match pm
JOIN matches m
    ON pm.Match_Id = m.Match_Id
WHERE m.Season_Id = 7;

-- Calculate players older than 25
SELECT
    COUNT(DISTINCT p.Player_Id) AS players_over_25_in_2014
FROM player p
JOIN player_match pm
    ON p.Player_Id = pm.Player_Id
JOIN matches m
    ON pm.Match_Id = m.Match_Id
WHERE m.Season_Id = 7
  AND TIMESTAMPDIFF(YEAR, p.DOB, m.Match_Date) > 25;

-- O4.
-- How many matches did RCB win in 2013?
SELECT
    COUNT(*) AS rcb_wins_2013
FROM matches
WHERE Season_Id = 6
  AND Match_Winner = 2;


-- O5.
-- List the top 10 players according to their strike rate in the last 4
-- seasons
-- Inspect batting data
SELECT
    Striker,
    Runs_Scored,
    Match_Id,
    Over_Id,
    Ball_Id
FROM ball_by_ball
LIMIT 10;

-- Checking extra-run types
SELECT *
FROM extra_type;

-- strike rate calculation: 
-- strike rate = batting runs / legal balls faced * 100
SELECT
    p.Player_Name,
    SUM(COALESCE(b.Runs_Scored, 0)) AS runs,
    COUNT(*) -
    COUNT(DISTINCT CASE
        WHEN e.Extra_Type_Id = 2
        THEN CONCAT(
            b.Match_Id, '-',
            b.Over_Id, '-',
            b.Ball_Id, '-',
            b.Innings_No
        )
    END) AS balls_faced,
    ROUND(
        SUM(COALESCE(b.Runs_Scored, 0)) * 100.0 /
        NULLIF(
            COUNT(*) -
            COUNT(DISTINCT CASE
                WHEN e.Extra_Type_Id = 2
                THEN CONCAT(
                    b.Match_Id, '-',
                    b.Over_Id, '-',
                    b.Ball_Id, '-',
                    b.Innings_No
                )
            END),
            0
        ),
        2
    ) AS strike_rate
FROM ball_by_ball b
JOIN player p
    ON b.Striker = p.Player_Id
JOIN matches m
    ON b.Match_Id = m.Match_Id
LEFT JOIN extra_runs e
    ON b.Match_Id = e.Match_Id
    AND b.Over_Id = e.Over_Id
    AND b.Ball_Id = e.Ball_Id
    AND b.Innings_No = e.Innings_No
WHERE m.Season_Id BETWEEN 6 AND 9
GROUP BY p.Player_Id, p.Player_Name
ORDER BY strike_rate DESC
LIMIT 10;

-- Check for duplicate extra-run records
SELECT
    Match_Id,
    Over_Id,
    Ball_Id,
    Innings_No,
    COUNT(*) AS records
FROM extra_runs
GROUP BY
    Match_Id, Over_Id, Ball_Id, Innings_No
HAVING COUNT(*) > 1
LIMIT 10;

-- O6.
-- What are the average runs scored by each batsman considering all the
-- seasons?
 -- Count unique batsmen
SELECT
    COUNT(DISTINCT Striker) AS total_batsmen
FROM ball_by_ball;

-- Total runs and matches
SELECT
    p.Player_Name,
    SUM(COALESCE(b.Runs_Scored, 0)) AS total_runs,
    COUNT(DISTINCT b.Match_Id) AS matches
FROM ball_by_ball b
JOIN player p
    ON b.Striker = p.Player_Id
GROUP BY p.Player_Id, p.Player_Name
ORDER BY total_runs DESC;

-- Final query
SELECT
    p.Player_Name,
    SUM(COALESCE(b.Runs_Scored, 0)) AS total_runs,
    COUNT(DISTINCT b.Match_Id) AS matches,
    ROUND(
        SUM(COALESCE(b.Runs_Scored, 0)) * 1.0 /
        NULLIF(COUNT(DISTINCT b.Match_Id), 0),
        2 ) AS avg_runs_per_match
FROM ball_by_ball b
JOIN player p
    ON b.Striker = p.Player_Id
GROUP BY p.Player_Id, p.Player_Name
ORDER BY avg_runs_per_match DESC;

-- O7.
-- What are the average wickets taken by each bowler considering all the
-- seasons?
-- Inspecting dismissal types
SELECT *
FROM out_type;

-- Inspecting wicket records
SELECT *
FROM wicket_taken
LIMIT 10; 

-- Checking total number of bowlers
SELECT COUNT(DISTINCT Bowler) AS total_bowlers
FROM ball_by_ball;

-- Final query
SELECT
    p.Player_Name,
    COUNT(*) AS total_wickets,
    COUNT(DISTINCT b.Match_Id) AS matches,
    ROUND(
        COUNT(*) * 1.0 /
        COUNT(DISTINCT b.Match_Id),
        2) AS avg_wickets_per_match
FROM wicket_taken w
JOIN ball_by_ball b
    ON w.Match_Id = b.Match_Id
    AND w.Over_Id = b.Over_Id
    AND w.Ball_Id = b.Ball_Id
    AND w.Innings_No = b.Innings_No
JOIN player p
    ON b.Bowler = p.Player_Id
WHERE w.Kind_Out IN (1, 2, 4, 6, 7, 8)
GROUP BY p.Player_Id, p.Player_Name
ORDER BY avg_wickets_per_match DESC;


-- O8.
-- List all the players who have average runs scored greater than the overall
-- average and who have taken wickets greater than the overall average
WITH batting AS (
    SELECT
        Striker AS Player_Id,
        SUM(COALESCE(Runs_Scored, 0)) / COUNT(DISTINCT Match_Id) AS avg_runs
    FROM ball_by_ball
    GROUP BY Striker
),
bowling_matches AS (
    SELECT
        Bowler AS Player_Id,
        COUNT(DISTINCT Match_Id) AS matches
    FROM ball_by_ball
    GROUP BY Bowler
),
bowling_wickets AS (
    SELECT
        b.Bowler AS Player_Id,
        COUNT(*) AS total_wickets
    FROM wicket_taken w
    JOIN ball_by_ball b
        ON w.Match_Id = b.Match_Id
       AND w.Over_Id = b.Over_Id
       AND w.Ball_Id = b.Ball_Id
       AND w.Innings_No = b.Innings_No
    WHERE w.Kind_Out IN (1, 2, 4, 6, 7, 8)
    GROUP BY b.Bowler
),
bowling AS (
    SELECT
        bm.Player_Id,
        COALESCE(bw.total_wickets, 0) / bm.matches AS avg_wkts
    FROM bowling_matches bm
    LEFT JOIN bowling_wickets bw
        ON bm.Player_Id = bw.Player_Id
)
SELECT
    p.Player_Name,
    ROUND(bt.avg_runs, 2) AS avg_runs,
    ROUND(bl.avg_wkts, 2) AS avg_wkts
FROM batting bt
JOIN bowling bl
    ON bt.Player_Id = bl.Player_Id
JOIN player p
    ON bt.Player_Id = p.Player_Id
WHERE bt.avg_runs > (
    SELECT AVG(avg_runs)
    FROM batting
)
AND bl.avg_wkts > (
    SELECT AVG(avg_wkts)
    FROM bowling
)
ORDER BY avg_runs DESC, avg_wkts DESC;

-- O9.
-- Create a table rcb_record table that shows the wins and losses of RCB in an
-- individual venue.
-- Inspecting venue table
SELECT *
FROM venue
LIMIT 10;

-- RCB's venue-wise performance
SELECT
    v.Venue_Id,
    v.Venue_Name,
    SUM(
        CASE
            WHEN m.Match_Winner = 2 THEN 1
            ELSE 0
        END
    ) AS wins,
    SUM(
        CASE
            WHEN m.Match_Winner IS NOT NULL AND m.Match_Winner <> 2 THEN 1
            ELSE 0
        END
) AS losses
FROM matches m
JOIN venue v
    ON m.Venue_Id = v.Venue_Id
WHERE m.Team_1 = 2 OR m.Team_2 = 2
GROUP BY v.Venue_Id, v.Venue_Name
ORDER BY wins DESC;

-- Venue wise record table
CREATE TABLE rcb_record AS
SELECT
    v.Venue_Id,
    v.Venue_Name,
    SUM(
        CASE
            WHEN m.Match_Winner = 2 THEN 1
            ELSE 0
        END
    ) AS wins,
    SUM(
        CASE
            WHEN m.Match_Winner IS NOT NULL
                 AND m.Match_Winner <> 2 THEN 1
            ELSE 0
        END
	) AS losses
FROM matches m
JOIN venue v
    ON m.Venue_Id = v.Venue_Id
WHERE m.Team_1 = 2 OR m.Team_2 = 2
GROUP BY v.Venue_Id, v.Venue_Name;

-- verifying created table
SELECT *
FROM rcb_record
ORDER BY wins DESC;

-- O10.
-- What is the impact of bowling style on wickets taken?
-- Inspecting Bowling style
SELECT *
FROM bowling_style;

-- calculating wickets by bowling
WITH bowler_wickets AS (
    SELECT
        b.Bowler AS Player_Id,
        COUNT(*) AS total_wickets
    FROM wicket_taken w
    JOIN ball_by_ball b
        ON w.Match_Id = b.Match_Id
       AND w.Over_Id = b.Over_Id
       AND w.Ball_Id = b.Ball_Id
       AND w.Innings_No = b.Innings_No
    WHERE w.Kind_Out IN (1, 2, 4, 6, 7, 8)
    GROUP BY b.Bowler
)

SELECT
    bs.Bowling_skill AS bowling_style,
    SUM(bw.total_wickets) AS total_wickets,
    COUNT(DISTINCT p.Player_Id) AS num_bowlers,
    ROUND(
        SUM(bw.total_wickets) * 1.0 /
        COUNT(DISTINCT p.Player_Id),
        2
    ) AS wickets_per_bowler
FROM bowler_wickets bw
JOIN player p
    ON bw.Player_Id = p.Player_Id
JOIN bowling_style bs
    ON p.Bowling_skill = bs.Bowling_Id
GROUP BY bs.Bowling_Id, bs.Bowling_skill
ORDER BY total_wickets DESC;

-- O11.
-- Write the SQL query to provide a status of whether the performance of the
-- team is better than the previous year's performance on the basis of the
-- number of runs scored by the team in the season and the number of
-- wickets taken
WITH extras_per_ball AS (
    SELECT
        Match_Id, Over_Id, Ball_Id, Innings_No,
        SUM(Extra_Runs) AS extra_total
    FROM extra_runs
    GROUP BY Match_Id, Over_Id, Ball_Id, Innings_No
),
season_runs AS (
    SELECT
        m.Season_Id,
        SUM(
            COALESCE(b.Runs_Scored, 0) + COALESCE(e.extra_total, 0)) AS runs
    FROM ball_by_ball b
    JOIN matches m
        ON b.Match_Id = m.Match_Id
    LEFT JOIN extras_per_ball e
        ON b.Match_Id = e.Match_Id
       AND b.Over_Id = e.Over_Id
       AND b.Ball_Id = e.Ball_Id
       AND b.Innings_No = e.Innings_No
    WHERE b.Team_Batting = 2
    GROUP BY m.Season_Id
),
season_wickets AS (
    SELECT
        m.Season_Id,
        COUNT(*) AS wkts
    FROM wicket_taken w
    JOIN ball_by_ball b
        ON w.Match_Id = b.Match_Id
       AND w.Over_Id = b.Over_Id
       AND w.Ball_Id = b.Ball_Id
       AND w.Innings_No = b.Innings_No
    JOIN matches m
        ON b.Match_Id = m.Match_Id
    WHERE b.Team_Bowling = 2
      AND w.Kind_Out IN (1, 2, 4, 6, 7, 8)
    GROUP BY m.Season_Id
),

season_totals AS (
    SELECT
        s.Season_Year,
        r.runs,
        COALESCE(w.wkts, 0) AS wkts
    FROM season_runs r
    JOIN season s
        ON r.Season_Id = s.Season_Id
    LEFT JOIN season_wickets w
        ON r.Season_Id = w.Season_Id
    WHERE s.Season_Year BETWEEN 2013 AND 2016
),
year_comparison AS (
    SELECT
        Season_Year,
        runs,
        wkts,
        LAG(runs) OVER (
            ORDER BY Season_Year
        ) AS prev_runs,
        LAG(wkts) OVER (
            ORDER BY Season_Year
        ) AS prev_wkts
    FROM season_totals
)
SELECT
    Season_Year,
    runs,
    wkts,
    CASE
        WHEN prev_runs IS NULL THEN 'N/A'
        WHEN runs > prev_runs THEN 'Increased'
        WHEN runs < prev_runs THEN 'Decreased'
        ELSE 'Same'
    END AS runs_vs_prev,
    CASE
        WHEN prev_wkts IS NULL THEN 'N/A'
        WHEN wkts > prev_wkts THEN 'Increased'
        WHEN wkts < prev_wkts THEN 'Decreased'
        ELSE 'Same'
    END AS wkts_vs_prev,
    CASE
        WHEN prev_runs IS NULL THEN 'No previous season'
        WHEN runs > prev_runs AND wkts > prev_wkts
            THEN 'Improved'
        WHEN runs < prev_runs AND wkts < prev_wkts
            THEN 'Declined'
        ELSE 'Mixed performance'
    END AS performance_status
FROM year_comparison
ORDER BY Season_Year;

-- O12.
-- Can you derive more KPIs for the team strategy?
-- (A): RCB win percentage by season
SELECT
    s.Season_Year,
    COUNT(*) AS played,
    SUM(
        CASE
            WHEN m.Match_Winner = 2 THEN 1
            ELSE 0
        END) AS wins,
    ROUND(
        SUM(
            CASE
                WHEN m.Match_Winner = 2 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*), 2) AS win_pct
FROM matches m
JOIN season s
    ON m.Season_Id = s.Season_Id
WHERE (m.Team_1 = 2 OR m.Team_2 = 2)
  AND s.Season_Year BETWEEN 2013 AND 2016
GROUP BY s.Season_Year
ORDER BY s.Season_Year;

-- (B): Percentage of RCB runs from boundaries
SELECT
    ROUND(
        SUM(
            CASE
                WHEN Runs_Scored IN (4, 6)
                THEN Runs_Scored
                ELSE 0
            END
        ) * 100.0 / NULLIF(SUM(COALESCE(Runs_Scored, 0)), 0), 2
    ) AS pct_runs_from_boundaries
FROM ball_by_ball
WHERE Team_Batting = 2;

-- (C): Top 5 RCB run-scorers
SELECT
    p.Player_Name,
    SUM(COALESCE(b.Runs_Scored, 0)) AS runs
FROM ball_by_ball b
JOIN player p
    ON b.Striker = p.Player_Id
JOIN matches m
    ON b.Match_Id = m.Match_Id
WHERE b.Team_Batting = 2
  AND m.Season_Id BETWEEN 6 AND 9
GROUP BY p.Player_Id, p.Player_Name
ORDER BY runs DESC
LIMIT 5;

-- O13.
-- Using SQL, write a query to find out the average wickets taken by each
-- bowler in each venue. Also, rank bowlers within each venue based on their
-- average wickets.
WITH bowling_matches AS (
    SELECT
        m.Venue_Id,
        b.Bowler AS Player_Id,
        COUNT(DISTINCT b.Match_Id) AS matches_bowled
    FROM ball_by_ball b
    JOIN matches m
        ON b.Match_Id = m.Match_Id
    GROUP BY m.Venue_Id, b.Bowler
),
bowling_wickets AS (
    SELECT
        m.Venue_Id,
        b.Bowler AS Player_Id,
        COUNT(*) AS wickets
    FROM wicket_taken w
    JOIN ball_by_ball b
        ON w.Match_Id = b.Match_Id
       AND w.Over_Id = b.Over_Id
       AND w.Ball_Id = b.Ball_Id
       AND w.Innings_No = b.Innings_No
    JOIN matches m
        ON b.Match_Id = m.Match_Id
    WHERE w.Kind_Out IN (1, 2, 4, 6, 7, 8)
    GROUP BY m.Venue_Id, b.Bowler
),
venue_stats AS (
    SELECT
        v.Venue_Name,
        p.Player_Name,
        bw.wickets,
        ROUND(
            bw.wickets * 1.0 / NULLIF(bm.matches_bowled, 0),
            2
        ) AS avg_wickets
    FROM bowling_wickets bw
    JOIN bowling_matches bm
        ON bw.Venue_Id = bm.Venue_Id
       AND bw.Player_Id = bm.Player_Id
    JOIN venue v
        ON bw.Venue_Id = v.Venue_Id
    JOIN player p
        ON bw.Player_Id = p.Player_Id
)
SELECT
    Venue_Name,
    Player_Name,
    wickets,
    avg_wickets,
    DENSE_RANK() OVER (
        PARTITION BY Venue_Name
        ORDER BY avg_wickets DESC
    ) AS venue_rank
FROM venue_stats
ORDER BY Venue_Name, venue_rank, wickets DESC;

-- O14.
-- Which of the given players have consistently performed well in past
-- seasons? (will you use any visualization to solve the problem)
WITH seasonal_runs AS (
    SELECT
        b.Striker AS Player_Id,
        m.Season_Id,
        SUM(COALESCE(b.Runs_Scored, 0)) AS season_runs
    FROM ball_by_ball b
    JOIN matches m
        ON b.Match_Id = m.Match_Id
    WHERE m.Season_Id BETWEEN 6 AND 9
    GROUP BY b.Striker, m.Season_Id
)
SELECT
    p.Player_Name,
    COUNT(sr.Season_Id) AS seasons_played,
    ROUND(AVG(sr.season_runs), 2) AS avg_runs_per_season,
    MIN(sr.season_runs) AS worst_season,
    MAX(sr.season_runs) AS best_season,
    ROUND(STDDEV_POP(sr.season_runs), 2) AS runs_stddev
FROM seasonal_runs sr
JOIN player p
    ON sr.Player_Id = p.Player_Id
GROUP BY p.Player_Id, p.Player_Name
HAVING COUNT(DISTINCT sr.Season_Id) = 4
ORDER BY avg_runs_per_season DESC, runs_stddev ASC;

-- O15.
-- Are there players whose performance is more suited to specific venues or
-- conditions? (how would you present this using charts?)
WITH venue_batting AS (
    SELECT
        p.Player_Name,
        v.Venue_Name,
        SUM(COALESCE(b.Runs_Scored, 0)) AS runs,
        COUNT(*) - SUM(CASE WHEN e.Extra_Type_Id = 2 THEN 1 ELSE 0 END) AS balls
    FROM ball_by_ball b
    JOIN player p
        ON b.Striker = p.Player_Id
    JOIN matches m
        ON b.Match_Id = m.Match_Id
    JOIN venue v
        ON m.Venue_Id = v.Venue_Id
    LEFT JOIN extra_runs e
        ON b.Match_Id = e.Match_Id
       AND b.Over_Id = e.Over_Id
       AND b.Ball_Id = e.Ball_Id
       AND b.Innings_No = e.Innings_No
    GROUP BY p.Player_Id, p.Player_Name, v.Venue_Id, v.Venue_Name
)
SELECT
    Player_Name,
    Venue_Name,
    runs,
    balls,
    ROUND(runs * 100.0 / NULLIF(balls, 0),2) AS strike_rate
FROM venue_batting
WHERE balls >= 60
ORDER BY strike_rate DESC, runs DESC
LIMIT 25;



/* =====================================================================
   SUBJECTIVE QUESTIONS
   ===================================================================== */

-- S1.
-- How does the toss decision affect the result of the match? (which
-- visualizations could be used to present your answer better) And is the
-- impact limited to only specific venues?
-- Check toss decisions
SELECT *
FROM toss_decision;

-- Toss decision vs match result
SELECT
    td.Toss_Name AS toss_decision,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN m.Toss_Winner = m.Match_Winner THEN 1 ELSE 0 END) AS matches_won,
    SUM(CASE WHEN m.Toss_Winner <> m.Match_Winner THEN 1 ELSE 0 END) AS matches_lost,
    ROUND(SUM(CASE WHEN m.Toss_Winner = m.Match_Winner THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS win_percentage
FROM matches m
JOIN toss_decision td
    ON m.Toss_Decide = td.Toss_Id
WHERE m.Match_Winner IN (m.Team_1, m.Team_2)
GROUP BY td.Toss_Name
ORDER BY win_percentage DESC;

-- Overall toss-winning advantage
SELECT
    COUNT(*) AS total_matches,
    SUM(CASE WHEN Toss_Winner = Match_Winner THEN 1 ELSE 0 END) AS toss_winner_won,
    SUM(CASE WHEN Toss_Winner <> Match_Winner THEN 1 ELSE 0 END) AS toss_winner_lost,
    ROUND(SUM(CASE WHEN Toss_Winner = Match_Winner THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS toss_win_match_win_pct
FROM matches
WHERE Match_Winner IN (Team_1, Team_2);

-- Toss decisions at different venues
SELECT
    v.Venue_Name,
    td.Toss_Name AS toss_decision,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN m.Toss_Winner = m.Match_Winner THEN 1 ELSE 0 END) AS matches_won,
    ROUND(SUM(CASE WHEN m.Toss_Winner = m.Match_Winner THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS win_percentage
FROM matches m
JOIN venue v
    ON m.Venue_Id = v.Venue_Id
JOIN toss_decision td
    ON m.Toss_Decide = td.Toss_Id
WHERE m.Match_Winner IN (m.Team_1, m.Team_2)
GROUP BY v.Venue_Id, v.Venue_Name, td.Toss_Name
HAVING COUNT(*) >= 5
ORDER BY v.Venue_Name, win_percentage DESC;

-- S2.
-- Suggest some of the players who would be best fit for the team.

-- Combined player performance analysis IPL seasons 2013–2016

WITH batting AS (
    SELECT
        b.Striker AS Player_Id,
        SUM(COALESCE(b.Runs_Scored, 0)) AS total_runs,
        COUNT(DISTINCT b.Match_Id) AS batting_matches,
        ROUND(SUM(COALESCE(b.Runs_Scored, 0)) * 100.0 /
            NULLIF(
                SUM(CASE
                    WHEN e.Extra_Type_Id = 2 THEN 0
                    ELSE 1
                END), 0
            ),2) AS strike_rate
    FROM ball_by_ball b
    JOIN matches m
        ON b.Match_Id = m.Match_Id
    LEFT JOIN extra_runs e
        ON b.Match_Id = e.Match_Id
       AND b.Over_Id = e.Over_Id
       AND b.Ball_Id = e.Ball_Id
       AND b.Innings_No = e.Innings_No
    WHERE m.Season_Id BETWEEN 6 AND 9
    GROUP BY b.Striker
),
bowling_matches AS (
    SELECT
        b.Bowler AS Player_Id,
        COUNT(DISTINCT b.Match_Id) AS matches_bowled
    FROM ball_by_ball b
    JOIN matches m
        ON b.Match_Id = m.Match_Id
    WHERE m.Season_Id BETWEEN 6 AND 9
    GROUP BY b.Bowler
),
bowling_wickets AS (
    SELECT
        b.Bowler AS Player_Id,
        COUNT(*) AS total_wickets
    FROM wicket_taken w
    JOIN ball_by_ball b
        ON w.Match_Id = b.Match_Id
       AND w.Over_Id = b.Over_Id
       AND w.Ball_Id = b.Ball_Id
       AND w.Innings_No = b.Innings_No
    JOIN matches m
        ON b.Match_Id = m.Match_Id
    WHERE m.Season_Id BETWEEN 6 AND 9
      AND w.Kind_Out IN (1, 2, 4, 6, 7, 8)
    GROUP BY b.Bowler
)
SELECT
    p.Player_Name,
    COALESCE(bt.total_runs, 0) AS total_runs,
    bt.strike_rate,
    COALESCE(bw.total_wickets, 0) AS total_wickets,
    ROUND(
        COALESCE(bt.total_runs, 0) /
        NULLIF(bt.batting_matches, 0),
        2) AS runs_per_match,
    ROUND(
        COALESCE(bw.total_wickets, 0) /
        NULLIF(bm.matches_bowled, 0),
        2) AS wickets_per_match
FROM player p
LEFT JOIN batting bt
    ON p.Player_Id = bt.Player_Id
LEFT JOIN bowling_matches bm
    ON p.Player_Id = bm.Player_Id
LEFT JOIN bowling_wickets bw
    ON p.Player_Id = bw.Player_Id
WHERE COALESCE(bt.total_runs, 0) >= 100
  AND COALESCE(bw.total_wickets, 0) >= 5
ORDER BY wickets_per_match DESC, runs_per_match DESC
LIMIT 10;

-- S3.
-- What are some of the parameters that should be focused on while selecting
-- the players?

/* 
Key Selection Parameters:
1.	Batting Performance: Evaluate total runs, runs per match, strike rate, and scoring ability.
2.	Bowling Effectiveness: Consider wickets per match, economy rate, and bowling style.
3.	Consistency: Prefer players who maintain strong performance across multiple seasons with relatively low variation.
4.	All-Round Ability: Identify players who contribute effectively with both bat and ball.
5.	Venue Suitability: Analyze performances at M Chinnaswamy Stadium and other IPL venues.
6.	Recent Form: Examine year-on-year performance trends to identify improving players.
7.	Team Balance: Prioritize players who strengthen weak departments and complement existing squad members.
8.	Auction Value: Consider affordability, player availability, retention rules, and overseas-player restrictions.

Key Insights:
•	AB de Villiers demonstrated aggressive batting with a strike rate of 167.92.
•	DJ Bravo recorded 75 wickets, averaging 1.53 wickets per match.
•	RG Sharma showed strong consistency, averaging 474.75 runs per season with a standard deviation of 53.48.
•	AD Russell demonstrated all-round ability with 527 runs and 30 wickets.
•	RCB's historical performance suggests that strengthening bowling depth while retaining batting strength
 should be a major priority.

Recommendation:
RCB should adopt a balanced, data-driven player selection strategy rather than selecting players solely based
 on reputation or total runs and wickets.
Priority should be given to consistent wicket-taking bowlers, reliable all-rounders, and players whose skills
 complement the existing batting core.
A role-specific weighted scoring model can help compare potential recruits objectively. 
Final decisions should also account for player availability, auction budget, squad composition, 
and overseas-player restrictions.
*/


-- S4.
-- Which players offer versatility in their skills and can contribute
-- effectively with both bat and ball? (can you visualize the data for the
-- same)
WITH batting AS (
    SELECT
        b.Striker AS Player_Id,
        SUM(COALESCE(b.Runs_Scored, 0)) AS total_runs,
        COUNT(DISTINCT b.Match_Id) AS batting_matches
    FROM ball_by_ball b
    JOIN matches m
        ON b.Match_Id = m.Match_Id
    WHERE m.Season_Id BETWEEN 6 AND 9
    GROUP BY b.Striker
),
bowling_matches AS (
    SELECT
        b.Bowler AS Player_Id,
        COUNT(DISTINCT b.Match_Id) AS matches_bowled
    FROM ball_by_ball b
    JOIN matches m
        ON b.Match_Id = m.Match_Id
    WHERE m.Season_Id BETWEEN 6 AND 9
    GROUP BY b.Bowler
),
bowling_wickets AS (
    SELECT
        b.Bowler AS Player_Id,
        COUNT(*) AS total_wickets
    FROM wicket_taken w
    JOIN ball_by_ball b
        ON w.Match_Id = b.Match_Id
       AND w.Over_Id = b.Over_Id
       AND w.Ball_Id = b.Ball_Id
       AND w.Innings_No = b.Innings_No
    JOIN matches m
        ON b.Match_Id = m.Match_Id
    WHERE m.Season_Id BETWEEN 6 AND 9
      AND w.Kind_Out IN (1, 2, 4, 6, 7, 8)
    GROUP BY b.Bowler
)
SELECT
    p.Player_Name,
    bt.total_runs,
    bw.total_wickets,
    ROUND(
        bt.total_runs * 1.0 /
        NULLIF(bt.batting_matches, 0), 2
    ) AS runs_per_match,
    ROUND(
        bw.total_wickets * 1.0 /
        NULLIF(bm.matches_bowled, 0), 2
    ) AS wickets_per_match
FROM batting bt
JOIN bowling_matches bm
    ON bt.Player_Id = bm.Player_Id
JOIN bowling_wickets bw
    ON bt.Player_Id = bw.Player_Id
JOIN player p
    ON bt.Player_Id = p.Player_Id
WHERE bt.total_runs >= 100
  AND bw.total_wickets >= 10
ORDER BY
    wickets_per_match DESC,
    runs_per_match DESC
LIMIT 20;

/* The analysis identified several versatile players, including Shane Watson, Andre Russell, Dwayne Bravo, 
Chris Morris, and Ravindra Jadeja.
Shane Watson scored 1,315 runs and took 46 wickets, while Andre Russell scored 527 runs and took 30 wickets. 
Dwayne Bravo recorded 75 wickets with 423 runs, demonstrating strong bowling contributions alongside batting ability.
*/

-- S5.
-- Are there players whose presence positively influences the morale and
-- performance of the team? (justify your answer using visualization)
WITH rcb_matches AS (
    SELECT
        Match_Id,
        Match_Winner
    FROM matches
    WHERE Season_Id BETWEEN 6 AND 9
      AND (Team_1 = 2 OR Team_2 = 2)
      AND Match_Winner IN (Team_1, Team_2)
),
rcb_players AS (
    SELECT DISTINCT
        pm.Match_Id,
        pm.Player_Id
    FROM player_match pm
    JOIN rcb_matches rm
        ON pm.Match_Id = rm.Match_Id
    WHERE pm.Team_Id = 2
),
player_stats AS (
    SELECT
        rp.Player_Id,
        COUNT(*) AS matches_with,
        SUM(CASE WHEN rm.Match_Winner = 2 THEN 1 ELSE 0 END) AS wins_with
    FROM rcb_players rp
    JOIN rcb_matches rm
        ON rp.Match_Id = rm.Match_Id
    GROUP BY rp.Player_Id
),
team_stats AS (
    SELECT
        COUNT(*) AS total_matches,
        SUM(CASE WHEN Match_Winner = 2 THEN 1 ELSE 0 END) AS total_wins
    FROM rcb_matches
),
comparison AS (
    SELECT
        p.Player_Name,
        ps.matches_with,
        ps.wins_with,
        ROUND(ps.wins_with * 100.0 /NULLIF(ps.matches_with, 0), 2) AS win_pct_with,
        ts.total_matches - ps.matches_with AS matches_without,
        ts.total_wins - ps.wins_with AS wins_without,
        ROUND(
            (ts.total_wins - ps.wins_with) * 100.0 /
            NULLIF(ts.total_matches - ps.matches_with, 0),
            2
        ) AS win_pct_without
    FROM player_stats ps
    JOIN player p
        ON ps.Player_Id = p.Player_Id
    CROSS JOIN team_stats ts
)
SELECT
    Player_Name,
    matches_with,
    wins_with,
    win_pct_with,
    matches_without,
    win_pct_without,
    ROUND(win_pct_with - win_pct_without, 2) AS win_pct_difference
FROM comparison
WHERE matches_with >= 10
  AND matches_without >= 5
ORDER BY win_pct_difference DESC, matches_with DESC
LIMIT 15;


-- S6.
-- What would you suggest to RCB before going to the mega auction?
/*
Approach:

Based on the IPL 2013–2016 analysis, I would suggest that RCB focus on building a balanced team by strengthening 
its weaker areas while retaining its key performers.

Key Recommendations:

Strengthen Bowling: RCB already has a strong batting lineup, but its wicket count decreased from 92 in 2015 to 89 in 2016.
 Bowlers like Bhuvneshwar Kumar (74 wickets) and DJ Bravo (75 wickets) could be considered if available.

Invest in All-Rounders: Players like Andre Russell (527 runs, 30 wickets) and Chris Morris (285 runs, 42 wickets) 
could improve both batting depth and bowling options.

Retain Key Players: Virat Kohli, AB de Villiers, and Yuzvendra Chahal should be prioritized based on their consistent
 contributions.

Consider Venue Performance: RCB should select players who perform well at M Chinnaswamy Stadium. AB de Villiers,
 for example, scored 967 runs there at a strike rate of 173.92.

Focus on Consistency and Budget: Rather than spending heavily on star players, RCB should prioritize 
consistent performers, promising Indian talent, and players who offer good value for money.

Conclusion:

RCB's main priority should be improving its bowling attack while maintaining its strong batting core.
 A balanced combination of reliable bowlers, versatile all-rounders, and consistent batsmen would give the
 team a better chance of performing well in future seasons.
*/


-- S7.
-- What do you think could be the factors contributing to the high-scoring
-- matches and the impact on viewership and team strategies
/*
Approach:

High-scoring IPL matches can be influenced by several factors, including pitch conditions, batting strength, 
ground dimensions, and bowling performance.

Key Factors:

Batting-Friendly Pitches: Flat pitches with good bounce make it easier for batsmen to score runs. Smaller boundaries 
also contribute to higher scores.

Aggressive Batsmen: Players like Virat Kohli, AB de Villiers, and Chris Gayle can increase scoring rates through 
powerful hitting and frequent boundaries.

Bowling Performance: Weak bowling attacks, poor line and length, and ineffective death-over bowling can lead to 
higher totals.

Match Conditions: Dew, weather, and pitch conditions can influence scoring, particularly during run chases.

Impact on Viewership:

High-scoring matches may attract more viewers because frequent boundaries, big sixes, and close run chases make
 the game more exciting. Such matches can also encourage social media engagement and highlight sharing. However, 
 actual viewership impact would require television ratings or streaming data, which are not available in our dataset.

Impact on Team Strategies:

Teams may prioritize aggressive batsmen and all-rounders who can maintain high scoring rates.

Bowlers with good economy rates and effective death-over skills become especially important.

Captains should consider pitch conditions, venue history, and chasing records when making toss decisions.

Conclusion:

High-scoring matches are often influenced by batting-friendly conditions, aggressive batting, and bowling 
effectiveness. For RCB, the focus should be on maintaining its powerful batting lineup while improving bowling 
strategies to control opposition scores, especially at high-scoring venues like M Chinnaswamy Stadium.
*/


-- S8.
-- Analyze the impact of home-ground advantage on team performance and
-- identify strategies to maximize this advantage for RCB.
SELECT
    CASE
        WHEN v.Venue_Name = 'M Chinnaswamy Stadium'
        THEN 'Home'
        ELSE 'Other Venues'
    END AS venue_type,
    COUNT(*) AS matches_played,
    SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END) AS matches_won,
    SUM(CASE WHEN m.Match_Winner <> 2 THEN 1 ELSE 0 END) AS matches_lost,
    ROUND(SUM(CASE
                WHEN m.Match_Winner = 2 THEN 1
                ELSE 0
            END) * 100.0 / COUNT(*),2
    ) AS win_percentage
FROM matches m
JOIN venue v
    ON m.Venue_Id = v.Venue_Id
WHERE m.Season_Id BETWEEN 6 AND 9
  AND (m.Team_1 = 2 OR m.Team_2 = 2)
  AND m.Match_Winner IN (m.Team_1, m.Team_2)
GROUP BY venue_type
ORDER BY win_percentage DESC;


-- S9.
-- Come up with a visual and analytical analysis of the RCB's past season's
-- performance and potential reasons for them not winning a trophy.
/*
Approach:

Analyzed RCB's performance from IPL 2013 to 2016 using season-wise win percentages, total runs scored,
 and wickets taken to identify possible weaknesses.

Key Findings:

Inconsistent Performance: RCB's win percentage dropped from 56.25% in 2013 to 35.71% in 2014, before improving
 to 50% in 2015 and 56.25% in 2016.

Dependence on Batting: RCB scored its highest total of 2,977 runs in 2016, showing strong batting performance.
 However, scoring more runs did not guarantee winning the trophy.

Bowling Concerns: Despite scoring more runs in 2016, RCB took 89 wickets compared to 92 in 2015. This suggests
 that bowling effectiveness may have been an area needing improvement.

Home vs Other Venues: RCB won 59.26% of its home matches but only 45.45% at other venues, indicating difficulty 
maintaining the same performance across different grounds.

Possible Reasons for Not Winning:

RCB's inconsistent results, reliance on its leading batsmen, and possible bowling weaknesses may have contributed
 to its inability to win the IPL trophy during this period. However, these factors alone cannot establish why 
 individual knockout matches were lost.

Recommendations:

RCB should strengthen its bowling attack, improve performance at other venues, invest in reliable all-rounders, 
and focus on consistent team performance rather than depending mainly on individual batting performances.

Conclusion:

RCB had a strong batting lineup but struggled to maintain consistent results across seasons. A better balance
 between batting and bowling, along with improved performances away from home, could help the team compete more 
 effectively for the title.
*/


-- S10.
-- How would you approach this problem, if the objective and subjective
-- questions weren't given?
/*
Approach:
If the questions weren't provided, I would start by understanding the main goal of the project, 
which is to analyze RCB's past performance and suggest improvements for the upcoming auction.
First, I would explore the dataset to understand the available tables, columns, and relationships. 
I would also check for missing values, duplicates, and inconsistencies before starting the analysis.
Next, I would focus on a few important areas:
1.	Team Performance: Analyze RCB's wins, losses, and performance trends across seasons.
2.	Batting and Bowling: Identify the team's strengths and weaknesses using runs, strike rates, wickets, 
and economy rates.
3.	Player Performance: Compare players based on consistency, individual contributions, and all-round abilities.
4.	Venue Analysis: Check whether RCB performs better at home and how different grounds affect results.
5.	Auction Strategy: Identify gaps in the squad and shortlist players who could improve the team's overall balance.
I would use SQL to extract and analyze the data, then create charts in Excel to make the findings easier to understand.
Conclusion:
My approach would be to let the data guide the questions rather than starting with fixed assumptions. I would 
first identify where RCB is performing well, where it is struggling, and then use those findings to suggest 
practical improvements for the team and its auction strategy.

*/


-- S11.
-- In the "Match" table, some entries in the "Opponent_Team" column are
-- incorrectly spelled as "Delhi_Capitals" instead of "Delhi_Daredevils".
-- Write an SQL query to replace all occurrences of "Delhi_Capitals" with
-- "Delhi_Daredevils".
DESCRIBE matches;

SELECT *
FROM team
WHERE Team_Name IN ('Delhi_Capitals', 'Delhi_Daredevils');

SELECT *
FROM team
LIMIT 10;
/*
UPDATE team
SET Team_Name = 'Delhi_Daredevils'
WHERE Team_Name = 'Delhi_Capitals';

Approach:
The question refers to an Opponent_Team column in the Match table.
 However, the provided database stores team names in a separate team table.
Result:
After checking the records, Delhi Daredevils was already present with Team_Id = 6. 
No records contained Delhi_Capitals, so no changes were required.
Conclusion:
The dataset already contains the correct team name, and no update was necessary.

*/

/* ===================================== END OF FILE ===================================== */
