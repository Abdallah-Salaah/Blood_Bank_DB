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


insert into central_inventory ( sec_id,capacity,available,staff_type,worker_id,shft_id,tot_status)
values (
('bank_A' , 500 , 320 , 'worker', 'WK_1' , 1 , 0.64 ),
('bank_B' , 500 , 362 , 'worker' ,'WK_2' , null , 0.72 ),
('bank_AB', 500 , 289 , 'worker' ,'WK_3' , null , 0.57 ),
('bank_O' , 500 , 416 , 'worker' ,'WK_4' , null , 0.83 ),
('bank_plasma', 750 , 520 , 'worker' ,'WK_5' , null , 0.69 ),
('lab', 300 , 63 , 'doctor' ,'DR_1' , 2 , 0.72 )
);





insert into hospital ( unit_id , process_date , city , st_no , tot_need_quantity , need_type )
values ( 
( 1 , '2019-07-23' , ' alhamoul ' , 15 , 370 , ' A70_B100_O85_AB70_plasma45 ' ) ,
( 2 , '2020-1-15' , ' dsouq ', 8 , 480 ,  ' A85_B115_O110_AB105_plasma65 ' ) 
);





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