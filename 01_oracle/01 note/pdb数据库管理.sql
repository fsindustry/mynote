--�鿴���ݿ�汾
select * from v$version ;

--�鿴��ǰ���е�pdb
select con_id,dbid,name,open_mode from v$pdbs;

--����pdb
alter pluggable database pdborcl open;

--ֹͣpdb
alter pluggable database pdborcl close;

--��������pdb
alter pluggable database all open;

--ֹͣ����pdb
alter pluggable database all close;
