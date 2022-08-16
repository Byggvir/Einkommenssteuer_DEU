use Steuern;

drop table Eckwerte;

create table if not exists Eckwerte
(
    Jahr int(11) primary key
    , UEckwert0 double
    , UEckwert1 double
    , UEckwert2 double
    , UEckwert3 double
    , UEckwert4 double
    , Satz0 double
    , Satz1 double
    , Satz2 double
    , Satz3 double
    , Satz4 double
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;


LOAD DATA LOCAL 
INFILE '/tmp/Steuereckwerte.csv'      
INTO TABLE `Eckwerte`
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;

drop table if exists Tarifzonen;

create table if not exists Tarifzonen 
 ( Jahr int(11) 
 , Tarifzone int(11)
 , UEckwert double
 , OEckwert double
 , SteuerBeiUE double
 , p double
 , USatz double
 , OSatz double
 , Progressiv boolean default FALSE
 , primary key ( Jahr, Tarifzone)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;


insert into Tarifzonen 
select 
    Jahr
    , 0
    , UEckwert0
    , UEckwert1
    , 0
    , 0
    , Satz0
    , Satz0
    , FALSE
from Eckwerte
union
select 
    Jahr
    , 1
    , UEckwert1
    , UEckwert2
    , 0
    , 0
    , Satz1
    , Satz2
    , TRUE
from Eckwerte
union
select 
    Jahr
    , 2
    , UEckwert2
    , UEckwert3
    , 0
    , 0
    , Satz2
    , Satz3
    , TRUE
from Eckwerte
union
select 
    Jahr
    , 3
    , UEckwert3
    , UEckwert4
    , 0
    , 0
    , Satz3
    , Satz3
    , FALSE
    from Eckwerte
union
select 
    Jahr
    , 4
    , UEckwert4
    , 1E6
    , 0
    , 0
    , Satz4
    , Satz4
    , FALSE
    from Eckwerte
;

update Tarifzonen 
set p = (OSatz - USatz) / ( OEckwert - UEckwert) / 2 
where Progressiv;

update Tarifzonen as T1 
join Tarifzonen as T2 
on T1.Jahr = T2.Jahr and T2.Tarifzone = T1.Tarifzone - 1 
set T1.SteuerBeiUE = round(Steuerbetrag(T2.OEckwert, T2.UEckwert, T2.SteuerBeiUE,T2.p, T2.USatz),2)
where T1.Tarifzone = 2;

update Tarifzonen as T1 
join Tarifzonen as T2 
on T1.Jahr = T2.Jahr and T2.Tarifzone = T1.Tarifzone - 1 
set T1.SteuerBeiUE = round(Steuerbetrag(T2.OEckwert, T2.UEckwert, T2.SteuerBeiUE,T2.p, T2.USatz),2)
where T1.Tarifzone = 3;

update Tarifzonen as T1 
join Tarifzonen as T2 
on T1.Jahr = T2.Jahr and T2.Tarifzone = T1.Tarifzone - 1 
set T1.SteuerBeiUE = round(Steuerbetrag(T2.OEckwert, T2.UEckwert, T2.SteuerBeiUE,T2.p, T2.USatz),2)
where T1.Tarifzone = 4;

update Tarifzonen 
set SteuerBeiUE = round(SteuerBeiUE) 
where ( Jahr <2015 and Tarifzone = 2 )
or ( Jahr <2016 and Tarifzone = 3 )
or ( Jahr <2017 and Tarifzone = 4 )
;
