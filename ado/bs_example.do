#delimit ;

version 9.0 ;
cap log close ;
log using bs_example.log , replace ;

clear ;
set mem 5m ;
set more off ;
set seed 365476247 ;

cap prog drop runme ;
prog def runme ;

local hypothesis = `1' ;
tempfile main bootsave ;

use collapsed ;
/* 	hasinsurance - LHS var, fraction with insurance
	selfemployed - 0/1 dummmy var for self employed
	post - 0/1 dummy var for after policy
	post_self - interaction of post and self
*/

di ;
reg hasinsurance selfemployed post post_self , cluster(year) ;
global mainbeta = _b[post_self] ;
global maint = (_b[post_self] - `hypothesis') / _se[post_self] ;
predict epshat , resid;
predict yhat , xb ;

/* also generate "impose the null hypothesis" yhat and residual */
gen temp_y = hasinsurance - post_self * `hypothesis' ;
reg temp_y selfemployed post ;
predict epshat_imposed , resid ;
predict yhat_imposed , xb ;
qui replace yhat_imposed = yhat_imposed + post_self * `hypothesis' ;

sort year self ;
qui save `main' , replace ;

qui by year: keep if _n == 1 ;
qui summ ;
global numyears = r(N) ;

cap erase `bootsave' ;
qui postfile bskeep beta_np t_np t_fixx t_wild
	using `bootsave' , replace ;

forvalues b = 1/$bootreps { ;

/* first do wild bootstrap */
use `main', replace ;
qui by year: gen temp = uniform() ;
qui by year: gen pos = (temp[1] < .5) ;
/*  these two lines (and commendted t-stat below
are if you don't want to impose the null hypothesis*/
/*
gen wildresid = epshat * (2*pos - 1) ;
gen wildy = yhat + wildresid ;
*/
gen wildresid = epshat_imposed * (2*pos - 1) ;
gen wildy = yhat_imposed + wildresid ;
qui reg wildy selfemployed post post_self , cluster(year) ;
local bst_wild = (_b[post_self] - `hypothesis') / _se[post_self] ;
*local bst_wild = (_b[post_self] - $mainbeta) / _se[post_self] ;

/* next do nonparametric bootstrap */
bsample , cluster(year) idcluster(newyear) ;
qui reg hasinsurance selfemployed post post_self , cluster(newyear) ;
local bsbeta = _b[post_self] ;
local bst = (_b[post_self] - $mainbeta) / _se[post_self] ;

/* now do condition on X bootstrap */
/* first randomly sort new clusters. then merge residuals onto main data */
keep epshat newyear selfemployed ;
gen newsort = uniform() ;
sort newyear ;
qui by newyear: replace newsort = newsort[1] ;
sort newsort selfemployed ;
qui by newsort: gen first = 1 if _n == 1 ;
gen newnewyear = sum(first) ;
drop newyear newsort ;
gen year = 1982 + newnewyear ;
sort year self ;
rename epshat newepshat ;
merge year self using `main' ;
gen condy = yhat + newepshat ;
qui reg condy selfemployed post post_self , cluster(year) ;
local bst_cond = (_b[post_self] - $mainbeta) / _se[post_self] ;

post bskeep (`bsbeta') (`bst') (`bst_cond') (`bst_wild') ;
} ; /* end of bootstrap reps */
qui postclose bskeep ;

qui drop _all ;
qui set obs 1 ;
gen t_np = $maint ;
gen t_fixx = $maint ;
gen t_wild = $maint ;
qui append using `bootsave' ;

qui gen n = . ;
foreach stat in t_np t_fixx t_wild { ;
qui summ `stat' ;
local bign = r(N) ;
sort `stat' ;
qui replace n = _n ;
qui summ n if abs(`stat' - $maint) < .000001 ;
local myp = r(mean) / `bign' ;
global pctile_`stat' = 2 * min(`myp',(1-`myp')) ;
} ;

global mainp = norm($maint) ;
global pctile_main = 2 * min($mainp,(1-$mainp)) ;

local myfmt = "%7.5f" ;

di ; di "Number BS reps = $bootreps, Null hypothesis = `hypothesis'" ;
display "Main beta" _column(13) "main T"	_column(22) "Main %le"
	_column(33) "NP BS %le" _column(44) "fixX %le" _column(54) "wild %le" ;
di 	%6.3f $mainbeta _column(13) %6.3f $maint  _column(23) 
	`myfmt' $pctile_main _column(34) `myfmt' $pctile_t_np 
	_column(44) `myfmt' $pctile_t_fixx
	_column(55) `myfmt' $pctile_t_wild ;

end ;

global bootreps = 999 ;
runme .04 ;
log close ;
