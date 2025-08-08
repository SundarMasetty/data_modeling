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


