CREATE PROCEDURE CHANGE_SAL(emp_name VARCHAR2 , new_sal Number) IS
BEGIN
  UPDATE emp SET sal=new_sal
  WHERE ename=emp_name;
END CHANGE_SAL;

CREATE OR REPLACE FUNCTION CAL_ANNUAL_SAL(empname VARCHAR2) 
--��������ֵ����
RETURN NUMBER IS
   --��������洢��нֵ
   annual_sal NUMBER(7,2);  
BEGIN --ִ�в���
  SELECT (sal+NVL(comm,0))*12 INTO annual_sal 
  FROM emp
  WHERE ename=empname;
  RETURN annual_sal;
END CAL_ANNUAL_SAL;
/

--���淶
CREATE PACKAGE EMP_TOOL_PACKAGE IS
   --�����͹��̵�����
   PROCEDURE CHANGE_SAL(emp_name VARCHAR2 , new_sal Number);
   FUNCTION CAL_ANNUAL_SAL(empname VARCHAR2) RETURN NUMBER;
END EMP_TOOL_PACKAGE;
/


--����
CREATE PACKAGE BODY EMP_TOOL_PACKAGE IS

   --�����͹��̵�ʵ��
   PROCEDURE CHANGE_SAL(emp_name VARCHAR2 , new_sal Number) IS
   BEGIN
      UPDATE emp SET sal=new_sal
      WHERE ename=emp_name;
   END CHANGE_SAL;
   
   FUNCTION CAL_ANNUAL_SAL(empname VARCHAR2) 
   --��������ֵ����
   RETURN NUMBER IS
      --��������洢��нֵ
      annual_sal NUMBER(7,2);  
   BEGIN --ִ�в���
      SELECT (sal+NVL(comm,0))*12 INTO annual_sal 
      FROM emp
      WHERE ename=empname;
      RETURN annual_sal;
   END CAL_ANNUAL_SAL;
END EMP_TOOL_PACKAGE;
/



DECLARE

  --˰��
  c_tax_rate CONSTANT NUMBER(3,2):=0.03;
  --Ա������
  v_ename emp.ename%TYPE;
  --����
  v_sal emp.sal%TYPE;
  --˰
  v_sal_tax NUMBER(7,2);
  
BEGIN
  --ִ��
  SELECT ename,sal INTO v_ename,v_sal
  FROM emp
  WHERE empno=&no;
  
  --��������˰
  v_sal_tax:=v_sal*c_tax_rate;

  --���
  DBMS_OUTPUT.PUT_LINE('Ա��������'||v_ename||' | Ա�����ʣ�'||v_sal||' | ��˰��'||v_sal_tax);
  
END;
/


--�����¼
DECLARE 
   
   --����һ����¼���ͣ����emp���ename,sal,job�ֶ�
   TYPE emp_record_type IS RECORD(empname emp.ename%TYPE,sal emp.sal%TYPE,job emp.job%TYPE);
   --����һ����¼���͵ı���
   emp_record emp_record_type;
   
BEGIN
   --��ѯemp������Ϣ�������¼������
   SELECT ename,sal,job INTO emp_record
   FROM emp
   WHERE empno=7788;
   
   --��ӡ��¼
   DBMS_OUTPUT.PUT_LINE('Ա��������'||emp_record.empname || '���ʣ�' || emp_record.sal || '����:' || emp_record.job);
END;
/


--����PL/SQL��
DECLARE
   
   --����һ��PL/SQL�����ͣ����emp���ename�ֶ�
   TYPE emp_table_type IS TABLE OF emp.ename%TYPE INDEX BY BINARY_INTEGER;--�˴���ʾ�±갴��������,����Ϊ����
   --����һ��PL/SQL�����
   emp_table emp_table_type;

BEGIN
  
   SELECT ename INTO emp_table(0) 
   FROM emp
   WHERE empno=7788;

   DBMS_OUTPUT.PUT_LINE('Ա��������' || emp_table(0));
END;
/



--�����α������ȡ����ѯ�����
DECLARE

   --�����α�����
   TYPE emp_ref_cr_type IS REF CURSOR;
   --�����α����
   emp_ref_cr emp_ref_cr_type;
   
   --ename
   v_ename emp.ename%TYPE;
   --sal
   v_sal emp.sal%TYPE;
 
BEGIN
   
   --ʹ���α�
   OPEN emp_ref_cr FOR
   SELECT ename,sal
   FROM emp
   WHERE deptno=&no;
   
   --ѭ��ȡ������
   LOOP
      
      FETCH emp_ref_cr INTO v_ename,v_sal;
      --�ж��α��Ƿ�Ϊ��
      EXIT WHEN emp_ref_cr%NOTFOUND;
      
      --���
      DBMS_OUTPUT.PUT_LINE('Ա��������' || v_ename || 'нˮ' || v_sal );
   END LOOP;
   
   --�ر��α�
   CLOSE emp_ref_cr;
   
END;
/
