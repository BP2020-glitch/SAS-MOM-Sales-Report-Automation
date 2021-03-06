/***MOM Sales Report***/
%let Sales = %str(/folders/myfolders/sasdata/MOMSalesReportFolder);
libname BI "&Sales";

title;
proc sql;
select count(distinct cust_id)
from bi.sas_bi;
quit;

proc freq data=bi.sas_bi;
tables 	year_old ;
run;

data bi.age_range(drop=cust_id date_of_birth year_old);
length age_range $ 10;
set bi.sas_bi;
if 8<=  year_old <=	18 then age_range='8-18';
else if 19<=  year_old <= 30 then age_range='19-30';
else if 31<=  year_old <= 45 then age_range='31-45';
else  age_range='46-63';
run;

proc sort data=	bi.age_range out=bi.age_range1;;
by age_range prov channel descending buy_date;
run;

data bi.age_range2;
set bi.age_range1;
where substr(put(buy_date,date9.),6)='2012';
run;

data  bi.age_range3(drop=buy_date) ;
set bi.age_range2;
month= month(buy_date)	;
run;

proc sql;
create table bi.age_range4 as
select age_range, prov, channel, month , sum(buy_amount)as revenue
from bi.age_range3
group by age_range, prov, channel, month;
quit;

proc sort data=bi.age_range4 out=bi.age_range5;
by age_range prov channel;
run;

proc transpose data=bi.age_range5 out=bi.age_range6 prefix=month;
by age_range prov  channel;
id month;
var revenue	;
run;

DATA bi.age_range7;
set bi.age_range6 ;
MOM_FebToJan=(Month2-Month1)/month1;
format MOM_FebToJan PERCENT7.2;

MOM_MarToFeb=(Month3-Month2)/month2;
format MOM_MarToFeb PERCENT7.2;

MOM_AprToMar=(Month4-Month3)/month3;
format MOM_AprToMar PERCENT7.2;

MOM_MayToApr=(Month5-Month4)/month4;
format MOM_MayToApr PERCENT7.2;
RUN ;


ods listing close;
ods pdf file="/folders/myfolders/sasdata/MOMSalesReportFolder/sales_report.pdf" style=sasweb;
goptions reset=all device=ActiveX xpixels= 450  ypixels= 450 ;
title h=15pt f=swiss "MOM Sales Report Automation"  ;
proc report data=bi.age_range7 nowd split="/"; 
column age_range prov channel month1 month2 month3 month4 month5  MOM_FebToJan;
define age_range/"Age Range" left ; 
define prov/"Province" left ;
define channel/"Channel" left;
define month1/"Jan" left ;
define month2/"Feb" center ; 
define month3/"Mar" center ; 
define month4/"Apr" center ; 
define month5/"May" center ; 
define MOM_FebToJan/"MOM_FebToJan" right   format=percent11.2 ; 
define MOM_MarToFeb/"MOM_MarToFeb" right   format=percent11.2 ; 
define MOM_AprToMar/"MOM_AprToMar" right   format=percent11.2 ; 
define MOM_MayToApr/"MOM_MayToApr" right   format=percent11.2 ; 
run;
quit;
ods pdf close;
ods listing;




%Macro Salesreport;
data bi.age_range7;
set bi.age_range6;
loops=_n_;
run;

proc sql;
select max(loops)into:loops
from bi.age_range8;
quit;

%do=i %to &loops;
proc sql;
create table bi.test as
select Jan,Feb,Mar,Apr,May into :Month1, :Month2, :Month3, :Month4, :Month5 
from bi.age_range7
where loops=&i;
quit; 

DATA bi.age_range8;
set bi.age_range7 ;
MOM_FebToJan=('&Month2'-'&Month1')/'&month1';
format MOM_FebToJan PERCENT7.2;

MOM_MarToFeb=('&Month3'-'&Month2')/'&month2';
format MOM_MarToFeb PERCENT7.2;

MOM_AprToMar=('&Month4'-'&Month3')/'&month3';
format MOM_AprToMar PERCENT7.2;

MOM_MayToApr=('&Month5'-'&Month4')/'&month4';
format MOM_MayToApr PERCENT7.2;
RUN ;
%end;
%mend;
%Salesreport; 






