CREATE TABLE IPL_BALL(id int,
inning int,
	over int,
	ball int,
	batsman varchar,
	non_striker varchar,
	bowler varchar,
	batsman_runs int,
	extra_runs int,
	total_runs int,
	is_wicket int,
	dismissal_kind varchar,
	player_dismissed varchar,
	fielder varchar,
	extras_type varchar,
	batting_team varchar,
	bowling_team varchar);  

COPY IPL_BALL ("id","inning","over","ball","batsman","non_striker","bowler","batsman_runs","extra_runs","total_runs","is_wicket","dismissal_kind","player_dismissed","fielder","extras_type","batting_team","bowling_team")
FROM 'C:\Program Files\PostgreSQL\16\data\dataset\IPL Dataset\IPL_Ball.csv' DELIMITER ',' CSV HEADER;

select * from IPL_BALL;

/* Q1 */
 SELECT batsman,
ROUND((SUM(batsman_runs)*1.0 / COUNT(ball)) * 100,2) AS batsman_sr
FROM ipl_ball
WHERE extras_type not in ('wides')
GROUP BY batsman
HAVING COUNT(ball) > 500
ORDER BY batsman_sr DESC
LIMIT 10;

/* Q2 */
SELECT batsman,
	SUM(batsman_runs) AS runs,
	ROUND(SUM(batsman_runs)*1.0/SUM(is_wicket),2) AS 	average
FROM ipl_ball
GROUP BY batsman
HAVING SUM(is_wicket) > 0 AND COUNT(DISTINCT id) > 28
ORDER BY average DESC
LIMIT 10;

/* Q3 */
SELECT batsman, 
ROUND(SUM(CASE WHEN batsman_runs in(4,6) THEN batsman_runs else 0 END)*1.0 / SUM(batsman_runs)*100,2) AS boundary_percentage
FROM ipl_ball
WHERE extras_type NOT IN ('wides')
GROUP BY batsman
HAVING COUNT(DISTINCT id) > 28
ORDER BY boundary_percentage DESC
LIMIT 10;


CREATE TABLE IPL_matches(id int,
	city varchar,
	Date date,
	player_of_match varchar,
	venue varchar,
	neutral_venue int,
	team1 varchar,
	team2 varchar,
	toss_winner varchar,
	toss_decision varchar,
	winner varchar,
	result varchar,
	result_margin int,
	eliminator varchar,
	method varchar,
	umpire1 varchar,
	umpire2 varchar);
set datestyle =dmy;
COPY IPL_matches ("id","city","date","player_of_match" ,"venue" ,"neutral_venue" ,"team1" ,
	"team2" ,"toss_winner" ,"toss_decision" ,"winner" ,"result" ,"result_margin" ,
	"eliminator" ,"method","umpire1" ,"umpire2")
FROM 'C:\Program Files\PostgreSQL\16\data\dataset\IPL Dataset\IPL_matches.csv' DELIMITER ',' CSV HEADER;

select * from IPL_matches;

/* Q4 */
SELECT bowler,
	ROUND(SUM(total_runs)/(COUNT(bowler)/6.0), 2) as economy
FROM ipl_ball
GROUP BY bowler
HAVING COUNT(bowler) > 500
ORDER BY economy
LIMIT 10;

/* Q5 */
WITH ValidDismissals AS (
SELECT bowler, is_wicket,
     CASE
         WHEN dismissal_kind IN ('bowled', 'caught', 'caught and bowled', 'hit wicket', 'lbw', 'stumped')
         THEN 1
            ELSE 0
        END AS is_valid_dismissal
FROM ipl_ball)
SELECT bowler,
    ROUND(COUNT(bowler) * 1.0 / SUM(is_valid_dismissal),2) AS economy
FROM ValidDismissals
GROUP BY bowler
HAVING COUNT(bowler) > 500
ORDER BY economy
LIMIT 10;

CREATE TABLE batting_sr (batsman varchar,batsman_sr float );
copy batting_sr("batsman","batsman_sr") from 'C:\Program Files\PostgreSQL\16\data\dataset\FinalProject_SQL Q1data' delimiter ',' csv header;
CREATE TABLE bowling_sr (bowler varchar,Bowling_sr float );

/* Q6 */
SELECT
a.batsman AS all_rounder,
a.batsman_sr,
b.bowling_sr
FROM batting_sr a
INNER JOIN
bowling_sr b ON a.batsman = b.bowler
ORDER BY
a.batsman_sr DESC,
b.bowling_sr ASC
LIMIT 10;


/* Extra Q1 */
select count(city) as city_count from IPL_matches;

/* Extra Q2 */
CREATE TABLE deliveries_v02 AS
	SELECT *,
		CASE
			WHEN total_runs >= 4 THEN 'boundary'
			WHEN total_runs = 0 THEN 'dot'
			ELSE 'other'
		END AS ball_result
FROM ipl_ball;

select * from deliveries_v02;

/* Extra Q3 */
select count(ball_result)as Dotball_count from deliveries_v02 where ball_result='dot' ;
select count(ball_result)as boundary_count from deliveries_v02 where ball_result='boundary' ;

select count('boundary') as boundary_count ,count('dot') as Dotball_count
from deliveries_v02
group by ball_result;

/* Extra Q4 */
select batting_team, count('boundary') as total_number_of_boundaries 
from deliveries_v02
group by batting_team
order by total_number_of_boundaries desc;

/* Extra Q5 */
select bowling_team, count('dot') as total_number_of_dotballs 
from deliveries_v02
group by bowling_team
order by total_number_of_dotballs desc;

/* Extra Q6 */
select count(dismissal_kind) as Total_number_of_dismissals
from deliveries_v02
where not dismissal_kind='NA';

/* Extra Q7 */
select bowler,sum(extra_runs) as maximum_extra_runs 
from deliveries_v02
group by bowler
	order by maximum_extra_runs desc
limit 5;

/* Extra Q8 */
CREATE TABLE deliveries_v03 AS
	SELECT
		d.*,
		m.venue,
		EXTRACT(year FROM m.date) AS Year
	FROM deliveries_v02 d
	LEFT JOIN
		IPL_matches m ON d.id = m.id;
drop Table deliveries_v03;
select * from deliveries_v03 ;

/* Extra Q9 */
select venue,sum(total_runs) as Total_runs from deliveries_v03
group by venue
order by Total_runs desc;


/* Extra Q10 */
select distinct venue from deliveries_v03; 
select Year,sum(total_runs) as Total_runs from deliveries_v03
where venue = 'Eden Gardens'
	group by Year
	order by Total_runs desc ;
