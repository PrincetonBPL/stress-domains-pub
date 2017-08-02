*! version 1.0.1 , 20Mar2000
program define joint1 , rclass
* Arie Beresteanu and Charles Manski
* Northwestern University
version 6.0

syntax varlist(min=3 max=6) [if] ,/*
*/ Low(string) High(string) [ Boot(integer 0) Level(real 95)*]

tokenize `varlist'
local xnum : word count `varlist'
local xnum=`xnum'-2
local iy `1'
local iz `2'
local i 1
while `i'<=`xnum' {
	local j=`i'+2
	local ix`i'  ``j''
	local i=`i'+1
}

	tokenize `low'
	local lownum : word count `low'
	local i 1
	while `i'<=`lownum' {
	local l`i'="``i''"
	local i=`i'+1
	}	

	tokenize `high'
	local highnum : word count `high'
	local i 1
	while `i'<=`highnum' {
	local h`i'="``i''"
	local i=`i'+1
	}	

if `lownum'!=`xnum' {
	di in red "number of lower bound variables does not match number of covariates"
	exit 198
}
if `highnum'!=`xnum' {
	di in red "number of upper bound variables does not match number of covariates"
	exit 198
}

qui count if `l1'!=.
local n = r(N)

tempvar pl pu yhl yhu
qui gen long `pl'=.
qui gen long `pu'=.
qui gen long `yhl'=.
qui gen long `yhu'=.

local i 1
while `i'<=`n' {
	local j 1
	local zl=""
	local zh=""
	while `j'<=`xnum' {
		local zzl=string(`l`j''[`i'])
		local zzh=string(`h`j''[`i'])
		local zl="`zl' `zzl'"
		local zh="`zh' `zzh'"
		local j=`j'+1
	}
	joint12 `iy' `iz' `ix1' `ix2' `ix3' `ix4', low(`zl') high(`zh')  
	qui replace `pl'=r(probL) in `i'
	qui replace `pu'=r(probU) in `i'
	qui replace `yhl'=r(yhatL) in `i'
	qui replace `yhu'=r(yhatU) in `i'
	local i=`i'+1
}

local probL "probL"
local probU "probU"
local yhatL "yhatL"
local yhatU "yhatU"

*! Outputing the results
capture confirm new variable probL
if _rc==110 {
	qui replace `probL'=`pl'
}
else {
	qui gen `probL'=`pl'
}
capture confirm new variable probU
if _rc==110 {
	qui replace `probU'=`pu'
}
else {
	qui gen `probU'=`pu'
}
capture confirm new variable yhatL
if _rc==110 {
	qui replace `yhatL'=`yhl'
}
else {
	qui gen `yhatL'=`yhl'
}
capture confirm new variable yhatU
if _rc==110 {
	qui replace `yhatU'=`yhu'
}
else {
	qui gen `yhatU'=`yhu'
}

if `boot'>0 {
	local prL_lb "prL_lb"
	local prL_ub "prL_ub"
	local yhL_lb "yhL_lb"
	local yhL_ub "yhL_ub"
	local yhU_lb "yhU_lb"
	local yhU_ub "yhU_ub"
	tempvar prl_lb prl_ub yL_lb yL_ub yU_lb yU_ub
	qui gen `prl_lb'=.
	qui gen `prl_ub'=.
	qui gen `yL_lb'=.
	qui gen `yL_ub'=.
	qui gen `yU_lb'=.
	qui gen `yU_ub'=.
	di "Running `boot' bootstrap simulation for each grid point - please wait"
	local i 1
	while `i'<=`n' {
		local j 1
		local zl=""
		local zh=""
		while `j'<=`xnum' {
			local zzl=string(`l`j''[`i'])
			local zzh=string(`h`j''[`i'])
			local zl="`zl' `zzl'"
			local zh="`zh' `zzh'"
			local j=`j'+1
		}
	di "grid point #`i'"	
	qui bs "joint12 `iy' `iz' `ix1' `ix2' `ix3' `ix4', low(`zl') high(`zh') " "r(propL) r(yhatL) r(yhatU)"  , reps(`boot') l(`level') saving(treatbs) replace
	merge using treatbs
	qui sum bs1,detail
	qui replace `prl_lb' =r(p5) in `i'
	qui replace `prl_ub'=r(p95) in `i'
	qui sum bs2,detail
	qui replace `yL_lb' =r(p5) in `i'
	qui replace `yL_ub'=r(p95) in `i'
	qui sum bs3,detail
	qui replace `yU_lb' =r(p5) in `i'
	qui replace `yU_ub'=r(p95) in `i'
	drop _merge bs1 bs2 bs3 bs4 bs5 
	local i=`i'+1
	}
	capture confirm new variable prL_lb
	if _rc==110 {
		qui replace `prL_lb'=`prl_lb'
	}
	else {
		qui gen `prL_lb'=`prl_lb'
	}
	capture confirm new variable prL_ub
	if _rc==110 {
		qui replace `prL_ub'=`prl_ub'
	}
	else {
		qui gen `prL_ub'=`prl_ub'
	}
	capture confirm new variable yhL_lb
	if _rc==110 {
		qui replace `yhL_lb'=`yL_lb'
	}
	else {
		qui gen `yhL_lb'=`yL_lb'
	}
	capture confirm new variable yhL_ub
	if _rc==110 {
		qui replace `yhL_ub'=`yL_ub'
	}
	else {
		qui gen `yhL_ub'=`yL_ub'
	}
	capture confirm new variable yhU_lb
	if _rc==110 {
		qui replace `yhU_lb'=`yU_lb'
	}
	else {
		qui gen `yhU_lb'=`yU_lb'
	}
	capture confirm new variable yhU_ub
	if _rc==110 {
		qui replace `yhU_ub'=`yU_ub'
	}
	else {
		qui gen `yhU_ub'=`yU_ub'
	}

}


ret scalar n = `n'
ret scalar xnum=`xnum'
ret local kernel `"`kernel'"'
ret local method `"`method'"'


end

