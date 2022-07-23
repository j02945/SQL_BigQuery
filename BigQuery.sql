-- view the schema for this dataset
SELECT * FROM `bigquery-public-data.stackoverflow`.INFORMATION_SCHEMA.TABLES;

--- preview the table dataset
SELECT * FROM `bigquery-public-data.stackoverflow.stackoverflow_posts` LIMIT 100;

-- select the lowest score given to a post
SELECT
MIN(score) AS lowest_score
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`;

-- select the highest score given to a post
SELECT
MAX(score) AS highest_score
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`;

-- ensure the data is clean, check for null or zero values
SELECT view_count
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
ORDER BY view_count
LIMIT 100; 

-- exclude null values from the view count
SELECT view_count
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE view_count IS NOT NULL
ORDER BY view_count
LIMIT 100;

-- select lowest and highest score and ensure no null values in view count
SELECT
MIN(score) AS lowest_score, MAX(score) as highest_score
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE view_count IS NOT NULL;

-- get the 10 lowest scores
SELECT
id, MIN(score) AS lowest_scores, view_count, comment_count
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE view_count IS NOT null
GROUP BY id, view_count, comment_count
ORDER BY MIN(score)
LIMIT 10;

-- get the 10 highest scores
SELECT
id, MAX(score) AS highest_scores, view_count, comment_count
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE view_count IS NOT null
GROUP BY id, view_count, comment_count
ORDER BY MAX(score) DESC
LIMIT 10;

-- total sum of scores, views count, and comments count for the top 10 lowest-score posts
SELECT
SUM(score) AS total_lowest_score, 
SUM(view_count) AS total_view_count, 
SUM(comment_count) AS total_comm_count
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE score <= -43 AND view_count IS NOT null;

-- total sum of scores, views count, and comments count for the top 10 highest-score posts
SELECT
SUM(score) AS total_highest_score, 
SUM(view_count) AS total_view_count, 
SUM(comment_count) AS total_comm_count
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE score >= 5005 AND view_count IS NOT null;

-- create a view called data_metrics_view in my_dataset
-- create a subquery
-- get highest score, view, and comment totals
CREATE VIEW `my-project-93702-dataanalytics.stackoverflow_data.data_metrics_view2`(highest_score, hs_view_count, hs_comm_count, best_score, lowest_score, ls_view_count, ls_comm_count, worst_score) AS (
SELECT  
SUM(score) AS total_highest_score, 
SUM(view_count) AS hs_total_view_count, 
SUM(comment_count) AS hs_total_comm_count,

-- get the highest score
(SELECT MAX(score)
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE score >= 5005 AND view_count IS NOT null) AS the_best_score,

-- get lower score totals
(SELECT
SUM(score) 
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE score <= -43 AND view_count IS NOT null) AS total_lowest_score,

-- get lower view count
(SELECT
SUM(view_count) 
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE score <= -43 AND view_count IS NOT null) AS ls_total_view_count,

-- get lower comment count
(SELECT
SUM(comment_count) 
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE score <= -43 AND view_count IS NOT null) AS ls_total_comment_count,

-- get the lowest score
(SELECT MIN(score)
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE score <= -43 AND view_count IS NOT null) AS the_worst_score,

FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE score >= 5005 AND view_count IS NOT null
LIMIT 10
);