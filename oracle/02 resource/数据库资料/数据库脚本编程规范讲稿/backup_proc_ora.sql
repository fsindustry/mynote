--*********************************************************************
-- 版权所有 (C)2005, 中兴通讯股份有限公司
-- 数据库版本： Oracle 8i
-- 内容摘要： 备份通用存储过程
-- 作    者： yb
-- 完成日期： 2005.02.02
--**********************************************************************/
create or replace procedure pr_backuptable(
    v_nowtablename       varchar2,     --生产表名
    v_baktablename       varchar2,     --备份表名
    v_nowkeepdaynum      int,          --生产表保留的天数
    v_bakkeepdaynum      int,          --备份表保留的天数
    v_datefield          varchar2,     --筛选日期字段名
    v_datefieldformat    varchar2,     --筛选日期字段的格式
    v_dopernum           int,          --分批提交的间隔
    v_extcond            varchar2      --用于进行比较的扩展条件
)
as
v_nowkeeptodate   varchar2(300);        --生产表保留时间的最小值
v_bakkeeptodate   varchar2(300);        --备份表保留时间的最小值
v_strcheck        varchar2(2000);
v_strsql          varchar2(8000);
v_tmpbegindate    varchar2(500);
v_tmpnowbegindate varchar2(300);
v_tmpnowenddate   varchar2(300);
v_tmpbakbegindate varchar2(300);
v_tmpbakenddate   varchar2(300);

v_change_dopernum int;
v_change_datefieldformat varchar2(300);
v_count int;
v_datefieldischar int; --日期是否字符型
begin
    v_change_dopernum := v_dopernum;
    if (v_datefieldformat not in (
        'datetime','yyyy.mm.dd','yyyy-mm-dd', 
        'yyyy/mm/dd','yyyymmdd','yyyy.mm.dd hh',
        'yyyy-mm-dd hh','yyyy/mm/dd hh','yyyymmddhh', 
        'yyyy.mm.dd hh:mi:ss','yyyy-mm-dd hh:mi:ss','yyyy/mm/dd hh:mi:ss',
        'yyyymmddhhmiss'))
    then
        dbms_output.put_line('筛选日期字段的格式不在指定的范围');
        return;

    end if;

    select count(1) into v_count from user_tables 
        where table_name = upper(v_nowtablename) and rownum<2;
    if v_count <= 0 then
        dbms_output.put_line(v_nowtablename||'生产表不存在');
        return;
    end if;
	
    select count(1) into v_count from user_tables 
        where table_name = upper(v_baktablename) and rownum<2;
    if v_count <= 0 then
        dbms_output.put_line(v_baktablename||'备份表不存在');
        return;
    end if;
	
    select count(1) into v_count from user_tab_columns 
        where table_name = upper(v_nowtablename)
		and column_name = upper(v_datefield) 
		and rownum<2;
    if v_count <= 0 then
        dbms_output.put_line(v_datefield||'指定的字段不存在');
        return;
    end if;
	
    if v_nowkeepdaynum < 0 then
        dbms_output.put_line('生产表保留天数小于0');
        return;
    end if;
    
    if v_nowkeepdaynum < 0 then
        dbms_output.put_line('备份表保留天数小于0');
        return;
    end if;
    
    if v_change_dopernum <= 0 then
        dbms_output.put_line('提交间隔小于0');
        return;
    end if;
	
    select replace(v_datefieldformat,'hh','hh24') 
        into v_change_datefieldformat from dual;
	v_datefieldischar := 1;
    if (v_datefieldformat = 'datetime') then 
        v_tmpbegindate := 'nvl(min(' || v_datefield || '),sysdate)'; 
        v_tmpnowbegindate := 'v_nowbegindate';  
        v_tmpnowenddate := 'v_nowenddate';      
        v_tmpbakbegindate := 'v_bakbegindate';  
        v_tmpbakenddate := 'v_bakenddate'; 
		v_datefieldischar := 0;     
    else 
        if (v_datefieldformat in( 
		  'yyyy.mm.dd','yyyy/mm/dd','yyyy-mm-dd',   
		  'yyyymmdd')) then 
            v_change_dopernum :=1440;
        elsif (v_datefieldformat in(
		  'yyyy.mm.dd hh','yyyy/mm/dd hh','yyyy-mm-dd hh',
		  'yyyymmddhh')) then
		    v_change_dopernum :=60;
        end if;
        
        v_tmpbegindate := 'to_date(nvl(min(' || v_datefield 
                      || '),to_char(sysdate,''' 
	              || v_change_datefieldformat || ''')),''' 
					  || v_change_datefieldformat || ''')'; 
        v_tmpnowbegindate := 'to_char(v_nowbegindate,''' 
	              || v_change_datefieldformat || ''')';  
        v_tmpnowenddate := 'to_char(v_nowenddate,''' 
	              || v_change_datefieldformat || ''')';      
        v_tmpbakbegindate := 'to_char(v_bakbegindate,''' 
	              || v_change_datefieldformat || ''')';  
        v_tmpbakenddate := 'to_char(v_bakenddate,''' 
                      || v_change_datefieldformat || ''')';     
		  
    end if;
	
    --记录保留日期点
    v_nowkeeptodate := 'trunc(sysdate)-'|| v_nowkeepdaynum;
    v_bakkeeptodate := 'trunc(sysdate)-'|| v_bakkeepdaynum;

    --check format sql
    v_strcheck := ''; 
    if v_datefieldischar = 0 then
        v_strcheck := '
        v_count :=0;
        select count(1) into v_count from '||v_nowtablename||' where rownum<2;
        if v_count = 0 then
            select count(1) into v_count from ' || v_baktablename ||' where rownum<2;
            if v_count = 0 then
                return;
            else 
                select '||v_datefield||' into v_checkdate from '||v_baktablename||' where rownum<2;		       
            end if; 
        else
            select '||v_datefield||' into v_checkdate from '||v_nowtablename||' where rownum<2;
        end if;
	   
        if v_checkdate is null then
            return;
        end if;
        if v_checkdate <> to_date(to_char(v_checkdate,
            ''yyyymmddhh24miss''),
            ''yyyymmddhh24miss'') then
            dbms_output.put_line(''时间格式不符!'');
            return;	    
        end if;';
        
    else
        v_strcheck := '
        v_count :=0;
        select count(1) into v_count from '||v_nowtablename||' where rownum<2;
        if v_count = 0 then
            select count(1) into v_count from ' || v_baktablename ||' where rownum<2;
            if v_count = 0 then
                return;
            else 
                select '||v_datefield||' into v_strcheckdate from '||v_baktablename||' where rownum<2;		       
            end if; 
        else
            select '||v_datefield||' into v_strcheckdate from '||v_nowtablename||' where rownum<2;
        end if;
	   
        if v_strcheckdate is null then
            return;
        end if;
        
        if v_strcheckdate <> to_char(to_date(v_strcheckdate,
            '''||v_change_datefieldformat||'''),
            '''||v_change_datefieldformat||''') then
            dbms_output.put_line(''时间格式不符!'');
            return;	    
        end if;';
    end if;
    
    --begin dynamic sql
    v_strsql :=
    'declare
    v_nowbegindate  date;
    v_nowenddate    date;
    v_bakbegindate  date;
    v_bakenddate    date;
    v_rows int;
    v_checkdate     date;
    v_strcheckdate  varchar2(100);
    v_count int;

    select ' || v_tmpbegindate ||' into v_nowbegindate from ' 
	|| v_nowtablename || ' where 1=1 ' 
        || v_extcond || ';
	v_nowenddate := v_nowbegindate+'|| v_change_dopernum||'/1440; 
    if v_nowenddate>' || v_nowkeeptodate || ' then
	   v_nowenddate:=' || v_nowkeeptodate || ';
    end if;
    
    while (v_nowbegindate < '|| v_nowkeeptodate ||') loop
        insert into '||v_baktablename||' select * from '||v_nowtablename
		    ||'
		    where '||v_datefield||'>='||v_tmpnowbegindate
					 ||'
			and '
					 ||v_datefield||'<='||v_tmpnowenddate||' '
					 ||v_extcond||';
        delete from '||v_nowtablename||' where '
		             ||v_datefield||'>='||v_tmpnowbegindate
					 ||'
			and '
					 ||v_datefield||'<='||v_tmpnowenddate||' '
					 ||v_extcond||';
        commit;			 
        select '||v_tmpbegindate||'
		    into v_nowbegindate from 
		       '||v_nowtablename||' where 1=1 
			   '||v_extcond||';
        v_nowenddate := v_nowbegindate+'|| v_change_dopernum||'/1440;
        if v_nowenddate>' || v_nowkeeptodate || ' then
	       v_nowenddate:=' || v_nowkeeptodate || ';
        end if;
    end loop;
	
    delete from '||v_baktablename||' where '||v_datefield
	             ||'<='||v_tmpbakenddate||' ' 
				 ||v_extcond||'
	    and rownum<=2000;
    v_rows := sql%rowcount;
    
    while (v_rows > 0) loop
        delete from '||v_baktablename||' where '||v_datefield
	             ||'<='||v_tmpbakenddate||' ' 
				 ||v_extcond||'
		    and rownum<=2000;
        commit;
        v_rows := sql%rowcount;
    end loop;
	

    execute immediate v_strsql;
exception 
    when others then
	begin
	    dbms_output.put_line('执行异常!');
	end;
end;
/
