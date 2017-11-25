--查看数据库版本
select * from v$version ;

--查看当前所有的pdb
select con_id,dbid,name,open_mode from v$pdbs;

--启动pdb
alter pluggable database pdborcl open;

--停止pdb
alter pluggable database pdborcl close;

--启动所有pdb
alter pluggable database all open;

--停止所有pdb
alter pluggable database all close;
