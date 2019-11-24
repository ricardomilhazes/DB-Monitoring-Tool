DROP TABLE "DBMONITORING"."TABLESPACE" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."DATAFILE" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."USER" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."SESSION" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."QUOTA" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."QUOTA_HISTORY" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."SGA" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."SGA_HISTORY" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."PGA" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."PGA_HISTORY" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."CPU" CASCADE CONSTRAINTS;
DROP TABLE "DBMONITORING"."CPU_HISTORY" CASCADE CONSTRAINTS;
drop sequence tablespace_sq;
drop sequence datafile_sq;
drop sequence user_sq;
drop sequence session_sq;

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


CREATE TABLE "DBMONITORING"."TABLESPACE" 
    ("TABLESPACE_ID" NUMBER NOT NULL,   
    "NAME" VARCHAR2(200 BYTE) NOT NULL, 
    "STATUS" VARCHAR2(200 BYTE) NOT NULL,
    "TOTAL_SIZE" NUMBER NOT NULL, 
    "CONTENT" VARCHAR2(200 BYTE) NOT NULL,
    "USED_PERCENTAGE" NUMBER NOT NULL, 
    "MAX_SIZE" NUMBER NOT NULL, 
    "TIMESTAMP" TIMESTAMP NOT NULL,
    CONSTRAINT TABLESPACE_PK PRIMARY KEY (TABLESPACE_ID)
);

CREATE TABLE "DBMONITORING"."DATAFILE" 
   ("DATAFILE_ID" NUMBER NOT NULL,
    "NAME" VARCHAR2(200 BYTE) NOT NULL, 
    "TABLESPACE" NUMBER NOT NULL, 
    "CURRENT_SIZE" NUMBER NOT NULL,
    "STATUS" VARCHAR2(200 BYTE) NOT NULL,
    "AVAILABLE_SIZE" NUMBER NOT NULL, 
    "MAX_SIZE" NUMBER NOT NULL, 
    "AUTOEXTENSIBLE" VARCHAR2(10 BYTE) NOT NULL,
    "ONLINE_STATUS" VARCHAR2(200 BYTE) NOT NULL,
    "TIMESTAMP" TIMESTAMP NOT NULL,
    CONSTRAINT DATAFILE_PK PRIMARY KEY (DATAFILE_ID),
    CONSTRAINT FK_TABLESPACE FOREIGN KEY ("TABLESPACE")
        REFERENCES "DBMONITORING"."TABLESPACE"(TABLESPACE_ID)
);

CREATE TABLE "DBMONITORING"."USER" 
   ("USER_ID" NUMBER NOT NULL, 
	"USERNAME" VARCHAR2(200 BYTE) NOT NULL, 
	"ACCOUNT_STATUS" NUMBER NOT NULL, 
	"EXPIRATION_DATE" DATE NOT NULL, 
	"DEFAULT_TABLESPACE" NUMBER NOT NULL, 
	"TEMP_TABLESPACE" NUMBER NOT NULL, 
    "CREATION_DATE" DATE NOT NULL,
    "TIMESTAMP" TIMESTAMP NOT NULL,
    CONSTRAINT USER_PK PRIMARY KEY (USER_ID),
    CONSTRAINT FK_DEFTABLESPACE FOREIGN KEY (DEFAULT_TABLESPACE)
        REFERENCES "DBMONITORING"."TABLESPACE" (TABLESPACE_ID),
    CONSTRAINT FK_TEMPTABLESPACE FOREIGN KEY (TEMP_TABLESPACE)
        REFERENCES "DBMONITORING"."TABLESPACE" (TABLESPACE_ID)
);

CREATE TABLE "DBMONITORING"."QUOTA" 
   ("TABLESPACE_ID" NUMBER NOT NULL, 
	"USER_ID" NUMBER NOT NULL, 
	"CURRENT" NUMBER NOT NULL, 
	"MAX_SIZE" NUMBER NOT NULL,
    "TIMESTAMP" TIMESTAMP NOT NULL,
    CONSTRAINT TABLESPACE_ID_PK PRIMARY KEY (TABLESPACE_ID,USER_ID),
    CONSTRAINT TABLESPACE_ID_FK FOREIGN KEY (TABLESPACE_ID)
        REFERENCES "DBMONITORING"."TABLESPACE"(TABLESPACE_ID),
	CONSTRAINT USER_ID_FK FOREIGN KEY (USER_ID)
        REFERENCES "DBMONITORING"."USER"(USER_ID)
);

CREATE TABLE "DBMONITORING"."QUOTA_HISTORY" 
   ("TABLESPACE_ID" NUMBER NOT NULL, 
	"USER_ID" NUMBER NOT NULL,
    "TIMESTAMP" TIMESTAMP NOT NULL,
	"CURRENT" NUMBER NOT NULL, 
	"MAX_SIZE" NUMBER NOT NULL,
    CONSTRAINT TABLESPACE_ID_HIST_PK PRIMARY KEY (TABLESPACE_ID,USER_ID,TIMESTAMP)
);

CREATE TABLE "DBMONITORING"."SESSION" 
    ("SESSION_ID" NUMBER NOT NULL,
     "USERNAME" VARCHAR2(100 BYTE) NOT NULL,
     "STATUS" VARCHAR2(10 BYTE) NOT NULL,
     "SCHEMA_NAME" VARCHAR2(45 BYTE) NOT NULL,
     "TYPE" VARCHAR2(100 BYTE) NOT NULL,
     "LOGON_TIME" DATE NOT NULL,
     "TIMESTAMP" TIMESTAMP NOT NULL,
     "USER_ID" NUMBER NOT NULL,
     CONSTRAINT SESSION_ID PRIMARY KEY (SESSION_ID),
     CONSTRAINT USER_ID FOREIGN KEY (USER_ID)
        REFERENCES "DBMONITORING"."USER" (USER_ID)
);
   
CREATE TABLE "DBMONITORING"."CPU" 
   ("CPU_INSTANCE_ID" NUMBER  NOT NULL,  
    "CPU_COUNT" NUMBER NOT NULL,
    "TIMESTAMP" TIMESTAMP NOT NULL,
    CONSTRAINT CPU_ID_PK PRIMARY KEY (CPU_INSTANCE_ID)
);

CREATE TABLE "DBMONITORING"."CPU_HISTORY" 
   ("CPU_INSTANCE_ID" NUMBER  NOT NULL,
    "TIMESTAMP" TIMESTAMP NOT NULL,
    "CPU_COUNT" NUMBER NOT NULL,
    CONSTRAINT CPU_ID_HIST_PK PRIMARY KEY (CPU_INSTANCE_ID,TIMESTAMP)
);

CREATE TABLE "DBMONITORING"."SGA"
    ("SGA_ID" NUMBER NOT NULL,
     "NAME" VARCHAR2(100 BYTE) NOT NULL,
     "USED" NUMBER NOT NULL,
     "TIMESTAMP" TIMESTAMP NOT NULL,
     CONSTRAINT SGA_ID PRIMARY KEY (SGA_ID)
);

CREATE TABLE "DBMONITORING"."SGA_HISTORY"
    ("SGA_ID" NUMBER NOT NULL,
     "TIMESTAMP" TIMESTAMP NOT NULL,
     "NAME" VARCHAR2(100 BYTE) NOT NULL,
     "USED" NUMBER NOT NULL,
     CONSTRAINT SGA_ID_PK PRIMARY KEY (SGA_ID,TIMESTAMP)
);

CREATE TABLE "DBMONITORING"."PGA"
    ("PGA_ID" NUMBER NOT NULL,
     "NAME" VARCHAR2(100 BYTE) NOT NULL,
     "USED" NUMBER NOT NULL,
     "TIMESTAMP" TIMESTAMP NOT NULL,
     CONSTRAINT PGA_ID PRIMARY KEY (PGA_ID)
);

CREATE TABLE "DBMONITORING"."PGA_HISTORY"
    ("PGA_ID" NUMBER NOT NULL,
     "TIMESTAMP" TIMESTAMP NOT NULL,
     "NAME" VARCHAR2(100 BYTE) NOT NULL,
     "USED" NUMBER NOT NULL,
     CONSTRAINT PGA_ID_PK PRIMARY KEY (PGA_ID,TIMESTAMP)
);