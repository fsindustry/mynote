--����һ����
CREATE OR REPLACE PACKAGE SEPARATE_PAGE_PKG IS
  
   --�����α�
   TYPE rc_data IS REF CURSOR;

   --����洢����
   PROCEDURE QUERY_BY_PAGE(table_name IN VARCHAR2,--����
      page_size IN NUMBER,--ÿҳ��¼��
      page_now IN NUMBER,--��ǰҳ��
      total_size OUT NUMBER,--�ܼ�¼��
      total_page OUT NUMBER,--��ҳ��
      o_rc_data OUT SEPARATE_PAGE_PKG.rc_data
     );

END SEPARATE_PAGE_PKG;


--��������
CREATE OR REPLACE PACKAGE BODY SEPARATE_PAGE_PKG IS

   --����洢����
   PROCEDURE QUERY_BY_PAGE(table_name IN VARCHAR2,--����
      page_size IN NUMBER,--ÿҳ��¼��
      page_now IN NUMBER,--��ǰҳ��
      total_size OUT NUMBER,--�ܼ�¼��
      total_page OUT NUMBER,--��ҳ��
      o_rc_data OUT SEPARATE_PAGE_PKG.rc_data)
   IS
      
      --�����ַ��ͱ��������SQL�ַ���
      v_sql VARCHAR2(1000);
      --�����¼��ѯ�Ŀ�ʼֵ�ͽ���ֵ
      v_start_index NUMBER:=(page_now-1)*page_size +1;
      v_end_index NUMBER:=page_now*page_size;
      
   BEGIN
      --������̬SQL���
      v_sql:='SELECT * FROM ( SELECT temp.*, ROWNUM rn FROM ( SELECT * FROM '|| table_name
            ||') temp WHERE rn<'|| v_end_index||') WHERE ROWNUM>='||v_start_index;
            
      --���α��SQL����
      OPEN o_rc_data FOR v_sql;
      
      --�����ܼ�¼������ҳ��
      v_sql:='SELECT COUNT(*) FROM '||table_name;
      
      --ִ��SQL���,��ȡ�ܼ�¼��
      EXECUTE IMMEDIATE v_sql INTO total_size;
      
      IF MOD(total_size,page_size)=0
      THEN 
         total_page:=total_size/page_size;
      ELSE
         total_page:=total_size/page_size+1;
      END IF;
   
   END QUERY_BY_PAGE;
END SEPARATE_PAGE_PKG;
   
