# README<br><br>

## Exploring Common SQL Queries, Aggregate Functions, Subqueries, and Views<br><br>

### Summary
In this project, I will share some of the most common SQL queries and subqueries using large datasets from *Google BigQuery*. There are several aggregate functions that I would use on this project such as: *count(), min(), max(), and sum()*. I will explain the use for each of these functions as we go along with the chapters of this presentation. Last, I will create a view in SQL to store the queries I have scripted for this project.<br><br>

Please see [Google BigQuery File](https://console.cloud.google.com/bigquery?sq=719953228463:63a491168e274db18514a03b27eeaff8) to view the queries used in this project. Note: You will need to be logged in to your Google account in order to access this file.<br><br>

### Google Cloud
Create a new project so that you can query the public dataset using [Google BigQuery](https://console.cloud.google.com/bigquery). You can find more information about using Google Cloud to query a public dataset [here](https://cloud.google.com/bigquery/docs/quickstarts/query-public-dataset-console?_ga=2.110530181.-1202785955.1647124723).


### Getting to Know the Data
Every time you are starting a new project with a a new dataset, it is recommended to spend time browsing it to get familiar with the information in the dataset. In this case, I will be using the *stackoverflow* dataset from bigquery-public-data. Getting to know the schema, details, and running a preview of the dataset are part of the introduction.

View the schema of a dataset in BigQuery:
```
SELECT * FROM `bigquery-public-data.stackoverflow`.INFORMATION_SCHEMA.TABLES
```

Preview the table we are going to work from the dataset:
```
SELECT * FROM `bigquery-public-data.stackoverflow.stackoverflow_posts` LIMIT 100
```

I will be using the following from *bigquery-public-data*:
Dataset: **stackoverflow**
Table: **stackoverflow_posts**

To view the table details, go to the *Details* tab within the table you have selected.<br>

Once I have loaded the dataset and have become familiar with it, I will create a list of questions to try and get answers. As mentioned previously, I have chosen the *stackoverflow_posts* table to work with. Now I would like to answer a few questions about the data as shown below:
- **What is the lowest score given to a post on the Stack Overflow site?**
- **What is the highest score given to a post on the Stack Overflow site?**

**Lowest Score:**<br>
I am using the aggregate function ```MIN()``` to obtain the lowest score within the column name *score* in the table *stackoverflow_posts*.
```
SELECT
MIN(score) AS lowest_score
FROM
`bigquery-public-data.stackoverflow.stackoverflow_posts`;
```

**Highest Score:**<br>
Similar to ```MIN()```, I am using the aggregate function ```MAX()``` to obtain the highest score within the column name *score* in the table *stackoverflow_posts*.
```
SELECT
MAX(score) AS highest_score
FROM
`bigquery-public-data.stackoverflow.stackoverflow_posts`;
```

### Cleaning the Data
While analyzing the data, I've noticed some posts have null values in the view counts. I can see there is a relation between view counts and scores so I will need to optimize the previous query for minimun and maximun scores so that it excludes any null values from the view count.

I am running the script below to confirm there are not null values in the *view_count* column. 
Note I am ordering the column by default in ascending order to get the lowest numbers on the top, also I am limiting the output to 100 rows due to the nature of the size of this table.
```
SELECT view_count
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
ORDER BY view_count
LIMIT 100; 
```
Exclude any null values from the *view_count* column. I am using the ```IS NOT NULL``` operator after the ```WHERE``` clause.
```
SELECT view_count
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE view_count IS NOT NULL
ORDER BY view_count
LIMIT 100;
```
Now that we have cleaned up the data, we can confirm the lowest and highest scores we are going to query are valid and have view counts.
```
SELECT
MIN(score) AS lowest_score, MAX(score) as highest_score
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE view_count IS NOT NULL;
```

### Organizing, Validating, Commenting the Data
There are different ways to organize your data. It all depends on the task and the project you are working on at the time. For this instance, I will need to answer a few questions now that I have cleaned up the data, therefore I will use the aggregate function ```SUM()```, the clause ```ORDER BY DESC``` and the comparison operator```<=``` to organize and validate the data.

I will start with analyzing the top 10 lowest and highest scores:

```
SELECT
id, MIN(score) AS lowest_scores, view_count, comment_count
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE view_count IS NOT null
GROUP BY id, view_count, comment_count
ORDER BY MIN(score)
LIMIT 10;
```

```
SELECT
id, MAX(score) AS highest_scores, view_count, comment_count
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE view_count IS NOT null
GROUP BY id, view_count, comment_count
ORDER BY MAX(score) DESC
LIMIT 10;
```

- **What is the sum of scores, views count, and comments count for the top 10 lowest-score posts on Stack Overflow site?**
- **What is the sum of scores, views count, and comments count for the top 10 highest-score posts on Stack Overflow site?**


**Lowest Score Summary:**<br>
```
-- lowest score summary
-- show any score value equal or lower than -43
SELECT
SUM(score) AS total_lowest_score, 
SUM(view_count) AS total_view_count, 
SUM(comment_count) AS total_comm_count
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE score <= -43 AND view_count IS NOT null;
```

**Highest Score Summary:**<br>
```
-- highest score summary
-- show any score value equal or greater than 5005
SELECT
SUM(score) AS total_highest_score, 
SUM(view_count) AS total_view_count, 
SUM(comment_count) AS total_comm_count
FROM `bigquery-public-data.stackoverflow.stackoverflow_posts`
WHERE score >= 5005 AND view_count IS NOT null;
``` 

### Subqueries

In this example, I am using a subquery to summarize the data in this table.

```
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
```

### Subquery Results:
## ![results](https://i.ibb.co/wcfKMHB/subquery-results.jpg)

### Create Views

Now that I have created various scripts I can store them in a *view* for later use. Below I have added the line ```CREATE VIEW `my_dataset.my_view_name`(highest_score, hs_view_count, hs_comm_count, best_score, lowest_score, ls_view_count, ls_comm_count, worst_score) AS (***)``` to create view in my dataset. When you are creating a view in BigQuery you need to ensure you name each column after you declare your dataset name. Example: ```CREATE VIEW `my_dataset.my_view`(column1, column2,...)```.

```
-- create a view called data_metrics_view in my_dataset
CREATE VIEW `my_dataset.data_metrics_view`(highest_score, hs_view_count, hs_comm_count, best_score, lowest_score, ls_view_count, ls_comm_count, worst_score) AS (
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
```

To query this view, use the following line:
```
SELECT * FROM `my_dataset.data_metrics_view`;
```

### Create View Results
### ![create view](https://i.ibb.co/p1bsKGG/view-results.jpg)

### Closing
I was able to ask questions about the data, filter the data as needed, and identify min and max values within a large dataset. I ranked and organized in a list of top 10 the lowest and highest scores using operators and clauses, and I also analyzed the views counts per posts. Furthermore, I used aggregate functions to quantify scores, views, comments, users, and posts. I used subqueries to pivot data and get a high level view of the dataset. Last, I create views to speed up the process and eliminate redundancy in some of the queries.
