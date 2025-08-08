SELECT * FROM bootcamp.nba_game_details limit 50
SHOW CREATE TABLE bootcamp.nba_game_details
SELECT count(1) From bootcamp.nba_game_details
SELECT * from bootcamp.nba_game_details LIMIT 10;
SELECT DISTINCT(comment) from bootcamp.nba_game_details
SELECT * from bootcamp.nba_game_details WHERE comment is NOT NULL ;
SELECT * FROM bootcamp.nba_games;

CREATE TABLE sundarmasetty.fct_nba_game_details(
game_id BIGINT,
Team_id BIGINT,
player_id BIGINT,
dim_team_abbreviation VARCHAR,
dim_player_name VARCHAR,
dim_start_position VARCHAR,
dim_did_not_dress BOOLEAN,
dim_not_with_team BOOLEAN,
m_seconds_played  DOUBLE,
m_fields_goals_made DOUBLE,
m_field_goals_attempted DOUBLE,
m_3_pointers_attempted DOUBLE,
m_free_throws_made DOUBLE,
m_free_throws_attempted DOUBLE,
m_offensive_rebounds DOUBLE,
m_defensive_rebounds DOUBLE,    -- using double can save the fractal part which will be helpful for the analysts
m_rebounds DOUBLE,  
m_assists DOUBLE,
m_steals DOUBLE,
m_blocks DOUBLE,
m_turnovers DOUBLE,
m_personal_fouls DOUBLE,
m_points DOUBLE,
m_plus_minus DOUBLE,
dim_game_date DATE,
dim_season INTEGER,
dim_team_did_win BOOLEAN
)
WITH(
Format = 'PARQUET',
Partitioning = Array['dim_season']
)

WITH games AS (
  SELECT game_id , season , home_team_wins , home_team_id , visitor_team_id FROM bootcamp.nba_games;
)
select * from games;

--Joining two tables with the needed columns to check. for the next step.
WITH games AS(
Select game_id , season , home_team_wins, home_team_id , visitor_team_id from bootcamp.nba_games
)
Select * from games g JOIN bootcamp.nba_game_details gd ON g.game_id = gd.game_id
LIMIT 50;

-- creating / making the data with the columns i need and changing the column names as per my conviction
WITH games AS(
Select game_id , game_date_est, season , home_team_wins, home_team_id , visitor_team_id from bootcamp.nba_games
)
Select 
CAST(g.game_id  AS BIGINT) as game_id,
gd.team_id,
Gd.player_id,
gd.team_abbreviation as dim_team_abbreviation,
gd.player_name as dim_player_name,
gd.start_position as dim_start_position,
gd.comment LIKE '%DND%' AS dim_did_not_dress,
gd.comment LIKE '%NWT%' AS dim_not_with_team,
CASE WHEN CARDINALITY (SPLIT(min,':')) > 1 
  THEN 
CAST(CAST(SPLIT (min , ':')[1] AS DOUBLE ) * 60 + CAST(SPLIT(min,':')[2] AS DOUBLE ) AS INTEGER)
ELSE
  CAST(min as INTEGER)
END
AS 
  seconds_played , -- conversion into seconds as in original table in the minutes which is not good for analytics 
CAST(fgm as DOUBLE ) as m_fields_goals_made,
CAST(fga as DOUBLE ) as m_fields_goals_attempted,
CAST(fg3m as DOUBLE ) as m_3_pointers_made,
CAST(fg3a as DOUBLE ) as m_3_pointers_attempted,
CAST(ftm as DOUBLE ) as m_free_throws_made,
CAST(fta as DOUBLE ) as m_free_throws_attempted,
CAST(oreb AS DOUBLE) as m_offensive_rebounds,
CAST(dreb AS DOUBLE ) as m_defensive_rebounds,
CAST(reb as DOUBLE ) as m_rebounds,
CAST(ast as DOUBLE ) as m_assists,
CAST(stl as DOUBLE) as m_steals,
CAST(blk as DOUBLE ) as m_blocks,
CAST(turnovers AS DOUBLE ) as m_turnovers,  -- issue with to
CAST(pf as DOUBLE ) as m_personal_fouls,
CAST(plus_minus as DOUBLE ) as m_plus_minus,
g.game_date_est AS dim_game_date,
g.season as dim_season,
CASE WHEN gd.team_id = g.home_team_id THEN home_team_wins = 1 
  ELSE home_team_wins = 0 
  END AS  
  dim_team_win
from games g JOIN bootcamp.nba_game_details gd ON g.game_id = gd.game_id


