--创建一个包
CREATE OR REPLACE PACKAGE SEPARATE_PAGE_PKG IS
  
   --定义游标
   TYPE rc_data IS REF CURSOR;

   --定义存储过程
   PROCEDURE QUERY_BY_PAGE(table_name IN VARCHAR2,--表名
      page_size IN NUMBER,--每页记录数
      page_now IN NUMBER,--当前页数
      total_size OUT NUMBER,--总记录数
      total_page OUT NUMBER,--总页数
      o_rc_data OUT SEPARATE_PAGE_PKG.rc_data
     );

END SEPARATE_PAGE_PKG;


--创建包体
CREATE OR REPLACE PACKAGE BODY SEPARATE_PAGE_PKG IS

   --定义存储过程
   PROCEDURE QUERY_BY_PAGE(table_name IN VARCHAR2,--表名
      page_size IN NUMBER,--每页记录数
      page_now IN NUMBER,--当前页数
      total_size OUT NUMBER,--总记录数
      total_page OUT NUMBER,--总页数
      o_rc_data OUT SEPARATE_PAGE_PKG.rc_data)
   IS
      
      --定义字符型变量，存放SQL字符串
      v_sql VARCHAR2(1000);
      --定义记录查询的开始值和结束值
      v_start_index NUMBER:=(page_now-1)*page_size +1;
      v_end_index NUMBER:=page_now*page_size;
      
   BEGIN
      --创建动态SQL语句
      v_sql:='SELECT * FROM ( SELECT temp.*, ROWNUM rn FROM ( SELECT * FROM '|| table_name
            ||') temp WHERE rn<'|| v_end_index||') WHERE ROWNUM>='||v_start_index;
            
      --把游标和SQL关联
      OPEN o_rc_data FOR v_sql;
      
      --计算总记录数和总页数
      v_sql:='SELECT COUNT(*) FROM '||table_name;
      
      --执行SQL语句,获取总记录数
      EXECUTE IMMEDIATE v_sql INTO total_size;
      
      IF MOD(total_size,page_size)=0
      THEN 
         total_page:=total_size/page_size;
      ELSE
         total_page:=total_size/page_size+1;
      END IF;
   
   END QUERY_BY_PAGE;
END SEPARATE_PAGE_PKG;
   
