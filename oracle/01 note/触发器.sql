--创建ddl操作信息表
create table ddl_operation_info
(
    operation_type varchar2(20);
    user_name      varchar2(20);
    operation_time timestamp;
);



