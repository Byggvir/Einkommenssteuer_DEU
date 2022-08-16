create database if not exists Steuern;

use Steuern;

drop table MathParmeter;

create table if not exists MathParmeter
(
    Jahr int(11) primary key
    , E0 double
    , E1 double
    , E2 double
    , E3 double
    , E4 double
    , S0 double
    , S1 double
    , S2 double
    , S3 double
    , S4 double
    , p0 double
    , p1 double
    , p2 double
    , p3 double
    , p4 double
    , sg0 double
    , sg1 double
    , sg2 double
    , sg3 double
    , sg4 double
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

LOAD DATA LOCAL 
INFILE '/tmp/SteuerParameter.csv'      
INTO TABLE `MathParmeter`
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;

drop table Tarifzonen ;

create table if not exists Tarifzonen 
 ( Jahr int(11) 
 , Tarifzone int(11)
 , UEckwert double
 , OEckwert double
 , SteuerBeiUE double
 , p double
 , Satz double
 , primary key ( Jahr, Tarifzone)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

insert into Tarifzonen 
select 
    Jahr
    , 0
    , E0
    , E1
    , S0
    , p0
    , sg0
    from MathParmeter
union
select 
    Jahr
    , 1
    , E1
    , E2
    , S1
    , p1
    , sg1
    from MathParmeter
union
select 
    Jahr
    , 2
    , E2
    , E3
    , S2
    , p2
    , sg2
    from MathParmeter
union
select 
    Jahr
    , 3
    , E3
    , E4
    , S3
    , p3
    , sg3
    from MathParmeter
union
select 
    Jahr
    , 4
    , E4
    , 1e15
    , S4
    , p4
    , sg4
    from MathParmeter
;

drop table if exists Einkommen;

create table Einkommen (
    zvE double default 0 primary key
)  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

LOAD DATA LOCAL 
INFILE '/tmp/Einkommen.csv'      
INTO TABLE `Einkommen`
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;

delimiter //

create or replace 
function SteuerBetrag ( 
    zvE double
    , E double
    , S double
    , p double
    , Satz double
    ) returns double
begin
    return ( ( p * (zvE - E) + Satz) * ( zvE - E) + S);
end 
//
