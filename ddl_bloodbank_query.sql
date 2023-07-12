-- physical version 0.1  (11/27/21)
--v 0.2 (25/12/21)

--intialization
CREATE DATABASE BLOOD_BANK ;
GO
USE BLOOD_BANK;
GO
--drop BLOOD_BANK --ACTIVATE IF NEEDED!

--starting with main entities 

create table  central_inventory
(

-- section  attributes starts
--quantity in each sec. will be func in ( check (date) and supply quantity and blood bag type)
sec_id      varchar(10) primary key , --lap 'l' and storages 'bank1_plasma,bank2_blood.., bank4_plasma_o' ,other
capacity    int ,--if lap can be null
available   int,
staff_type  varchar(20) not null,
--end section  composite attributes

shft_id    int  ,
tot_status decimal ,

constraint lap_capacity_null 
check (
(capacity = null and sec_id like 'l%') or (capacity != null and sec_id not like 'l%')
),

constraint valid_secid check (sec_id= 'b%' or sec_id = 'l%')

);

create table  hospital
(
unit_id       int primary key,
process_date  date unique not null, -- make it default ON UPDATE for real use <3
client_id   int unique not null ,

--hospital_address start
 city varchar(30) not null ,st_no int ,
 --hospital_address  composite end
 
 --need atrributes  start
 need_quantity int ,need_type varchar(10), --blood/plasma other 
 --end need composite

  --make it better later  need can be(need <= available) not only (need==available)
  constraint hospital_fk foreign key  (need_type) references central_inventory(sec_id), 
  constraint valid_storage_sec check(  need_type != 'l%'),

  --constraint  is_availabel check (need_quantity <= central_inventory(available))
  --cant check with colums in other table :( need matrialized view,,
  --FOR NOW WE CANT RESTRICT NEEDED QUATNTITY TO NO EXCEED AVAILABLE QUANTITY IN BANK
);

create table  supply_line --!!!NEED better primary key!!!
(
--trigger to update with each req_donor update (maybe usin cascadin ref integ constraint)
tot_unchkd_quantity int,
shft_id           int unique,
destination_sec     varchar(10) not null ,

constraint pk_supply primary key (tot_unchkd_quantity), 
constraint supply_fk foreign key  (destination_sec) references central_inventory(sec_id)
);



create table  client
(

ssn        int primary key,
blood_type varchar(3) not null,
cname      varchar(50),
age        int not null,

constraint age_Chk check ( age >= 18)
);



--############################################################################################
-- weak/associative,sub entities section

create table  Donor
(

--donor_code varchar(10) primary key , -- 'd'+ssn

ssn           int  not null foreign key references client(ssn),

last_donation date, --use getdate() if u want to get crnt date auto

 
 constraint not_donated_recently 
 check
 (
 DATEDIFF(month, last_donation , cast(getdate()as date )) >= 3
 )
 --previous constraint is for not accepting people donating before 3 month have past
);

create table  Recepient
(

--recpnt_code varchar(10) primary key, --'r'+ssn

ssn      int not null foreign key references client(ssn),
disorder varchar(50) not null ,

--blood_type compostite  start
blood_type varchar(3) not null,  bld_particles_needed varchar(10) ,
bags_need  int 
--blood_type composite end


);
 
create table  staff
(

worker_id     int primary key ,

assigned_shft int not null  foreign key references supply_line(shft_id) , --simple supply line 2 stages

assigned_sec  varchar(10) not null foreign key references central_inventory(sec_id)

);

create table  blood_bags
(

bld_bag_date    date not null ,  
client_id		int  not null ,  
crnt_stage      int not null ,
bag_no          int ,
constraint fk_stf_sply foreign key (crnt_stage) references supply_line(stage_id),
constraint fk_staff1   foreign key (bld_bag_date) references hospital(process_date),
constraint fk_staff2   foreign key (client_id) references hospital(client_id),

constraint pk_BLDbags  primary key (bld_bag_date,client_id)

); 
 
create table  request_log
(
--donor/ recep columns will remain null if request is for opposite client

destination_unit int  foreign key references  hospital(unit_id),
ssn              int  foreign key references client(ssn),
req_date         date foreign key references hospital(process_date),

--request_status compostie start
donor_or_recp binary not null ,
is_completed  binary not null , 
cname         varchar(50) not null, 
age			  int not null,
blood_type	  varchar(3) not null,
wieght        decimal not null,
bags_quantity int null,
blood_particles varchar(20) null,
--request_status compostie end



constraint req_pk primary key (destination_unit,ssn,req_date),
constraint age_Chk2 check ( age >= 18)
);







--########################################################################################
--editing structure  section 
alter table  blood_bags add blood_type varchar(3) 

 alter table hospital add  constraint unique_hos unique (process_date,client_id)

 alter table supply_line drop column stage_id

 alter table supply_line add  tot_unchkd_quantity int not null unique 
 go
 alter table supply_line add constraint pk_supply primary key (tot_unchkd_quantity) 

 alter table blood_bags add bag_no int not null --make it auto  woth each rew_donor
 alter table blood_bags add constraint fk_supply foreign key (bag_no) references supply_line(tot_unchkd_quantity)
 alter table blood_bags drop constraint pk_BLDbags 
 alter table blood_bags add constraint PK_BldBag primary key (client_id,bag_no)
 alter table supply_line add constraint unique_shft unique (shft_id)
  alter table staff add constraint FK_supply2 foreign key (assigned_shft) references supply_line(shft_id)

 -- alter table 
 -- drop table 
  --delete table
--more queries
--1)  create index on indx_table_name (choosed freq. used tables)
--2) drop table_name.index_name  (deletes index makes updating the table faster --no need to update index )
--3)w3school for more commands ddl/mdl :--https://www.w3schools.com/sql/sql_create_index.asp








