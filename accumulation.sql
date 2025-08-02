-- Your original table design which creates a new row for each season
-- CREATE TABLE players (
--     player_name TEXT,
--     height TEXT,
--     college TEXT,
--     country TEXT,
--     draft_year TEXT,
--     draft_round TEXT,
--     draft_number TEXT,
--     season_stats season_stats[],
--     current_season INTEGER,
--     PRIMARY KEY (player_name,current_season)
-- )

-- Your corrected INSERT statement to properly accumulate stats,
-- but a new row will still be created due to the PRIMARY KEY.
INSERT INTO players
WITH yesterday AS (
    SELECT * FROM players
             WHERE current_season = 2001
),
    today AS (
        SELECT * FROM player_seasons
                 WHERE season = 2002
    )
SELECT
    COALESCE(t.player_name , y.player_name) AS player_name,
    COALESCE(t.height , y.height) AS height,
    COALESCE(t.college , y.college) AS college,
    COALESCE(t.country , y.country) AS country,
    COALESCE(t.draft_year , y.draft_year) AS draft_year,
    COALESCE(t.draft_round , y.draft_round) AS draft_round,
    COALESCE(t.draft_number , y.draft_number) AS draft_number,
    -- Corrected CASE statement to handle accumulation
    CASE
        -- Scenario 1: New player, start a new array
        WHEN y.player_name IS NULL THEN ARRAY[ROW(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats]
        -- Scenario 2: Existing player with new season data, append to the array
        WHEN t.player_name IS NOT NULL AND y.player_name IS NOT NULL THEN y.season_stats || ARRAY[ROW(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats]
        -- Scenario 3: Existing player with no new season data, carry over the old stats
        ELSE y.season_stats
    END as season_stats,
    COALESCE(t.season , y.current_season + 1) AS current_season -- Corrected column name
FROM today t FULL OUTER JOIN yesterday y
    ON t.player_name = y.player_name;

select player_name, season_stats from players where current_season=2001 and player_name = 'Michael Jordan'


-- Issue starts here
WITH unnested AS (
    SELECT
        player_name,
        unnest(season_stats) AS season_stats
    FROM players
    WHERE current_season = 2001
      AND player_name = 'Michael Jordan'
)
SELECT
    unnested.player_name,
    (unnested.season_stats).season,
    (unnested.season_stats).gp,
    (unnested.season_stats).pts,
    (unnested.season_stats).reb,
    (unnested.season_stats).ast
FROM unnested;
--Issue with this code.

