CREATE DATABASE netflix_project_p4;

DROP TABLE IF EXISTS  netflix;

CREATE TABLE netflix
	(show_id VARCHAR(20) PRIMARY KEY,
	type VARCHAR(150),
	title VARCHAR(250),
	director VARCHAR(800),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added DATE,
	release_year INT,
	rating VARCHAR(50) ,
	duration VARCHAR(80),
	listed_in VARCHAR(800),
	description VARCHAR(800)		
	);

--Taking look  at the data
SELECT * FROM netflix;

--Making sure all data has been imported
SELECT COUNT(*) AS total_content FROM netflix;

--Listing distinct types
SELECT DISTINCT type FROM netflix;