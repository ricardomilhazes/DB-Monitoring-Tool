-- Works well, does not show usage by temporary tablespaces

select df.tablespace_name "Tablespace", tbl.status, tbl.contents, totalusedspace "Used MB", (df.totalspace - tu.totalusedspace) "Free MB", df.totalspace "Total MB", round(100 * ( (df.totalspace - tu.totalusedspace)/ df.totalspace)) "Pct. Free"
from
(select tablespace_name,
round(sum(bytes) / 1048576) TotalSpace
from dba_data_files
group by tablespace_name) df,
(select round(sum(bytes)/(1024*1024)) totalusedspace, tablespace_name
from dba_segments
group by tablespace_name) tu
join dba_tablespaces tbl on tbl.tablespace_name = tu.tablespace_name
where df.tablespace_name = tu.tablespace_name;


-- Does not show all the required info but does show (kinda) the usage by the temporary tablespaces

select b.tablespace_name, tbs_size maxSizeMb, a.free_space freeSizeMb, (tbs_size - a.free_space) as "OCCUPIED_MB", round(((tbs_size - a.free_space)/tbs_size),2)*100 as "used_percentage"
from
(select tablespace_name, round(sum(bytes)/1024/1024 ,2) as free_space
from dba_free_space group by tablespace_name) a,
(select tablespace_name, sum(bytes)/1024/1024 as tbs_size
from dba_data_files group by tablespace_name
UNION
select tablespace_name, sum(bytes)/1024/1024 tbs_size
from dba_temp_files
group by tablespace_name ) b
where a.tablespace_name(+)=b.tablespace_name;

-- Shows the usage actually used by temporary tablespaces (i guess)

SELECT A.tablespace_name tablespace, D.mb_total, SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used, D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM v$sort_segment A, (
	SELECT B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
	FROM v$tablespace B, v$tempfile C
	WHERE 
	   B.ts# = C.ts#
	GROUP BY 
	   B.name, C.block_size
	) D
WHERE 
   A.tablespace_name = D.name
GROUP by 
   A.tablespace_name, 
   D.mb_total