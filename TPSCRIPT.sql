DROP TABLE "DBMONITORING"."TABLESPACE" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."DATAFILE" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."USERS" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."SESSION" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."QUOTA" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."QUOTA_HISTORY" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."RESOURCE" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."RESOURCE_HISTORY" CASCADE CONSTRAINTS;
drop sequence tablespace_sq;
drop sequence datafile_sq;
drop sequence user_sq;
drop sequence session_sq;
drop sequence resource_sq;

create sequence tablespace_sq
    start with 1
    increment by 1;

create sequence datafile_sq
    start with 1
    increment by 1;

create sequence user_sq
    start with 1
    increment by 1;

create sequence session_sq
    start with 1
    increment by 1;

create sequence resource_sq
    start with 1
    increment by 1;    


CREATE TABLE "DBMONITORING"."TABLESPACE" 
    ("TABLESPACE_ID" NUMBER NOT NULL,   
    "NAME" VARCHAR2(200 BYTE) NOT NULL, 
    "STATUS" VARCHAR2(200 BYTE) NOT NULL,
    "CONTENT" VARCHAR2(200 BYTE) NOT NULL,
    "USED_MB" NUMBER NOT NULL,
    "FREE_MB" NUMBER NOT NULL,
    "TOTAL_MB" NUMBER NOT NULL,
    "FREE_PERCENTAGE" NUMBER NOT NULL, 
    "MAX_SIZE" NUMBER NOT NULL, 
    "TIMESTAMP" TIMESTAMP NOT NULL,
    "ACTIVE" NUMBER(3) NOT NULL,
    CONSTRAINT TABLESPACE_PK PRIMARY KEY (TABLESPACE_ID)
);

CREATE TABLE "DBMONITORING"."DATAFILE" 
   ("DATAFILE_ID" NUMBER NOT NULL,
    "TABLESPACE_ID" NUMBER NOT NULL,
    "NAME" VARCHAR2(200 BYTE) NOT NULL,  
    "USED_MB" NUMBER NOT NULL,
    "FREE_MB" NUMBER NOT NULL,
    "TOTAL_MB" NUMBER NOT NULL,
    "FREE_PERCENTAGE" NUMBER NOT NULL, 
    "MAX_SIZE" NUMBER NOT NULL,
    "AUTOEXTENSIBLE" VARCHAR2(10 BYTE) NOT NULL,    
    "STATUS" VARCHAR2(200 BYTE) NOT NULL, 
    "ONLINE_STATUS" VARCHAR2(200 BYTE) NOT NULL,
    "TIMESTAMP" TIMESTAMP NOT NULL,
    "ACTIVE" NUMBER(3) NOT NULL,
    CONSTRAINT DATAFILE_PK PRIMARY KEY (DATAFILE_ID),
    CONSTRAINT FK_TABLESPACE_ID FOREIGN KEY ("TABLESPACE_ID")
        REFERENCES "DBMONITORING"."TABLESPACE"(TABLESPACE_ID)
);

CREATE TABLE "DBMONITORING"."USERS" 
   ("USER_ID" NUMBER NOT NULL, 
	"USERNAME" VARCHAR2(200 BYTE) NOT NULL, 
	"ACCOUNT_STATUS" VARCHAR2(200 BYTE) NULL, 
	"EXPIRATION_DATE" DATE NULL, 
	"DEFAULT_TABLESPACE" NUMBER NOT NULL, 
	"TEMP_TABLESPACE" NUMBER NULL, 
    "CREATION_DATE" DATE NULL,
    "TIMESTAMP" TIMESTAMP NOT NULL,
    "ACTIVE" NUMBER(3) NOT NULL,
    CONSTRAINT USER_PK PRIMARY KEY (USER_ID),
    CONSTRAINT FK_DEFTABLESPACE FOREIGN KEY (DEFAULT_TABLESPACE)
        REFERENCES "DBMONITORING"."TABLESPACE" (TABLESPACE_ID),
    CONSTRAINT FK_TEMPTABLESPACE FOREIGN KEY (TEMP_TABLESPACE)
        REFERENCES "DBMONITORING"."TABLESPACE" (TABLESPACE_ID)
);

CREATE TABLE "DBMONITORING"."QUOTA" 
   ("TABLESPACE_ID" NUMBER NOT NULL, 
	"USER_ID" NUMBER NOT NULL, 
	"USED" NUMBER NOT NULL, 
	"MAX_SIZE" NUMBER NOT NULL,
    "TIMESTAMP" TIMESTAMP NOT NULL,
    "ACTIVE" NUMBER(3) NOT NULL,
    CONSTRAINT TABLESPACE_ID_PK PRIMARY KEY (TABLESPACE_ID,USER_ID),
    CONSTRAINT TABLESPACE_ID_FK FOREIGN KEY (TABLESPACE_ID)
        REFERENCES "DBMONITORING"."TABLESPACE"(TABLESPACE_ID),
	CONSTRAINT USERS_ID_FK FOREIGN KEY (USER_ID)
        REFERENCES "DBMONITORING"."USERS"(USER_ID)
);

CREATE TABLE "DBMONITORING"."QUOTA_HISTORY" 
   ("TABLESPACE_ID" NUMBER NOT NULL, 
	"USER_ID" NUMBER NOT NULL,
	"USED" NUMBER NOT NULL, 
	"MAX_SIZE" NUMBER NOT NULL,
    "TIMESTAMP" TIMESTAMP NOT NULL, 
    "ACTIVE" NUMBER(3) NOT NULL,
    CONSTRAINT TABLESPACE_ID_HIST_PK PRIMARY KEY (TABLESPACE_ID,USER_ID)
);

CREATE TABLE "DBMONITORING"."SESSION" 
    ("SESSION_ID" NUMBER NOT NULL,
     "USER_ID" NUMBER NOT NULL,
     "SERIAL_N" NUMBER NOT NULL,
     "STATUS" VARCHAR2(10 BYTE) NOT NULL,
     "SCHEMA_NAME" VARCHAR2(45 BYTE) NOT NULL,
     "OSUSER" VARCHAR2 (100 BYTE) NOT NULL,
     "MACHINE" VARCHAR2 (100 BYTE) NOT NULL,
     "PORT" NUMBER NOT NULL,
     "TYPE" VARCHAR2(100 BYTE) NOT NULL,
     "LOGON_TIME" DATE NOT NULL,
     "TIMESTAMP" TIMESTAMP NOT NULL,
     "ACTIVE" NUMBER(3) NOT NULL,
     CONSTRAINT SESSION_ID PRIMARY KEY (SESSION_ID),
     CONSTRAINT USERS_ID FOREIGN KEY (USER_ID)
        REFERENCES "DBMONITORING"."USERS" (USER_ID)
);
   
CREATE TABLE "DBMONITORING"."RESOURCE" 
   ("RESOURCE_ID" NUMBER  NOT NULL,  
    "NAME" VARCHAR2(200 BYTE) NOT NULL,    
    "VALUE" NUMBER NOT NULL,
    "UNIT" VARCHAR2(45 BYTE) NOT NULL,
    "ORIGIN" VARCHAR2 (45 BYTE) NOT NULL,
    "TIMESTAMP" TIMESTAMP NOT NULL,
    CONSTRAINT RESOURCE_ID_PK PRIMARY KEY (RESOURCE_ID)
);

CREATE TABLE "DBMONITORING"."RESOURCE_HISTORY" 
   ("RESOURCE_ID" NUMBER  NOT NULL,  
    "NAME" VARCHAR2(200 BYTE) NOT NULL,    
    "VALUE" NUMBER NOT NULL,
    "UNIT" VARCHAR2(45 BYTE) NOT NULL,
    "ORIGIN" VARCHAR2 (45 BYTE) NOT NULL,
    "TIMESTAMP" TIMESTAMP NOT NULL,
    CONSTRAINT RESOURCEHISTORY_ID_PK PRIMARY KEY (RESOURCE_ID)
);

