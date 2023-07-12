
-- physical version 0.1  (11/27/21)
--v 0.2 (25/12/21)
--v 0.3 (30/12/21)
--intialization

CREATE DATABASE BLOOD_BANK ;
GO
USE BLOOD_BANK;
GO

                                           -- main entities --

create table  central_inventory
(
--quantity in each sec. will be func in ( check (date) and supply quantity and blood bag type)

--sec
sec_id      varchar(255) primary key , --lap 'l' and storages 'bank1_plasma,bank2_blood.., bank4_plasma_o' ,other
capacity    int,
available   int, 
staff_type  varchar(255) not null,
--end composite 
worker_id  varchar(255) unique,
shft_id    int unique ,
tot_status decimal,

constraint valid_secid check (sec_id='b%' or sec_id = 'l%'),

/*constraint lap_capacity_null check (
(capacity = null and sec_id like 'l%') or (capacity != null and sec_id like 'b%')
), */
);

create table  hospital
(
unit_id       int primary key,
process_date  date not null  unique default getdate(), 

--hospital_address 
 city varchar(255) not null ,st_no varchar(255) ,
--composite end

--need  
 tot_need_quantity int ,need_type varchar(255), --blood/plasma other 
--end  composite

  --make it better later  need can be(need <= available) not only (need==available)
  constraint Fk_ndtypRefInvntrySecID  foreign key  (need_type) references central_inventory(sec_id), 
  constraint is_storage_chk           check( need_type != 'l%'),


  --constraint  is_availabel check (need_quantity <= central_inventory(available))
  --FOR NOW WE CANT RESTRICT NEEDED QUATNTITY TO NO EXCEED AVAILABLE QUANTITY IN BANK
);

create table  supply_line
(
--trigger to update with each req_donor update (maybe usin cascadin ref integ constraint)
tot_unchkd_quantity int   identity ,--could use sum or count instead
shft_id             int,
destination_sec     varchar(255) not null ,
lap_tst_rslt        binary not null,-- if zero not accepted

constraint Pk_supply                   primary key (tot_unchkd_quantity), 
constraint Fk_DestinSecRefInvntrySecId foreign key (destination_sec) references central_inventory(sec_id),

/*  Fk_TotQntyRefReqIsDnr       foreign key (tot_unchkd_quantity) references request_log(is_donor)
on update cascade on delete cascade */
-- prev constraint to keep tot bags num valid (force integrity)
);





create table  client
(
ssn        varchar(255),
blood_type varchar(255) not null,
cname      varchar(255),
age        int not null,
phone_num  varchar(255) null,

constraint Pk_client primary key (ssn),
constraint Clntage_Chk check (age>=18)
);



--############################################################################################
                             -- weak/associative/sub entities --
create table  Donor
(

ssn           varchar(255)  not null primary key ,
last_donation date, 

 constraint Fk_SsnRefClntSsn foreign key (ssn) references client(ssn) 
 on delete cascade on update cascade,

 constraint is_donated_recently 
 check
 (
 DATEDIFF(month, last_donation , cast(getdate()as date )) >= 3
 )
 --previous constraint is for not accepting people donating before 3 past since last donation
);

create table  Recepient
(
ssn      varchar(255) primary key,

--blood_partciles 
bld_particles_needed varchar(255) ,
bags_need  int 
--composite end

constraint Fk_SsnRefClintSsn foreign key (ssn) references client(ssn)
on delete cascade on update cascade,
);
 
create table  staff_status
(
worker_id     varchar(255),
assigned_bag  int,
shft_id		  int,

constraint Pk_Staff                     primary key (worker_id,assigned_bag),
constraint Fk_AsigndSecRefInvntrySecId  foreign key (worker_id) references central_inventory(worker_id),
constraint FK_ShftIdRefInvntryChftId    foreign key (shft_id) references central_inventory (shft_id), 
constraint Fk_AsigndShftRefSplyShftId   foreign key (assigned_bag) references supply_line(tot_unchkd_quantity)
on update cascade

);

create table  blood_bag
(

bld_bag_date    date not null ,  
client_id		varchar(255) not null ,
blood_type      varchar(255),
constraint Fk_BLdBgDatRefHospPrcsDat   foreign key (bld_bag_date) references hospital(process_date),
constraint Fk_ClntIdRefHospCLntId      foreign key (client_id)    references client(ssn),
constraint Pk_BLDbags                  primary key (bld_bag_date,client_id)
); 
 
create table  request_log
(
--donor/ recep columns will remain null if request is for opposite client
destination_unit int         not null ,
ssn              varchar(255)not null ,
req_date         date        not null ,

--request_status 
is_donor int  unique ,
is_recp  int ,
is_completed  binary not null , 
cname         varchar(255) not null, 
age			  int not null,
blood_type	  varchar(255) not null,
wieght        decimal,
bags_quantity int default 1,
blood_particles varchar(255) default 'not specified' ,
-- compostie end

constraint Fk_DestUntRefHospUntId foreign key (destination_unit) references hospital(unit_id),
constraint Fk_SsnRefClntIdSsn     foreign key (ssn)              references client(ssn),
constraint Fk_RqstDtRefHopPrcsDt  foreign key (req_date)         references hospital(process_date),
constraint Pk_reqst               primary key (destination_unit,ssn,req_date),
constraint Chk_RqstAge            check (age >= 18),
constraint Chk_DnrXorRecp         check ((is_donor != null and is_recp =  null) or (is_donor = null and is_recp != null))
--previous condition to *prevent* making overlaped request e.g.(donor and recp at same time)
);


--insert sec
/*  INSERT INTO table_name (column1, column2, column3, ...)
VALUES (value1, value2, value3, ...);  */


--update sec 
/* UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE condition; */


--delete sec (danger)
/* DELETE FROM table_name WHERE condition; */




--ordering/filtiring sec



--join sec



-- insert central inventory

insert into central_inventory ( sec_id,capacity,available,staff_type,worker_id,shft_id,tot_status)
values (
('bank_A' , 500 , 320 , 'worker', 'WK_1' , 1 , 0.64 ),
('bank_B' , 500 , 362 , 'worker' ,'WK_2' , null , 0.72 ),
('bank_AB', 500 , 289 , 'worker' ,'WK_3' , null , 0.57 ),
('bank_O' , 500 , 416 , 'worker' ,'WK_4' , null , 0.83 ),
('bank_plasma', 750 , 520 , 'worker' ,'WK_5' , null , 0.69 ),
('lab', 300 , 63 , 'doctor' ,'DR_1' , 2 , 0.72 )
);




-- insert hospital
insert into hospital ( unit_id , process_date , city , st_no , tot_need_quantity , need_type )
values (
( 1 , '2019-07-23' , ' alhamoul ' , 15 , 370 , ' A70_B100_O85_AB70_plasma45 ' ) ,
( 2 , '2020-1-15' , ' dsouq ', 8 , 480 ,  ' A85_B115_O110_AB105_plasma65 ' )
);




-- insert staff_status
insert into staff_status ( worker_id , assigned_bag , shft_id )
values (
( 'WK_1' , 2001, 2 ),
( 'WK_2' , 2002 , 2 ),
( 'WK_1' , 2003, 1 ),
( 'WK_1' , 2004 , 2 ),
( 'WK_1' , 2005, 1 ),
( 'WK_2' , 2006 , 1 ),
( 'WK_1' , 2007, 1 ),
( 'WK_2' , 2008 , 1 ),
( 'WK_2' , 2009, 2 ),
( 'WK_2' , 2010 , 1 ),
( 'WK_1' , 2011, 2 ),
( 'WK_2' , 2012 , 2 ),
( 'WK_1' , 2013, 1 ),
( 'WK_2' , 2014 , 1 ),
( 'WK_1' , 2015, 1 ),
( 'WK_1' , 2016 , 2 )
)


--INSERT CLIENTS

insert into client (ssn,blood_type,cname,age,phone_num)
values     ('2018010151327410','A-','Ali Fahmy',38,'147258'),
           ('2017010050063750','A+','Ahmed Maher',41,'369753'),
       ('2090306080202050','A+','Ramdan Ahmed',35,'658741'),
       ('2010300937198320','AB+','Maha Ahmed',25,'748596'),
       ('3010130253002810','AB-','Maher Abdou',42,'152463'),
       ('3011010009516780','B-','Yousif ElShahat',42,'159753'),
       ('3017010020191230','B+','Shrief Mohamed',34,'154236'),
       ('3005010141165400','B+','Samier Mohamed',38,'984278'),
       ('3017010606693330','O+','Ahmed ElSaied',24,'754286'),
       ('3180102204847450','O+','Ahmed Rady',20,'102834'), --10
       ('2008010097989820','A+','Amr Nabiel',32,'871625'),
       ('2019010083373870','O-','Walied Mohamed',42,'298346'),
       ('2017010103003740','B-','Haytham Amr ',32,'182730'),
       ('2018101092100030','O-','Magdy Mohamed',30,'951623'),
       ('2002010697691220','B+','Karim Abdallah',34,'102938'),
       ('2019010116343710','A+','Faried Abdelmoiem',23,'109876'),
       ('3021010662929121','O-','Ebrahim Gad',44,'195371'),
       ('3018010925968671','AB+','Ahmed Ramy',32,'098375'),
       ('3019010202538141','AB-','Mohamed Eleps',23,'912435'),
       ('3008010159856451','B+','samy Elsaied',34,'092837');
  

                            --INSERT DONER
INSERT INTO Donor (ssn) SELECT ssn From client 
where ssn like '%0';

                            --INSERT Recepient
INSERT INTO Recepient(ssn) SELECT ssn From client 
where ssn like '%1';


insert into request_log ( destination_unit , ssn , req_date , is_donor , is_recp , is_completed , cname , age , blood_type , wieght , bags_quantity , blood_particles )
values (





--############################################################################################
                             --editing structure  section --
use master
 drop DATABASE BLOOD_Bank
 alter table  blood_bags add blood_type varchar(3) 
 alter table hospital add  constraint unique_hos unique (process_date,client_id)
 alter table supply_line drop column stage_id
 alter table supply_line add  tot_unchkd_quantity int not null unique 
 alter table supply_line add constraint pk_supply primary key (tot_unchkd_quantity) 
 alter table blood_bags add bag_no int not null --make it auto  woth each rew_donor
 alter table blood_bags add constraint fk_supply foreign key (bag_no) references supply_line(tot_unchkd_quantity)
 alter table blood_bags drop constraint pk_BLDbags 
 alter table blood_bags add constraint PK_BldBag primary key (client_id,bag_no)
 alter table supply_line add constraint unique_shft unique (shft_id)
 alter table staff add constraint FK_supply2 foreign key (assigned_shft) references supply_line(shft_id)
ALTER table client alter column ssn varchar(1500)


 -- alter(add\drop..)\create\drop
--more queries:
--1)  create index on indx_table_name (freq_usedtable1,freq_usedtabl2)
--2) drop table_name.index_name  --deletes index makes updating the table faster --no need to update index
--3)w3school for more commands ddl/mdl : https://www.w3schools.com/sql/sql_create_index.asp

