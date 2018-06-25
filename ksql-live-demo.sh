TODO 
=> Not working within KSQL CLI... Need another solution.
=> Running generators in background process also not working (shows new data generated all the time)

# Preparation
confluent
confluent status
confluent start schema-registry 
cat  /Users/kai.waehner/git-projects/ksql/config/ksql-server.properties

/Users/kai.waehner/git-projects/ksql/bin/ksql-server-start /Users/kai.waehner/git-projects/ksql/config/ksql-server.properties 

/Users/kai.waehner/confluent-4.1.0/bin/ksql-datagen quickstart=users format=json topic=users maxInterval=1000 propertiesFile=/Users/kai.waehner/confluent-4.1.0/etc/ksql/datagen.properties 

/Users/kai.waehner/confluent-4.1.0/bin/ksql-datagen quickstart=pageviews format=delimited topic=pageviews maxInterval=100 propertiesFile=/Users/kai.waehner/confluent-4.1.0/etc/ksql/datagen.properties
  
/Users/kai.waehner/confluent-4.1.0/bin/ksql-datagen quickstart=ratings format=avro topic=ratings maxInterval=500


# do-it-live script
# doitlive play ksql-live-demo.sh -s 3 --shell /bin/zsh

/Users/kai.waehner/git-projects/ksql/bin/ksql http://localhost:8088  
  
SHOW TOPICS;

PRINT 'pageviews' FROM BEGINNING;

CREATE STREAM pageviews_original (viewtime bigint, userid varchar, pageid varchar) WITH (kafka_topic='pageviews', value_format='DELIMITED');

SHOW STREAMS;
DESCRIBE pageviews_original;

SELECT pageid, userid FROM pageviews_original LIMIT 10;

### STREAM => Always shows all data, not just one per key / ID
#SELECT * FROM pageviews_original; 
#EXPLAIN QUERY pageviews_original;


LIST TOPICS;
PRINT 'users' FROM BEGINNING;

CREATE TABLE users_original (registertime bigint, gender varchar, regionid varchar, userid varchar) WITH (kafka_topic='users', value_format='JSON', key = 'userid');

SHOW TABLES;

DESCRIBE users_original;

SELECT * FROM users_original LIMIT 10;

CREATE TABLE FEMALEUSERS AS SELECT * from users_original WHERE gender = 'FEMALE';
SELECT * FROM users_original WHERE gender = 'MALE' LIMIT 3;

CREATE STREAM pageviews_female AS SELECT users_original.userid AS userid, pageid, regionid, gender FROM pageviews_original LEFT JOIN users_original ON pageviews_original.userid = users_original.userid WHERE gender = 'FEMALE';

SELECT * FROM pageviews_female LIMIT 3;

PRINT 'ratings' FROM BEGINNING;

CREATE STREAM ratings WITH (KAFKA_TOPIC='ratings', VALUE_FORMAT='AVRO');

DESCRIBE ratings;
DESCRIBE EXTENDED ratings;
SELECT * FROM ratings LIMIT 10;
SELECT * FROM ratings WHERE stars <= 3 LIIMT 2;
  
exit
confluent destroy
confluent status