/**
ʹ��system��¼
**/
--�鿴���ݿ�Ķ�����
select segment_type , count(1) from dba_segments group by segment_type;

/**
��ȷ��λ�����ڵ�λ��
**/
--��ѯ������Ϣ
select tablespace_name , file_id , extent_id , block_id , blocks , bytes
  from dba_extents 
 where owner = upper('scott') and segment_name = upper('emp');
 
--����������
alter table scott.emp allocate extent;

--�ٴβ�ѯ������Ϣ
select tablespace_name , file_id , extent_id , block_id , blocks , bytes
  from dba_extents 
 where owner = upper('scott') and segment_name = upper('emp');

--��ѯ�������ڵ������ļ�
select tablespace_name , file_name from dba_data_files where file_id = 4;

--��ѯ�����ڵı�ռ�
select tablespace_name from dba_segments where segment_name = upper('emp') and owner = upper('scott'); 


/**
�˽����ݿ�����ݴ洢�ṹ
**/
--ȷ�������ļ������ƺʹ�С
select name, ( block_size * file_size_blks/1024/1024 ) MB from v$controlfile;

--ȷ������������־�ļ������ƺʹ�С
select member , bytes/1024/1024 MB from v$log join v$logfile using (group#);

--ȷ�������ļ�����ʱ�ļ������ƺʹ�С
select name , bytes/1024/1024 MB from v$datafile
union all
select name , bytes/1024/1024 MB from v$tempfile;

/**
�鿴��ռ�ʹ�����
**/
--��ѯ��ռ��ʹ�����
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
������ռ�ʾ��
**/
--������ͨ��ռ�
create smallfile tablespace tbs_cime_data
datafile 'D:/developer/oracle/oradata/cime/tbs_cime_data_01.dbf'
size 100m autoextend on next 10m maxsize 10G,
'D:/developer/oracle/oradata/cime/tbs_cime_data_02.dbf'
size 100m autoextend on next 10m maxsize 10G
logging
extent management local
segment space management auto
default nocompress;

--������ʱ��ռ�
create temporary tablespace tbs_cime_temp
tempfile 'D:/developer/oracle/oradata/cime/tbs_cime_temp_01.dbf'
size 100m autoextend on next 10m maxsize 10G
extent management local;

--�����û�������ռ�
create user cime identified by cime
default tablespace tbs_cime_data
temporary tablespace tbs_cime_temp;
--���û���Ȩ
grant create session,connect,dba to cime;
