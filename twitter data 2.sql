----------------------------------------DATA CLEANING----------------------------------------

SELECT *
FROM [master].[dbo].[Twitter Data]


SELECT text, SUBSTRING(text,1,CHARINDEX(' https',text))as Texts,SUBSTRING(text,CHARINDEX('https',text),LEN(text)) as TextWebPage
FROM [master].[dbo].[Twitter Data]

----------------------------------------Breaking out Text into individual columns----------------------------------------

ALTER TABLE [master].[dbo].[Twitter Data]
ADD Texts varchar(256)


UPDATE [master].[dbo].[Twitter Data] 
SET Texts = SUBSTRING(text,1,CHARINDEX(' https',text))


ALTER TABLE [master].[dbo].[Twitter Data]
ADD TextWebPage varchar(256)


UPDATE [master].[dbo].[Twitter Data] 
SET TextWebPage = SUBSTRING(text,CHARINDEX('https',text),LEN(text))




----------------------------------------removing strings from TextWebPage and leaving only the websites----------------------------------------

SELECT Text,TextWebPage, Texts
,CASE
	WHEN TextWebPage LIKE 'https%' THEN TextWebPage 
	ELSE NULL
END
FROM [master].[dbo].[Twitter Data]


UPDATE [master].[dbo].[Twitter Data]
SET TextWebPage = CASE
	WHEN TextWebPage LIKE 'https%' THEN TextWebPage 
	ELSE NULL
END
FROM [master].[dbo].[Twitter Data]

----------------------------------------filling in the Texts column with missing values----------------------------------------


SELECT Text,TextWebPage, Texts
FROM [master].[dbo].[Twitter Data]
WHERE Text NOT LIKE '%https%' 


UPDATE [master].[dbo].[Twitter Data]
SET Text = Texts
FROM [master].[dbo].[Twitter Data]
WHERE Text NOT LIKE '%https%'


----------------------------------------splitting Timestamp column into date and time columns----------------------------------------

SELECT timestamp,SUBSTRING(timestamp,1,10) AS Date,SUBSTRING(timestamp,12,8) AS Time
FROM [master].[dbo].[Twitter Data]


ALTER TABLE [master].[dbo].[Twitter Data]
ADD Date nvarchar(256)


UPDATE [master].[dbo].[Twitter Data]
SET Date = SUBSTRING(timestamp,1,10)


ALTER TABLE [master].[dbo].[Twitter Data]
ADD Time nvarchar(256)


UPDATE [master].[dbo].[Twitter Data]
SET Time = SUBSTRING(timestamp,12,8)


----------------------------------------Breaking retweeted_status_timestamp into individual columns----------------------------------------

SELECT *
FROM [master].[dbo].[Twitter Data]
WHERE retweeted_status_timestamp IS NOT NULL


SELECT retweeted_status_timestamp,SUBSTRING(retweeted_status_timestamp,1,10) AS retweeted_status_date,SUBSTRING(retweeted_status_timestamp,12,8) AS retweeted_status_time
FROM [master].[dbo].[Twitter Data]
WHERE retweeted_status_timestamp IS NOT NULL


ALTER TABLE [master].[dbo].[Twitter Data]
ADD retweeted_status_date nvarchar(256)


UPDATE [master].[dbo].[Twitter Data]
SET retweeted_status_date = SUBSTRING(retweeted_status_timestamp,1,10)


ALTER TABLE [master].[dbo].[Twitter Data]
ADD retweeted_status_time nvarchar(256)


UPDATE [master].[dbo].[Twitter Data]
SET retweeted_status_time = SUBSTRING(retweeted_status_timestamp,12,8)


----------------------------------------getting column for tweeting device----------------------------------------
SELECT *
FROM [master].[dbo].[Twitter Data]
WHERE source NOT LIKE '<%'


SELECT source,SUBSTRING(source,CHARINDEX('">',source)+2,CHARINDEX('/',source)+3) AS TweetingDevice
FROM [master].[dbo].[Twitter Data]
WHERE source NOT LIKE '%iphone%'


ALTER TABLE [master].[dbo].[Twitter Data]
ADD TweetingDevice nvarchar(256)


UPDATE [master].[dbo].[Twitter Data]
SET TweetingDevice = SUBSTRING(source,CHARINDEX('">',source)+2,CHARINDEX('/',source)+3)


SELECT TweetingDevice + 'e'
FROM [master].[dbo].[Twitter Data]
WHERE TweetingDevice NOT LIKE '%twitter%'

UPDATE [master].[dbo].[Twitter Data]
SET TweetingDevice = TweetingDevice + 'e'
FROM [master].[dbo].[Twitter Data]
WHERE TweetingDevice NOT LIKE '%twitter%'


SELECT TweetingDevice
FROM [master].[dbo].[Twitter Data]
WHERE TweetingDevice LIKE '%//%' 

UPDATE [master].[dbo].[Twitter Data]
SET TweetingDevice = NULL
FROM [master].[dbo].[Twitter Data]
WHERE TweetingDevice LIKE '%//%'

----------------------------------------Filtering and merging doggo, floofer, pupper and puppo to one column (DogType)----------------------------------------

ALTER TABLE [master].[dbo].[Twitter Data]
ADD DogType nvarchar(256) 

UPDATE [master].[dbo].[Twitter Data]
SET DogType = CASE
	WHEN doggo+floofer+pupper+puppo  = 'doggoNoneNoneNone' THEN 'doggo' 
	WHEN doggo+floofer+pupper+puppo  = 'NoneflooferNoneNone' THEN 'floofer'
	WHEN doggo+floofer+pupper+puppo  = 'NoneNonepupperNone' THEN 'pupper'
	WHEN doggo+floofer+pupper+puppo  = 'NoneNoneNonepuppo' THEN 'puppo'  
	ELSE 'None'
END
FROM [master].[dbo].[Twitter Data]

----------------------------------------Data cleaning for Name and DogType Column----------------------------------------

UPDATE [master].[dbo].[Twitter Data]
SET name = 'NoDogName'
FROM [master].[dbo].[Twitter Data]
WHERE name = 'None'


DELETE FROM [master].[dbo].[Twitter Data]
WHERE name = 'a'


UPDATE [master].[dbo].[Twitter Data]
SET DogType = 'Not Specified'
FROM [master].[dbo].[Twitter Data]
WHERE DogType = 'None'

----------------------------------------REMOVING DUPLICATES----------------------------------------

WITH CTE_ROW AS
(
SELECT * ,ROW_NUMBER ()  OVER(PARTITION BY source, timestamp, retweeted_status_user_id, tweet_id,text ORDER BY tweet_id) as rownum
FROM [master].[dbo].[Twitter Data]
)
DELETE FROM CTE_ROW
WHERE rownum > 1

WITH CTE AS
(
SELECT * ,ROW_NUMBER ()  OVER(PARTITION BY retweeted_status_timestamp, retweeted_status_id, retweeted_status_user_id,expanded_urls ORDER BY tweet_id) as rownum
FROM [master].[dbo].[Twitter Data]
WHERE TextWebPage IS NULL
)
DELETE
FROM CTE



DELETE FROM [master].[dbo].[Twitter Data]
WHERE source IS NULL


DELETE FROM [master].[dbo].[Twitter Data]
WHERE expanded_urls = 'None'

----------------------------------------Converting data types of newly formed columns----------------------------------------

SELECT Texts, CONVERT(nvarchar,Texts), CONVERT(nvarchar,TextWebPage)
FROM [master].[dbo].[Twitter Data] 


ALTER TABLE [master].[dbo].[Twitter Data]
ADD TextWebPages nvarchar(256)


ALTER TABLE [master].[dbo].[Twitter Data]
ADD Text nvarchar(256)


UPDATE [master].[dbo].[Twitter Data] 
SET TextWebPages = CONVERT(nvarchar,TextWebPage)


UPDATE [master].[dbo].[Twitter Data] 
SET text= CONVERT(nvarchar,Texts)



----------------------------------------Deleting unused columns----------------------------------------
SELECT *
FROM [master].[dbo].[Twitter Data]


ALTER TABLE [master].[dbo].[Twitter Data]
DROP COLUMN timestamp, text, retweeted_status_timestamp,texts, TextWebPage,in_reply_to_status_id, in_reply_to_user_id,retweeted_status_id,
,retweeted_status_user_id,retweeted_status_date,retweeted_status_time,source,doggo, floofer, pupper, puppo






