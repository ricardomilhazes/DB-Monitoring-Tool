# usr/bin/env python3
import cx_Oracle
import re
import requests as req
import json
import time

class Tablespace:
	def __init__(self):
		self.name = None
		self.status = None
		self.max_size = None
		self.content = None
		self.total_size = 0
		self.free_percentage = 0

class Datafile:
	def __init__(self):
		self.name = None
		self.tablespace_name = None
		self.bytes = 0
		self.status = None
		self.maxbytes = None
		self.autoextensible = None	
		self.user_bytes = None
		self.online_status = None

class User:
	def __init__(self):
		self.username = None
		self.account_status = None
		self.expiration_date = None
		self.default_tablespace = None
		self.temp_tablespace = None
		self.creation_date = None

class Session:
	def __init__(self):
		self.sid = None
		self.username = None
		self.status = None
		self.schemaname = None
		self.type = None
		self.logon_time = None

class SGA:
	def __init__(self):
		self.name = None
		self.value = None

class PGA:
	def __init__(self):
		self.name = None
		self.value = None
		self.unit = None

class CPU:
	def __init__(self):
		self.username = None
		self.count = None

class Quota:
	def __init__(self):
		self.tablespace_name = None
		self.username = None
		self.current = None
		self.max_size = None

def execute():

	con= cx_Oracle.connect("sys", "oracle", "localhost/orcl", mode = cx_Oracle.SYSDBA, encoding="UTF-8")

	cur = con.cursor()

	dbm = cx_Oracle.connect("dbmonitoring", "pass", "localhost/orcl", encoding="UTF-8")

	dbc = dbm.cursor()

	### TABLESPACES ###

	dbc.execute("update dbmonitoring.tablespace set active = 0")

	tablespaces = cur.execute("(select df.tablespace_name \"Tablespace\", tbl.status, tbl.contents, (df.totalspace - fs.free_space) \"Used MB\", fs.free_space \"Free MB\", df.totalspace \"Total MB\", round(100 * (fs.free_space/ df.totalspace)) \"Pct. Free\", round(df.MAXSIZE,1) capacity from (select tablespace_name, round(sum(bytes) / 1048576) TotalSpace, sum(decode(autoextensible,'YES',maxbytes,bytes))/(1024*1024*1024) maxsize from dba_data_files group by tablespace_name) df, (select tablespace_name, round(sum(bytes)/(1024*1024)) free_space from dba_free_space group by tablespace_name) fs join dba_tablespaces tbl on tbl.tablespace_name = fs.tablespace_name where df.tablespace_name = fs.tablespace_name) union (select dtf.tablespace_name, dtf.status, tbl.contents, round((sum(dtf.bytes) - sum(dtf.user_bytes))/(1024*1024),2) \"Used MB\", round(sum(dtf.user_bytes)/(1024*1024),2) \"Free MB\", round(sum(dtf.bytes) / 1048576) \"Total MB\", round(((sum(dtf.user_bytes)/(1024*1024))/(sum(dtf.bytes) / 1048576))*100,2) \"Pct. Free\", round(sum(decode(dtf.autoextensible,'YES',dtf.maxbytes,dtf.bytes))/(1024*1024),2) \"Capacity\" from dba_temp_files dtf join dba_tablespaces tbl on tbl.tablespace_name = dtf.tablespace_name group by dtf.tablespace_name, dtf.status, tbl.contents)")

	tablespace_array = {}

	for row in tablespaces:
		tbl = Tablespace()
		tbl.name = row[0]
		tbl.status = row[1]
		tbl.content = row[2]
		tbl.used_mb = row[3]
		tbl.free_mb = row[4]
		tbl.total_mb = row[5]
		tbl.used_perc = row[6]
		tbl.max_size = row[7]
		tablespace_array[tbl.name] = tbl


	for k,v in tablespace_array.items():
		
		sql = "merge into dbmonitoring.tablespace tbl using (select (:tablespace_name) as name from dual) src on (tbl.name = src.name) when matched then update set status = :status, content = :content, used_mb = :used_mbb, free_mb = :free_mb, total_mb = :total_mb, free_percentage = :used_perc, max_size = :max_size, active = 1, timestamp = (select current_timestamp from dual) when not matched then insert (tablespace_id, name, status, content, used_mb, free_mb, total_mb, free_percentage, max_size, active, timestamp) values (dbmonitoring.tablespace_sq.nextval,:name,:status,:content,:used_mb,:free_mb,:total_mb,:used_perc,:max_size, 1, (select current_timestamp from dual))"	

		values = (v.name, v.status, v.content, v.used_mb, v.free_mb, v.total_mb, v.used_perc, v.max_size, v.name, v.status, v.content, v.used_mb, v.free_mb, v.total_mb, v.used_perc, v.max_size)
		
		dbc.execute(sql,values)

	dbm.commit()


	### DATAFILES ###

	dbc.execute("update dbmonitoring.datafile set active = 0")

	datafiles = cur.execute("(select dtf.tablespace_name, dtf.file_name, round((sum(dtf.bytes) - sum(dtf.user_bytes))/(1024*1024),2) \"Used MB\", round(sum(dtf.user_bytes)/(1024*1024),2) \"Free MB\", round(sum(dtf.bytes) / 1048576) \"Total MB\", round(((sum(dtf.user_bytes)/(1024*1024))/(sum(dtf.bytes) / 1048576))*100,2) \"Pct. Free\", round(sum(decode(dtf.autoextensible,'YES',dtf.maxbytes,dtf.bytes))/(1024*1024),2) \"Capacity\", dtf.autoextensible \"AutoExtensible\", dtf.status \"Status\", vtf.status \"Online Status\" from dba_temp_files dtf join dba_tablespaces tbl on tbl.tablespace_name = dtf.tablespace_name join v$tempfile vtf on dtf.file_id = vtf.file# group by dtf.tablespace_name, dtf.file_name, dtf.autoextensible, dtf.status, vtf.status) union (select dtf.tablespace_name, dtf.file_name, round((sum(dtf.bytes) - sum(dtf.user_bytes))/(1024*1024),2) \"Used MB\", round(sum(dtf.user_bytes)/(1024*1024),2) \"Free MB\", round(sum(dtf.bytes) / 1048576) \"Total MB\", round(((sum(dtf.user_bytes)/(1024*1024))/(sum(dtf.bytes) / 1048576))*100,2) \"Pct. Free\", round(sum(decode(dtf.autoextensible,'YES',dtf.maxbytes,dtf.bytes))/(1024*1024),2) \"Capacity\", dtf.autoextensible \"AutoExtensible\", dtf.status \"Status\", vtf.status \"Online Status\"  from dba_data_files dtf join dba_tablespaces tbl on tbl.tablespace_name = dtf.tablespace_name join v$datafile vtf on dtf.file_id = vtf.file# group by dtf.tablespace_name, dtf.file_name, dtf.autoextensible, dtf.status, vtf.status)")

	datafiles_dict = {} 

	for row in datafiles:
		df = Datafile()
		df.tablespace_name = row[0]
		df.file_name = row[1]
		df.used_mb = row[2]
		df.free_mb = row[3]
		df.total_mb = row[4]
		df.free_percentage = row[5]
		df.max_size = row[6]
		df.autoextensible = row[7]
		df.status = row[8]
		df.online_status = row[9]
		datafiles_dict[df.file_name] = df;
			
	for k,v in datafiles_dict.items():
		sql = "merge into dbmonitoring.datafile dtf using (select tablespace_id from dbmonitoring.tablespace where name = :tablespace_name) src on (dtf.tablespace_id = src.tablespace_id and dtf.name = :file_name) when matched then update set used_mb = :used_mb, free_mb = :free_mb, total_mb = :total_mb, free_percentage = :free_percentage, max_size = :max_size, autoextensible = :autoextensible, status = :status, online_status = :online_status, active = 1,timestamp = (select current_timestamp from dual) when not matched then insert (datafile_id, tablespace_id, name, used_mb, free_mb, total_mb, free_percentage, max_size, autoextensible, status, online_status, active, timestamp) values (dbmonitoring.datafile_sq.nextval,(select tablespace_id from dbmonitoring.tablespace where name = :tablespace_nam),:file_name, :used_mb, :free_mb, :total_mb, :free_percentage, :max_size, :autoextensible, :status, :online_status, 1, (select current_timestamp from dual))"

		values = (v.tablespace_name, v.file_name, v.used_mb, v.free_mb, v.total_mb, v.free_percentage, v.max_size, v.autoextensible, v.status, v.online_status, v.tablespace_name, v.file_name, v.used_mb, v.free_mb, v.total_mb, v.free_percentage, v.max_size, v.autoextensible, v.status, v.online_status)

		dbc.execute(sql,values)

	dbm.commit()


	### USERS ###

	dbc.execute("update dbmonitoring.users set active = 0")

	users = cur.execute("select username, account_status, expiry_date, default_tablespace, temporary_tablespace, created from dba_users")

	users_dict = {}

	for row in users:
		u = User()
		u.username = row[0]
		u.account_status = row[1]
		u.expiration_date = row[2]
		u.default_tablespace = row[3]
		u.temp_tablespace = row[4]
		u.creation_date = row[5]
		users_dict[u.username] = u
		
	for k,u in users_dict.items():
		sql = "merge into dbmonitoring.users u using (select (:username) as name from dual) src on (u.username = src.name) when matched then update set account_status = :account_stats, expiration_date = :expiration_date, default_tablespace = (select tablespace_id from dbmonitoring.tablespace where name = :default_tablespace), temp_tablespace = (select tablespace_id from dbmonitoring.tablespace where name = :temp_tablespace), creation_date = :creation_date, active = 1, timestamp = (select current_timestamp from dual) when not matched then insert (user_id, username, account_status, expiration_date, default_tablespace, temp_tablespace, creation_date, active, timestamp) values (dbmonitoring.user_sq.nextval, :username, :account_status, :expiration_date, (select tablespace_id from dbmonitoring.tablespace where name = :default_tablespace), (select tablespace_id from dbmonitoring.tablespace where name = :temp_tablespace), :creation_date, 1, (select current_timestamp from dual))"

		values = (u.username, u.account_status, u.expiration_date, u.default_tablespace, u.temp_tablespace, u.creation_date,u.username, u.account_status, u.expiration_date, u.default_tablespace, u.temp_tablespace, u.creation_date)
		
		dbc.execute(sql,values)

	dbm.commit()


	### SESSIONS ###

	dbc.execute("update dbmonitoring.sessions set active = 0")

	sessions = cur.execute("select s.sid, s.serial#, u.username, s.status, s.schemaname,s.osuser, s.machine, s.port, s.type, s.logon_time from v$session s join dba_users u on u.user_id = s.user# where s.username is not null")

	sessions_dict = {}

	for row in sessions:
		s = Session()
		s.sid = row[0]
		s.serial_n = row[1]
		s.username = row[2]
		s.status = row[3]
		s.schemaname = row[4]
		s.osuser = row[5]
		s.machine = row[6]
		s.port = row[7]
		s.type = row[8]
		s.logon_time = row[9]
		sessions_dict[s.serial_n] = s

	for k,v in sessions_dict.items():
		sql = "merge into dbmonitoring.sessions s using (select :sid as sid from dual) src on (src.sid = s.session_id) when matched then update set user_id = (select user_id from dbmonitoring.users where username = :username), serial_n = :serial_n, status = :status, schema_name = :schemaname, osuser = :osuser, machine = :machine, port = :port, type = :type, logon_time = :logon_time, active = 1, timestamp = (select current_timestamp from dual) when not matched then insert (session_id, user_id, serial_n, status, schema_name, osuser, machine, port, type, logon_time, active, timestamp) values (:sid,(select user_id from dbmonitoring.users where username = :username), :serial_n, :status, :schemaname, :osuser, :machine, :port, :type, :logon_time, 1,(select current_timestamp from dual))"

		values = (v.sid,v.username, v.serial_n, v.status, v.schemaname, v.osuser, v.machine, v.port, v.type, v.logon_time, v.sid, v.username, v.serial_n, v.status, v.schemaname, v.osuser, v.machine, v.port, v.type, v.logon_time)
		
		dbc.execute(sql,values)

	dbm.commit()

	### RESOURCES ###

	### SGA ###

	sga = cur.execute("select name, value from v$sga")

	sga_dict = {}

	for row in sga:
		s = SGA()
		s.name = row[0]
		s.value = row[1]
		sga_dict[s.name] = s		

	for k,v in sga_dict.items():
		sql = "merge into dbmonitoring.resources r using (select :name as name from dual) src on (r.name = src.name) when matched then update set r.value = :value, r.unit = 'BYTES', r.origin = 'SGA', r.timestamp = (select current_timestamp from dual) when not matched then insert (resource_id, name, value, unit, origin, timestamp) values (dbmonitoring.resource_sq.nextval, :name, :value, 'BYTES', 'SGA', (select current_timestamp from dual))"

		values = (v.name, v.value, v.name, v.value)
		
		dbc.execute(sql,values)

	dbm.commit()

	### PGA ###

	pga = cur.execute("select name, value, unit from v$pgastat")

	pga_dict = {}

	for row in pga:
		p = PGA()
		p.name = row[0]
		p.value = row[1]
		p.unit = row[2]
		pga_dict[p.name] = p

	for k,v in pga_dict.items():
		sql = "merge into dbmonitoring.resources r using (select :name as name from dual) src on (r.name = src.name) when matched then update set r.value = :value, r.unit = :unit, r.origin = 'PGA', r.timestamp = (select current_timestamp from dual) when not matched then insert (resource_id, name, value, unit, origin, timestamp) values (dbmonitoring.resource_sq.nextval, :name, :value, :unit, 'PGA',(select current_timestamp from dual))"

		values = (v.name, v.value, v.unit, v.name, v.value, v.unit)

		dbc.execute(sql,values)

	dbm.commit()

	### CPU ###

	cpu = cur.execute("select ss.username,sum(VALUE/100) cpu_usage_seconds from v$session ss, v$sesstat se, v$statname sn where se.STATISTIC# = sn.STATISTIC# and NAME like '%CPU used by this session%' and se.SID = ss.SID and ss.status='ACTIVE' and ss.username is not null group by ss.username")

	cpu_dict = {}

	for row in cpu:
		c = CPU()
		c.username = row[0]
		c.count = row[1]
		cpu_dict[c.username] = c	


	for k,v in cpu_dict.items():
		sql = "merge into dbmonitoring.resources r using (select :name as name from dual) src on (r.name = src.name) when matched then update set r.value = :value, r.unit = 'SECS', r.origin = 'CPU', r.timestamp = (select current_timestamp from dual) when not matched then insert (resource_id, name, value, unit, origin, timestamp) values (dbmonitoring.resource_sq.nextval, :name, :value, 'SECS', 'CPU', (select current_timestamp from dual))"

		values = (v.username, v.count, v.username, v.count)
			
		dbc.execute(sql,values)


	dbm.commit()

	### QUOTAS ###

	dbc.execute("update dbmonitoring.quota set active = 0")

	quotas = cur.execute("select tablespace_name, username, bytes, max_bytes from dba_ts_quotas")

	quota_array = []

	for row in quotas:
		q = Quota()
		q.tablespace_name = row[0]
		q.username = row[1]
		q.current = row[2]
		q.max_size = row[3]
		quota_array.append(q)

	for v in quota_array:	
		sql = "merge into dbmonitoring.quota q using (select :tablespace_name tbl_name, :username uname from dual) src on (q.tablespace_id = (select tablespace_id from dbmonitoring.tablespace where name = src.tbl_name) and q.user_id = (select user_id from dbmonitoring.users where username = src.uname)) when matched then update set q.used = :curr, q.max_size = :max_size, active = 1, timestamp = (select current_timestamp from dual) when not matched then insert (tablespace_id, user_id, used, max_size, active, timestamp) values ((select tablespace_id from dbmonitoring.tablespace where name = src.tbl_name),(select user_id from dbmonitoring.users where username = src.uname),:curr,:max_size, 1, (select current_timestamp from dual)) "

		values = (v.tablespace_name, v.username,v.current,v.max_size,v.current,v.max_size)
		
		dbc.execute(sql,values)

	dbm.commit()
	cur.close()
	con.close()
	dbc.close()
	dbm.close()


def main():
	while True:
		execute()
		time.sleep(10)

if __name__ == '__main__':
	main()
