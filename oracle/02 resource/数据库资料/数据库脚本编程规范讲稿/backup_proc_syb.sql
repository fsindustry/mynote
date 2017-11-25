--*********************************************************************
-- 版权所有 (C)2005, 中兴通讯股份有限公司
-- 数据库版本： Sybase ASE Enterprise 12.5
-- 内容摘要： 备份通用存储过程
-- 作    者： dxm
-- 完成日期： 2005.02.02
--**********************************************************************/
print    'pr_backuptable'
go
if exists (select * from sysobjects where id = object_id('pr_backuptable'))
   drop procedure pr_backuptable
go
create  procedure pr_backuptable(    
    @v_nowtablename       varchar(20),     --生产表名          
    @v_baktablename       varchar(20),     --备份表名          
    @v_nowkeepdaynum      int,             --生产表保留的天数  
    @v_bakkeepdaynum      int,             --备份表保留的天数  
    @v_datefield          varchar(20),     --筛选日期字段名    
    @v_datefieldformat    varchar(20),     --筛选日期字段的格式
    @v_dopernum           int,             --分批提交的间隔
    @v_extcond            varchar(255)     --用于进行比较的扩展条件 
)    
as    
    declare @v_nowkeeptodate   varchar(300)        --生产表保留时间的最小值 
    declare @v_bakkeeptodate   varchar(300)        --备份表保留时间的最小值 
    declare @v_strsql          varchar(6000) 
    declare @v_tmpbegindate    varchar(500) 
    declare @v_tmpnowbegindate varchar(300) 
    declare @v_tmpnowenddate   varchar(300) 
    declare @v_tmpbakenddate   varchar(300)
    declare @v_begintranscount int 
    
begin    
    select @v_begintranscount = @@trancount
    if (@v_datefieldformat<>'datetime') 
        and (@v_datefieldformat<>'yyyy.mm.dd')
        and (@v_datefieldformat<>'yyyy-mm-dd') 
        and (@v_datefieldformat<>'yyyy/mm/dd')
        and (@v_datefieldformat<>'yyyymmdd') 
        and (@v_datefieldformat<>'yyyy.mm.dd hh')
        and (@v_datefieldformat<>'yyyy-mm-dd hh') 
        and (@v_datefieldformat<>'yyyy/mm/dd hh')
        and (@v_datefieldformat<>'yyyymmddhh') 
        and (@v_datefieldformat<>'yyyy.mm.dd hh:mi:ss')
        and (@v_datefieldformat<>'yyyy-mm-dd hh:mi:ss') 
        and (@v_datefieldformat<>'yyyy/mm/dd hh:mi:ss')
        and (@v_datefieldformat<>'yyyymmddhhmiss')
    begin
        select '筛选日期字段的格式不在指定的范围'
        return
    end
    if not exists (select 1 from sysobjects where id = object_id(@v_nowtablename) and type = 'U')
    begin
        select @v_nowtablename+'生产表不存在'
        return
    end
    else if not exists (select 1 from sysobjects where id = object_id(@v_baktablename) and type = 'U')
    begin
        select @v_baktablename+'备份表不存在'
        return
    end 
    if not exists (select 1 from syscolumns where id = object_id(@v_nowtablename) and name=@v_datefield)
    begin
        select @v_datefield+'指定的字段不存在'
        return
    end
    if @v_nowkeepdaynum<0
    begin
        select '生产表保留天数小于0'
        return
    end
    if @v_nowkeepdaynum<0
    begin
        select '备份表保留天数小于0'
        return
    end
    if @v_dopernum<0
    begin
        select '提交间隔小于0'
        return
    end
         
    if (@v_datefieldformat='datetime') 
    begin 
        select @v_tmpbegindate='isnull(min('+@v_datefield+'),getdate())' 
        select @v_tmpnowbegindate='@v_nowbegindate'  
        select @v_tmpnowenddate  ='@v_nowenddate'      
        select @v_tmpbakenddate  ='@v_bakenddate'      
    end 
    else if (@v_datefieldformat='yyyy.mm.dd') 
    begin 
        select @v_dopernum=1440 
        select @v_tmpbegindate='convert(datetime,isnull(min('+@v_datefield+'),convert(char(11),getdate(),102)) +'' 00:00:00'')' 
        select @v_tmpnowbegindate='convert(char(11),@v_nowbegindate,102)'  
        select @v_tmpnowenddate  ='convert(char(11),@v_nowenddate,102)'      
        select @v_tmpbakenddate  ='convert(char(11),@v_bakenddate,102)'      
    end 
    else if (@v_datefieldformat='yyyy/mm/dd') 
    begin 
        select @v_dopernum=1440 
        select @v_tmpbegindate='convert(datetime,isnull(min('+@v_datefield+'),convert(char(11),getdate(),111)) +'' 00:00:00'')' 
        select @v_tmpnowbegindate='convert(char(11),@v_nowbegindate,111)'  
        select @v_tmpnowenddate  ='convert(char(11),@v_nowenddate,111)'      
        select @v_tmpbakenddate  ='convert(char(11),@v_bakenddate,111)'      
    end 
    else if (@v_datefieldformat='yyyy-mm-dd') 
    begin 
        select @v_dopernum=1440  
        select @v_tmpbegindate='convert(datetime,isnull(min('+@v_datefield+'),substring(convert(varchar,getdate(),112),1,4)+''-''+substring(convert(varchar,getdate(),112),5,2)+''-''+substring(convert(varchar,getdate(),112),7,2) +'' 00:00:00''))'  
        select @v_tmpnowbegindate='substring(convert(varchar,@v_nowbegindate,112),1,4)+''-''+substring(convert(varchar,@v_nowbegindate,112),5,2)+''-''+substring(convert(varchar,@v_nowbegindate,112),7,2)'   
        select @v_tmpnowenddate  ='substring(convert(varchar,@v_nowenddate,112),1,4)+''-''+substring(convert(varchar,@v_nowenddate,112),5,2)+''-''+substring(convert(varchar,@v_nowenddate,112),7,2)'       
        select @v_tmpbakenddate  ='substring(convert(varchar,@v_bakenddate,112),1,4)+''-''+substring(convert(varchar,@v_bakenddate,112),5,2)+''-''+substring(convert(varchar,@v_bakenddate,112),7,2)'       
    end 
    else if (@v_datefieldformat='yyyymmdd') 
    begin 
        select @v_dopernum=1440 
        select @v_tmpbegindate='convert(datetime,isnull(min('+@v_datefield+'),convert(char(11),getdate(),112)))' 
        select @v_tmpnowbegindate='convert(char(11),@v_nowbegindate,112)'  
        select @v_tmpnowenddate  ='convert(char(11),@v_nowenddate,112)'      
        select @v_tmpbakenddate  ='convert(char(11),@v_bakenddate,112)'      
    end 
    else if (@v_datefieldformat='yyyy.mm.dd hh') 
    begin 
        select @v_dopernum=60 
        select @v_tmpbegindate='convert(datetime,isnull(min('+@v_datefield+'),convert(char(11),getdate(),102)+substring(convert(char(10),getdate(),108),1,2)) +'':00:00'')' 
        select @v_tmpnowbegindate='convert(char(11),@v_nowbegindate,102)+substring(convert(char(10),@v_nowbegindate,108),1,2)'  
        select @v_tmpnowenddate  ='convert(char(11),@v_nowenddate,102)+substring(convert(char(10),@v_nowenddate,108),1,2)'      
        select @v_tmpbakenddate  ='convert(char(11),@v_bakenddate,102)+substring(convert(char(10),@v_bakenddate,108),1,2)'      
    end 
    else if (@v_datefieldformat='yyyy/mm/dd hh') 
    begin 
        select @v_dopernum=60 
        select @v_tmpbegindate='convert(datetime,isnull(min('+@v_datefield+'),convert(char(11),getdate(),111)+substring(convert(char(10),getdate(),108),1,2)) +'':00:00'')' 
        select @v_tmpnowbegindate='convert(char(11),@v_nowbegindate,111)+substring(convert(char(10),@v_nowbegindate,108),1,2)'  
        select @v_tmpnowenddate  ='convert(char(11),@v_nowenddate,111)+substring(convert(char(10),@v_nowenddate,108),1,2)'      
        select @v_tmpbakenddate  ='convert(char(11),@v_bakenddate,111)+substring(convert(char(10),@v_bakenddate,108),1,2)'      
    end 
    else if (@v_datefieldformat='yyyy-mm-dd hh') 
    begin 
        select @v_dopernum=60 
        select @v_tmpbegindate='convert(datetime,isnull(min('+@v_datefield+'),substring(convert(varchar,getdate(),112),1,4)+''-''+substring(convert(varchar,getdate(),112),5,2)+''-''+substring(convert(varchar,getdate(),112),7,2)+'' ''+substring(convert(char(10),getdate(),108),1,2))+'':00:00'')'  
        select @v_tmpnowbegindate='substring(convert(varchar,@v_nowbegindate,112),1,4)+''-''+substring(convert(varchar,@v_nowbegindate,112),5,2)+''-''+substring(convert(varchar,@v_nowbegindate,112),7,2)+'' ''+substring(convert(char(10),@v_nowbegindate,108),1,2)'  
        select @v_tmpnowenddate  ='substring(convert(varchar,@v_nowenddate,112),1,4)+''-''+substring(convert(varchar,@v_nowenddate,112),5,2)+''-''+substring(convert(varchar,@v_nowenddate,112),7,2)+'' ''+substring(convert(char(10),@v_nowenddate,108),1,2)'  
        select @v_tmpbakenddate  ='substring(convert(varchar,@v_bakenddate,112),1,4)+''-''+substring(convert(varchar,@v_bakenddate,112),5,2)+''-''+substring(convert(varchar,@v_bakenddate,112),7,2)+'' ''+substring(convert(char(10),@v_bakenddate,108),1,2)'  
    end
    else if (@v_datefieldformat='yyyymmddhh') 
    begin 
        select @v_dopernum=60 
        select @v_tmpbegindate='convert(datetime,substring(isnull(min('+@v_datefield+'),convert(char(11),getdate(),112)+substring(convert(char(10),getdate(),108),1,2)),1,8)+'' ''+substring(isnull(min('+@v_datefield+'),convert(char(11),getdate(),112)+substring(convert(char(10),getdate(),108),1,2)),9,2) +'':00:00'')' 
        select @v_tmpnowbegindate='convert(char(8),@v_nowbegindate,112)+substring(convert(char(10),@v_nowbegindate,108),1,2)'  
        select @v_tmpnowenddate  ='convert(char(8),@v_nowenddate,112)+substring(convert(char(10),@v_nowenddate,108),1,2)'      
        select @v_tmpbakenddate  ='convert(char(8),@v_bakenddate,112)+substring(convert(char(10),@v_bakenddate,108),1,2)'      
    end
    else if (@v_datefieldformat='yyyy.mm.dd hh:mi:ss') 
    begin 
        select @v_tmpbegindate='convert(datetime,isnull(min('+@v_datefield+'),convert(char(11),getdate(),102)+convert(char(10),getdate(),108)))' 
        select @v_tmpnowbegindate='convert(char(11),@v_nowbegindate,102)+convert(char(10),@v_nowbegindate,108)'  
        select @v_tmpnowenddate  ='convert(char(11),@v_nowenddate,102)+convert(char(10),@v_nowenddate,108)'      
        select @v_tmpbakenddate  ='convert(char(11),@v_bakenddate,102)+convert(char(10),@v_bakenddate,108)'      
    end
    else if (@v_datefieldformat='yyyy/mm/dd hh:mi:ss') 
    begin 
        select @v_tmpbegindate='convert(datetime,isnull(min('+@v_datefield+'),convert(char(11),getdate(),111)+convert(char(10),getdate(),108)))' 
        select @v_tmpnowbegindate='convert(char(11),@v_nowbegindate,111)+convert(char(10),@v_nowbegindate,108)'  
        select @v_tmpnowenddate  ='convert(char(11),@v_nowenddate,111)+convert(char(10),@v_nowenddate,108)'      
        select @v_tmpbakenddate  ='convert(char(11),@v_bakenddate,111)+convert(char(10),@v_bakenddate,108)'      
    end 
    else if (@v_datefieldformat='yyyy-mm-dd hh:mi:ss') 
    begin 
        select @v_tmpbegindate='convert(datetime,isnull(min('+@v_datefield+'),substring(convert(varchar,getdate(),112),1,4)+''-''+substring(convert(varchar,getdate(),112),5,2)+''-''+substring(convert(varchar,getdate(),112),7,2)+'' ''+convert(char(10),getdate(),108)))'  
        select @v_tmpnowbegindate='substring(convert(varchar,@v_nowbegindate,112),1,4)+''-''+substring(convert(varchar,@v_nowbegindate,112),5,2)+''-''+substring(convert(varchar,@v_nowbegindate,112),7,2)+'' ''+convert(char(10),@v_nowbegindate,108)'  
        select @v_tmpnowenddate  ='substring(convert(varchar,@v_nowenddate,112),1,4)+''-''+substring(convert(varchar,@v_nowenddate,112),5,2)+''-''+substring(convert(varchar,@v_nowenddate,112),7,2)+'' ''+convert(char(10),@v_nowenddate,108)'  
        select @v_tmpbakenddate  ='substring(convert(varchar,@v_bakenddate,112),1,4)+''-''+substring(convert(varchar,@v_bakenddate,112),5,2)+''-''+substring(convert(varchar,@v_bakenddate,112),7,2)+'' ''+convert(char(10),@v_bakenddate,108)'  
    end
    else if (@v_datefieldformat='yyyymmddhhmiss') 
    begin 
        select @v_tmpbegindate='convert(datetime,substring(isnull(min('+@v_datefield+'),convert(char(11),getdate(),112)+substring(convert(char(10),getdate(),108),1,2)),1,8)+'' ''+substring(isnull(min('+@v_datefield+'),convert(char(11),getdate(),112)+substring(convert(char(10),getdate(),108),1,2)),9,2) +'':''+substring(isnull(min('+@v_datefield+'),convert(char(11),getdate(),112)+substring(convert(char(10),getdate(),108),1,2)),11,2)+'':''+substring(isnull(min('+@v_datefield+'),convert(char(11),getdate(),112)+substring(convert(char(10),getdate(),108),1,2)),13,2))' 
        select @v_tmpnowbegindate='convert(char(8),@v_nowbegindate,112)+substring(convert(char(10),@v_nowbegindate,108),1,2)+substring(convert(char(10),@v_nowbegindate,108),4,2)+substring(convert(char(10),@v_nowbegindate,108),7,2)'  
        select @v_tmpnowenddate  ='convert(char(8),@v_nowenddate,112)+substring(convert(char(10),@v_nowenddate,108),1,2)+substring(convert(char(10),@v_nowenddate,108),4,2)+substring(convert(char(10),@v_nowenddate,108),7,2)'      
        select @v_tmpbakenddate  ='convert(char(8),@v_bakenddate,112)+substring(convert(char(10),@v_bakenddate,108),1,2)+substring(convert(char(10),@v_bakenddate,108),4,2)+substring(convert(char(10),@v_bakenddate,108),7,2)'      
    end 
    
    select @v_nowkeeptodate='dateadd(day,-'+convert(varchar,@v_nowkeepdaynum)+',getdate())'
    select @v_bakkeeptodate='dateadd(day,-'+convert(varchar,@v_bakkeepdaynum)+',getdate())'
    
    select @v_strsql='
    declare @v_nowbegindate  datetime
    declare @v_nowenddate    datetime
    declare @v_bakbegindate  datetime
    declare @v_bakenddate    datetime
    declare @v_rows int
    select @v_nowbegindate='+@v_tmpbegindate+' from '+@v_nowtablename+' where 1=1 '+@v_extcond+'
    select @v_nowenddate=dateadd(mi,'+convert(varchar,@v_dopernum)+',@v_nowbegindate)
    if @v_nowenddate>'+@v_nowkeeptodate+'
    begin
        select @v_nowenddate='+@v_nowkeeptodate+'
    end
    select @v_bakenddate='+@v_bakkeeptodate+'
    while (@v_nowbegindate < '+@v_nowkeeptodate+')
    begin
        insert into '+@v_baktablename+' select * from '+@v_nowtablename+' where '+@v_datefield+'>='+@v_tmpnowbegindate+' and '+@v_datefield+'<='+@v_tmpnowenddate+' '+@v_extcond+'
        delete from '+@v_nowtablename+' where '+@v_datefield+'>='+@v_tmpnowbegindate+' and '+@v_datefield+'<='+@v_tmpnowenddate+' '+@v_extcond+'
        select @v_nowbegindate='+@v_tmpbegindate+' from '+@v_nowtablename+' where 1=1 '+@v_extcond+'
        select @v_nowenddate=dateadd(mi,'+convert(varchar,@v_dopernum)+',@v_nowbegindate)
        if @v_nowenddate>'+@v_nowkeeptodate+'
        begin
            select @v_nowenddate='+@v_nowkeeptodate+'
        end
    end
    set rowcount 2000
    delete from '+@v_baktablename+' where '+@v_datefield+'<='+@v_tmpbakenddate+' '+@v_extcond+'
    select @v_rows = @@rowcount
    while (@v_rows > 0)
    begin
        delete from '+@v_baktablename+' where '+@v_datefield+'<='+@v_tmpbakenddate+' '+@v_extcond+'
        select @v_rows = @@rowcount
    end
    set rowcount 0'
    
    exec (@v_strsql)
    if (@@trancount <> @v_begintranscount)  
    begin
        rollback transaction
    end

    return
end
go
  