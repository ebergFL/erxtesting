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
 import additional logs
* /
ALTER TABLE apachelog
  DROP COLUMN date_time_str;
*/

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