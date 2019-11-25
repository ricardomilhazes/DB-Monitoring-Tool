# DB-Monitoring-Tool
## Database Monitoring Tool for performance evaluation
### Tables and Attributes to build logical model

#### DBA_TABLESPACES:
  - TABLESPACE_NAME (PK)
  - STATUS
  - TOTAL_SIZE (CURRENT)
  - CONTENTS/TYPE
  - USED_%
  - MAX_SIZE

#### DBA_DATA_FILES:
  - DATAFILE_NAME (PK)
  - TABLESPACE_NAME (FK)
  - BYTES (CURRENT)
  - STATUS
  - USERBYTES (AVAILABLE_SIZE)
  - MAXBYTES
  - AUTOEXTENSIBLE (BIN)  
  - ONLINE_STATUS

#### DBA_USERS:
  - USERNAME (PK)
  - ACCOUNT_STATUS
  - EXPIRATION_DATE
  - DEFAULT_TABLESPACE (FK)
  - TEMP_TABLESPACE (FK)
  - CREATION_DATE

#### DBA_CPU_USAGE_STATISTICS (Not using this anymore, check collector.py)
  - DBID (PK)
  - TIMESTAMP
  - CPU_COUNT

#### DBA_TS_QUOTAS
  - TABLESPACE_NAME (PK-FK)
  - USERNAME (PK-FK)
  - BYTES (CURR)
  - MAX_BYTES
  
#### V$SESSION
  - SID (PK)
  - USERNAME
  - STATUS
  - SCHEMANAME
  - TYPE
  - LOGON_TIME
  - USER# (FK)
  
#### V$PGASTAT
  - NAME
  - VALUE

#### V$SGA
  - NAME
  - VALUE

## Authors

  - **A81919** Ricardo Milhazes
  - **A82892** Francisco Reinolds
  - **A82136** José Costa
  - **A81922** Tiago Sousa
