--*********************************************************************
-- ��Ȩ����:(C)2005, ����ͨѶ�ɷ����޹�˾
-- ���ݿ�汾:Sybase ASE Enterprise 12.0
-- ����ժҪ:1000��ҵ��Ľ���ű��ļ� 
-- ��    ��:dxm
-- �������:2005.03.23
-- �޸ļ�¼1�� 
--    �޸����ڣ�
--    �� �� �ţ�
--    �� �� �ˣ�
--    �޸����ݣ�
-- �޸ļ�¼2��
--**********************************************************************


--**************************************************
--  initialization  ��ʼ��            
--**************************************************

use master
go
exec sp_dboption 'zxdb_1000', 'trunc log on chkpt', true
go
use zxdb_1000
go
checkpoint
go
dump tran zxdb_1000 with no_log
go

--************************************************************
--  user and right creation �û���Ȩ�޵Ľ���      
--************************************************************

print 'add login and alias'
go
if not exists(select * from master..syslogins where name = 'zxdb_1000')
    exec sp_addlogin zxdb_1000, zxdb_1000, zxdb_1000
go
exec sp_dropalias zxdb_1000
go
exec sp_addalias zxdb_1000,dbo
go


--***********************************************************************
--  table creation    ���ݱ�Ĵ���       
--***********************************************************************

--�������ݱ�
print 't1000billinfo'
go
if exists(select 1 from sysobjects where id = object_id('t1000billinfo'))
    drop table t1000billinfo
go
create table t1000billinfo(
    id      int           not null,          --����id
    context varchar(255)  null               --��������
)
go
print   'idx_t1000billinfo01'
go
create unique index idx_t1000billinfo01 on t1000billinfo(id)
go
create index idx_t1000billinfo02 on t1000billinfo(context)
go
insert into t1000billinfo(id,context) values(1,'test1')
go
insert into t1000billinfo(id,context) values(2,'test2')
go



--**************************************************
--  procedure creation       �洢���̵Ĵ���
--**************************************************

--**************************************************
--  task creation       ���ݿ�����Ĵ���       
--**************************************************

--**************************************************
--  finalization     ����       
--**************************************************
use zxdb_1000
go
dump tran zxdb_1000 with no_log
go
