--*********************************************************************
-- 版权所有:(C)2005, 中兴通讯股份有限公司
-- 数据库版本:Sybase ASE Enterprise 12.0
-- 内容摘要:1000号业务的建表脚本文件 
-- 作    者:dxm
-- 完成日期:2005.03.23
-- 修改记录1： 
--    修改日期：
--    版 本 号：
--    修 改 人：
--    修改内容：
-- 修改记录2：
--**********************************************************************


--**************************************************
--  initialization  初始化            
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
--  user and right creation 用户及权限的建立      
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
--  table creation    数据表的创建       
--***********************************************************************

--留单内容表
print 't1000billinfo'
go
if exists(select 1 from sysobjects where id = object_id('t1000billinfo'))
    drop table t1000billinfo
go
create table t1000billinfo(
    id      int           not null,          --留单id
    context varchar(255)  null               --留单内容
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
--  procedure creation       存储过程的创建
--**************************************************

--**************************************************
--  task creation       数据库任务的创建       
--**************************************************

--**************************************************
--  finalization     结束       
--**************************************************
use zxdb_1000
go
dump tran zxdb_1000 with no_log
go
