CREATE PROCEDURE CHANGE_SAL(emp_name VARCHAR2 , new_sal Number) IS
BEGIN
  UPDATE emp SET sal=new_sal
  WHERE ename=emp_name;
END CHANGE_SAL;

CREATE OR REPLACE FUNCTION CAL_ANNUAL_SAL(empname VARCHAR2) 
--声明返回值类型
RETURN NUMBER IS
   --定义变量存储年薪值
   annual_sal NUMBER(7,2);  
BEGIN --执行部分
  SELECT (sal+NVL(comm,0))*12 INTO annual_sal 
  FROM emp
  WHERE ename=empname;
  RETURN annual_sal;
END CAL_ANNUAL_SAL;
/

--包规范
CREATE PACKAGE EMP_TOOL_PACKAGE IS
   --函数和过程的声明
   PROCEDURE CHANGE_SAL(emp_name VARCHAR2 , new_sal Number);
   FUNCTION CAL_ANNUAL_SAL(empname VARCHAR2) RETURN NUMBER;
END EMP_TOOL_PACKAGE;
/


--包体
CREATE PACKAGE BODY EMP_TOOL_PACKAGE IS

   --函数和过程的实现
   PROCEDURE CHANGE_SAL(emp_name VARCHAR2 , new_sal Number) IS
   BEGIN
      UPDATE emp SET sal=new_sal
      WHERE ename=emp_name;
   END CHANGE_SAL;
   
   FUNCTION CAL_ANNUAL_SAL(empname VARCHAR2) 
   --声明返回值类型
   RETURN NUMBER IS
      --定义变量存储年薪值
      annual_sal NUMBER(7,2);  
   BEGIN --执行部分
      SELECT (sal+NVL(comm,0))*12 INTO annual_sal 
      FROM emp
      WHERE ename=empname;
      RETURN annual_sal;
   END CAL_ANNUAL_SAL;
END EMP_TOOL_PACKAGE;
/



DECLARE

  --税率
  c_tax_rate CONSTANT NUMBER(3,2):=0.03;
  --员工姓名
  v_ename emp.ename%TYPE;
  --工资
  v_sal emp.sal%TYPE;
  --税
  v_sal_tax NUMBER(7,2);
  
BEGIN
  --执行
  SELECT ename,sal INTO v_ename,v_sal
  FROM emp
  WHERE empno=&no;
  
  --计算所得税
  v_sal_tax:=v_sal*c_tax_rate;

  --输出
  DBMS_OUTPUT.PUT_LINE('员工姓名：'||v_ename||' | 员工工资：'||v_sal||' | 个税：'||v_sal_tax);
  
END;
/


--定义记录
DECLARE 
   
   --定义一个记录类型，存放emp表的ename,sal,job字段
   TYPE emp_record_type IS RECORD(empname emp.ename%TYPE,sal emp.sal%TYPE,job emp.job%TYPE);
   --定义一个记录类型的变量
   emp_record emp_record_type;
   
BEGIN
   --查询emp表中信息，放入记录变量中
   SELECT ename,sal,job INTO emp_record
   FROM emp
   WHERE empno=7788;
   
   --打印记录
   DBMS_OUTPUT.PUT_LINE('员工姓名：'||emp_record.empname || '工资：' || emp_record.sal || '工作:' || emp_record.job);
END;
/


--定义PL/SQL表
DECLARE
   
   --定义一个PL/SQL表类型，存放emp表的ename字段
   TYPE emp_table_type IS TABLE OF emp.ename%TYPE INDEX BY BINARY_INTEGER;--此处表示下标按整数排序,可以为负数
   --定义一个PL/SQL表变量
   emp_table emp_table_type;

BEGIN
  
   SELECT ename INTO emp_table(0) 
   FROM emp
   WHERE empno=7788;

   DBMS_OUTPUT.PUT_LINE('员工姓名：' || emp_table(0));
END;
/



--定义游标变量，取出查询结果；
DECLARE

   --定义游标类型
   TYPE emp_ref_cr_type IS REF CURSOR;
   --定义游标变量
   emp_ref_cr emp_ref_cr_type;
   
   --ename
   v_ename emp.ename%TYPE;
   --sal
   v_sal emp.sal%TYPE;
 
BEGIN
   
   --使用游标
   OPEN emp_ref_cr FOR
   SELECT ename,sal
   FROM emp
   WHERE deptno=&no;
   
   --循环取出数据
   LOOP
      
      FETCH emp_ref_cr INTO v_ename,v_sal;
      --判断游标是否为空
      EXIT WHEN emp_ref_cr%NOTFOUND;
      
      --输出
      DBMS_OUTPUT.PUT_LINE('员工姓名：' || v_ename || '薪水' || v_sal );
   END LOOP;
   
   --关闭游标
   CLOSE emp_ref_cr;
   
END;
/
