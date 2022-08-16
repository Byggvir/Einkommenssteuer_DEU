use Steuern;

create or replace view Tarifkurve as 
select * 
from (

    select
        T1.Jahr as Jahr
        , T1.Tarifzone as Tarifzone
        , T1.UEckwert as Eckwert
        , T1.USatz as Satz
    from Tarifzonen as T1
    union
    select
        T1.Jahr as Jahr
        , T1.Tarifzone as Tarifzone
        , T1.OEckwert as Eckwert
        , T1.OSatz as Satz
    from Tarifzonen as T1
    ) as TK
    order by Jahr, Tarifzone , Eckwert;
;

select * from Tarifkurve where Jahr > 2021; 
