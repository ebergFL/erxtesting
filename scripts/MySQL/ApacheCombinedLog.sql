/*
 apache access log "combined log format" import to MySQL
 (used on cre8asiteforums)
*/

DROP TABLE IF EXISTS `test`.`apachelog`;

CREATE TABLE  `test`.`apachelog` (
  `remote_host`	varchar(17) DEFAULT NULL,
  `remote_logname`	varchar(45) DEFAULT NULL,
  `remote_user`	varchar(45) DEFAULT NULL,
  `date_time_str`		varchar(21) DEFAULT NULL,
  `date_time`		DATETIME NOT NULL,
  `first_line_of_request`	varchar(255) DEFAULT NULL,
  `last_request_status`	INT NOT NULL,
  `bytes_sent` 		INT,
  `referrer` 		varchar(255) DEFAULT NULL,
  `user_agent` 		text
);

LOAD DATA INFILE '/tmp/kim.log' INTO TABLE apachelog
  FIELDS TERMINATED BY ' ' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '';

UPDATE apachelog
  SET date_time = STR_TO_DATE( date_time_str , '[%d/%b/%Y:%H:%i:%s' );

/*
 optional, omit if you wish to keep the date string or expect to 
 import additional logs; an alternate is to NULL the column (below)
* /
ALTER TABLE apachelog
  DROP COLUMN date_time_str;
* /

UPDATE apachelog
  SET date_time_str = NULL
    WHERE date_time_str is not NULL;
*/
/*
 http://www.freeopenbook.com/mysqlcookbook/mysqlckbk-CHP-18-SECT-15.html
 18.15.5 Analyzing the Log File
 Now that you have Apache logging into the database, what can you do with the 
 information? That depends on what you want to know. Here are some examples 
 that show the kinds of questions you can use MySQL to answer easily:
*/

-- How many records are in the request log?
SELECT COUNT(*) FROM apachelog;

-- How many different client hosts have sent requests?
SELECT COUNT(DISTINCT remote_host) FROM apachelog;

-- How many different pages have clients requested?
SELECT COUNT(DISTINCT first_line_of_request) FROM apachelog;

-- What are the ten most popular pages?
SELECT first_line_of_request, COUNT(*) AS count FROM apachelog
  GROUP BY first_line_of_request ORDER BY count DESC LIMIT 10;

-- How many requests have been received for those useless, wretched favicon.ico 
-- files that certain browsers like to check for?
SELECT COUNT(*) FROM apachelog WHERE first_line_of_request LIKE '%/favicon.ico%';

-- What is the range of dates spanned by the log?
SELECT MIN(date_time), MAX(date_time) FROM apachelog;

-- How many requests have been received each day?
SELECT FROM_DAYS(TO_DAYS(date_time)) AS day, COUNT(*) FROM apachelog GROUP BY day;
-- Answering this question requires stripping off the time-of-day part from the 
-- date_time values so that requests received on a given date can be grouped. 
-- The query does this using TO_DAYS( ) and FROM_DAYS( ) to convert DATETIME 
-- values to DATE values. However, if you intend to run a lot of queries that 
-- use just the date part of the date_time values, it would be more efficient to 
-- create the apachelog table with separate DATE and TIME columns, change the 
-- LogFormat directive to produce the date and time as separate output values, 
-- and modify httpdlog.pl accordingly. Then you can operate on the request dates 
-- directly without stripping off the time, and you can index the date column for 
-- even better performance.

-- What is the hour-of-the-day request histogram?
SELECT HOUR(date_time) AS hour, COUNT(*) FROM apachelog GROUP BY hour;

-- What is the average number of requests received each day?
SELECT COUNT(*)/(TO_DAYS(MAX(date_time)) - TO_DAYS(MIN(date_time)) + 1) FROM apachelog;
-- The numerator is the total number of requests in the table. The denominator 
-- is the number of days spanned by the records.

-- What is the longest URL recorded in the table?
SELECT MAX(LENGTH(first_line_of_request)) FROM apachelog;
-- If the first_line_of_request column is defined as VARCHAR(255) and this query 
-- produces a value of 255, it's likely that some URL values were too long to 
-- fit in the column and were truncated at the end. To avoid this, you can 
-- convert the column to BLOB or TEXT (depending on whether or not you want the 
-- values to be case sensitive). For example, if you want case-sensitive values up 
-- to 65,535 characters long, modify the first_line_of_requestcolumn as follows:
ALTER TABLE apachelog MODIFY first_line_of_request BLOB NOT NULL;

-- What is the total number of bytes served and the average bytes per request?
SELECT
    COUNT(bytes_sent) AS requests,
    SUM(bytes_sent) AS bytes,
    AVG(bytes_sent) AS 'bytes/request'
FROM apachelog;
-- The query uses COUNT(bytes_sent) rather than COUNT(*) to count only those requests 
-- with a non-NULL bytes_sentvalue. (If a client requests a page twice, the server may 
-- respond to the second request by sending a header indicating that the page 
-- hasn't changed rather than by sending content. In this case, the log entry 
-- for the request will have NULL in the bytes_sent column.)

-- How much traffic has there been for each kind of file (based on filename 
--  extension such as .html, .jpg, or.php)?
SELECT
    SUBSTRING_INDEX(SUBSTRING_INDEX(first_line_of_request,'?',1),'.',-1) AS extension,
    COUNT(bytes_sent) AS requests,
    SUM(bytes_sent) AS bytes,
    AVG(bytes_sent) AS 'bytes/request'
FROM apachelog
WHERE first_line_of_request LIKE '%.%'
GROUP BY extension;
-- The WHERE clause selects only url values that have a period in them, to 
-- eliminate pathnames that name files that have no extension. To extract the 
-- extension values for the output column list, the innerSUBSTRING_INDEX( ) call 
-- strips off any parameter string at the right end of the URL and leaves the 
-- rest. (This turns a value like /cgi-bin/script.pl?id=43 into /cgi-bin/script.pl. 
-- If the value has no parameter part, SUBSTRING_INDEX( ) returns the entire string.) 
-- The outer SUBSTRING_INDEX( ) call strips everything up to and including the 
-- rightmost period from the result, leaving only the extension.


/*
 http://httpd.apache.org/docs/2.4/logs.html
 
 apache configuration for Common:
 LogFormat "%h %l %u %t \"%r\" %>s %b" common
 CustomLog logs/access_log common
 example log: 127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326
 
 apache configuration for Combined:
 LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" combined
 CustomLog log/acces_log combined
 example: 127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"

 apache configuration for Virtual Hosts:
 LogFormat "%v %l %u %t \"%r\" %>s %b" comonvhost
 CustomLog logs/access_log comonvhost
 The %v is used to log the name of the virtual host that is serving the request. 
 Then a program like split-logfile can be used to post-process the access log in 
 order to split it into one file per virtual host.  
*/
