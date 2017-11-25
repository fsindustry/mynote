/**
使用system登录
**/
--查看数据库的段类型
select segment_type , count(1) from dba_segments group by segment_type;

/**
精确定位段所在的位置
**/
--查询区间信息
select tablespace_name , file_id , extent_id , block_id , blocks , bytes
  from dba_extents 
 where owner = upper('scott') and segment_name = upper('emp');
 
--创建新区间
alter table scott.emp allocate extent;

--再次查询区间信息
select tablespace_name , file_id , extent_id , block_id , blocks , bytes
  from dba_extents 
 where owner = upper('scott') and segment_name = upper('emp');

--查询区间所在的数据文件
select tablespace_name , file_name from dba_data_files where file_id = 4;

--查询段所在的表空间
select tablespace_name from dba_segments where segment_name = upper('emp') and owner = upper('scott'); 


/**
了解数据库的数据存储结构
**/
--确定控制文件的名称和大小
select name, ( block_size * file_size_blks/1024/1024 ) MB from v$controlfile;

--确定联机重做日志文件的名称和大小
select member , bytes/1024/1024 MB from v$log join v$logfile using (group#);

--确定数据文件和临时文件的名称和大小
select name , bytes/1024/1024 MB from v$datafile
union all
select name , bytes/1024/1024 MB from v$tempfile;

/**
查看表空间使用情况
**/
--查询表空间的使用情况
select t.tablespace_name as name,
       d.allocated as allocated,
       u.used,
       f.free,
       t.status,
       d.cnt,
       contents,
       t.extent_management as extman,
       t.segment_space_management as segman
  from dba_tablespaces t,
     ( select sum(bytes)/1024/1024 as allocated,
              count(file_id) as cnt
         from dba_data_files 
        where tablespace_name='EXAMPLE'
     ) d,
     ( select sum(bytes)/1024/1024 as free
         from dba_free_space
        where tablespace_name='EXAMPLE'
     ) f,
     ( select sum(bytes)/1024/1024 as used
         from dba_segments
        where tablespace_name='EXAMPLE'
     ) u
 where t.tablespace_name='EXAMPLE';
 
 
/**
创建表空间示例
**/
--创建普通表空间
create smallfile tablespace tbs_cime_data
datafile 'D:/developer/oracle/oradata/cime/tbs_cime_data_01.dbf'
size 100m autoextend on next 10m maxsize 10G,
'D:/developer/oracle/oradata/cime/tbs_cime_data_02.dbf'
size 100m autoextend on next 10m maxsize 10G
logging
extent management local
segment space management auto
default nocompress;

--创建临时表空间
create temporary tablespace tbs_cime_temp
tempfile 'D:/developer/oracle/oradata/cime/tbs_cime_temp_01.dbf'
size 100m autoextend on next 10m maxsize 10G
extent management local;

--创建用户关联表空间
create user cime identified by cime
default tablespace tbs_cime_data
temporary tablespace tbs_cime_temp;
--对用户授权
grant create session,connect,dba to cime;
