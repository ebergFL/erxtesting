/*
 apache access log GSI Raw import to MySQL
*/

DROP TABLE IF EXISTS `test`.`apachelog`;

CREATE TABLE  `test`.`apachelog` (
  `date_time` DATETIME DEFAULT NULL,
  `vhost` varchar(30) DEFAULT NULL,
  `remote_host` varchar(17) DEFAULT NULL,
  `last_request_status` INT NOT NULL,
  `request_method` varchar(5) DEFAULT NULL,
  `request_path` varchar(255) DEFAULT NULL,
  `query_string` varchar(255) DEFAULT NULL,
  `request_protocol` varchar(10) DEFAULT NULL,
  `bytes_sent` INT,
  `session` text,
  `user_agent` text,
  `referrer` varchar(255) DEFAULT NULL,
  `response_microseconds` INT NOT NULL
);

LOAD DATA INFILE '/tmp/gsi.log' INTO TABLE apachelog
  FIELDS TERMINATED BY ' ' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
  (@var1, vhost, remote_host, last_request_status, request_method, request_path, 
  query_string, request_protocol, bytes_sent, session, user_agent, referrer, 
  response_microseconds)

SET date_time = STR_TO_DATE( @var1, '%d/%b/%Y:%H:%i:%s -0400');

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
