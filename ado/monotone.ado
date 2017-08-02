*! version 1.0.1 , 20Mar2000
program define monotone, rclass
* Arie Beresteanu and Charles Manski
* Northwestern University
version 6.0

syntax varlist(min=2 max=6) [if] ,/*
*/ AT(string) [ CONtinuous DECrease CONVex CONCave /* 
*/ Low(real 0.0) High(real 1.0) /*
*/ W1(real 0.0) W2(real 0.0) W3(real 0.0) W4(real 0.0)/*
*/ BIweight EPan GAUss RECtangle  /*
*/ TRIangle Boot(integer 0) Level(real 95)*]

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

	local con = ( (`"`convex'"' !=`""') + (`"'concave'"' != `""') )
	if `con' >1 {
		di in red `"treatment effect can not be both concave and convex"'
		exit 198
	}
	local kflag = ( (`"`epan'"' != `""') + (`"`biweigh'"' != `""') + /*
			*/ (`"`triangl'"' != `""') + (`"`gauss'"' != `""') + /*
			*/ (`"`rectang'"' != `""'))
	if `kflag' > 1 {
		di in red `"only one kernel may be specified"'
		exit 198
	}

	if `"`biweigh'"'       != `""' { local kernel=`"Biweight"'     }
	else if `"`triangl'"'  != `""' { local kernel=`"Triangle"'     }
	else if `"`gauss'"'    != `""' { local kernel=`"Gaussian"'     }
	else if `"`rectang'"'  != `""' { local kernel=`"Rectangular"'  }
	else                       { local kernel=`"Epanechnikov"' }

	tokenize `at'
	local atnum : word count `at'
	if `atnum' != `xnum'+1 {
		di in red `"insufficient parameters in at() option"'
		exit 198
	}
	local i 1
while `i'<=`atnum' {
	if `i'==1 {
		local t="``i''"
	}
	else {
		local k=`i'-1
		local m`k'=``i''
	}
	local i=`i'+1
}	
local atnum=`atnum'-1
qui count if `t'!=.
local n=r(N)

tempvar p0 p1 lb ub
qui gen double `p1'=.
qui gen double `p0'=.
qui gen double `lb'=.
qui gen double `ub'=.

if `low'>`high' {
	di in red '"Lower bound of outcome can not be bigger than the upper bound"'
	exit 198
}
local i 1
while `i'<=`n' {
	local j 1
	local z="`t'[`i']"
	while `j'<=`xnum' {
		local zz=string(`m`j''[`i'])
		local z="`z' `zz'"
		local j=`j'+1
	}
	mono2 `iy' `iz' `ix1' `ix2' `ix3' `ix4', at(`z') `continuous' w1(`w1') w2(`w2') w3(`w3') w4(`w4') `epan' `biweigh' `triangl' `gauss' `rectang' 
	qui replace `p1'=r(prop1) in `i'
	qui replace `p0'=r(prop0) in `i'
	qui replace `lb'=r(LB) in `i'
	qui replace `ub'=r(UB) in `i'
	local i=`i'+1
}

local prob0 "prob0"
local prob1 "prob1"
local boundL "boundL"
local boundU "boundU"


*! Outputing the results
capture confirm new variable prob0
if _rc==110 {
	qui replace `prob0'=`p0'
}
else {
	qui gen `prob0'=`p0'
}
capture confirm new variable prob1
if _rc==110 {
	qui replace `prob1'=`p1'
}
else {
	qui gen `prob1'=`p1'
}
capture confirm new variable boundL
if _rc==110 {
	qui replace `boundL'=`lb'
}
else {
	qui gen `boundL'=`lb'
}
capture confirm new variable boundU
if _rc==110 {
	qui replace `boundU'=`ub'
}
else {
	qui gen `boundU'=`ub'
}

if `boot'>0 {
	local pr0_lb0 "pr0_lb"
	local pr0_ub0 "pr0_ub"
	local pr1_lb1 "pr1_lb"
	local pr1_ub1 "pr1_ub"
	local bdL_lb "bdL_lb"
	local bdL_ub "bdL_ub"
	local bdU_lb "bdU_lb"
	local bdU_ub "bdU_ub"
	tempvar p0_lb p0_ub p1_lb p1_ub  bl_lb bl_ub bu_lb bu_ub
	qui gen `p0_lb'=.
	qui gen `p0_ub'=.
	qui gen `p1_lb'=.
	qui gen `p1_ub'=.
	qui gen `bl_lb'=.
	qui gen `bl_ub'=.
	qui gen `bu_lb'=.
	qui gen `bu_ub'=.
	di "Running `boot' bootstrap simulation for each grid point - please wait"
	local i 1
	while `i'<=`n' {
		local j 1
		local z="`t'[`i']"
		while `j'<=`xnum' {
			local zz=string(`m`j''[`i'])
			local z="`z' `zz'"
			local j=`j'+1
		}
	di "grid point #`i'"	
	qui bs "mono2 `iy' `iz' `ix1' `ix2' `ix3' `ix4', at(`z') `continuous' w1(`w1') w2(`w2') w3(`w3') w4(`w4') `epan' `biweigh' `triangl' `gauss' `rectang' " "r(prop0) r(prop1)  r(LB) r(UB)"  , reps(`boot') l(`level') saving(treatbs) replace
	merge using treatbs
	qui sum bs1,detail
	qui replace `p0_lb' =r(p5) in `i'
	qui replace `p0_ub'=r(p95) in `i'
	qui sum bs2,detail
	qui replace `p1_lb' =r(p5) in `i'
	qui replace `p1_ub'=r(p95) in `i'
	qui sum bs3,detail
	qui replace `bl_lb' =r(p5) in `i'
	qui replace `bl_ub'=r(p95) in `i'
	qui sum bs4,detail
	qui replace `bu_lb' =r(p5) in `i'
	qui replace `bu_ub'=r(p95) in `i'
	drop _merge bs1 bs2 bs3 bs4
	local i=`i'+1
	}
	capture confirm new variable pr0_lb
	if _rc==110 {
		qui replace `pr0_lb'=`p0_lb'
	}
	else {
		qui gen `pr0_lb'=`p0_lb'
	}
	capture confirm new variable pr0_ub
	if _rc==110 {
		qui replace `pr0_ub'=`p0_ub'
	}
	else {
		qui gen `pr0_ub'=`p0_ub'
	}
	capture confirm new variable pr1_lb
	if _rc==110 {
		qui replace `pr1_lb'=`p1_lb'
	}
	else {
		qui gen `pr1_lb'=`p1_lb'
	}
	capture confirm new variable pr1_ub
	if _rc==110 {
		qui replace `pr1_ub'=`p1_ub'
	}
	else {
		qui gen `pr1_ub'=`p1_ub'
	}
	capture confirm new variable bdL_lb
	if _rc==110 {
		qui replace `bdL_lb'=`bl_lb'
	}
	else {
		qui gen `bdL_lb'=`bl_lb'
	}
	capture confirm new variable bdL_ub
	if _rc==110 {
		qui replace `bdL_ub'=`bl_ub'
	}
	else {
		qui gen `bdL_ub'=`bl_ub'
	}
	capture confirm new variable bdU_lb
	if _rc==110 {
		qui replace `bdU_lb'=`bu_lb'
	}
	else {
		qui gen `bdU_lb'=`bu_lb'
	}
	capture confirm new variable bdU_ub
	if _rc==110 {
		qui replace `bdU_ub'=`bu_ub'
	}
	else {
		qui gen `bdU_ub'=`bu_ub'
	}

}
ret scalar n = `n'
ret scalar xnum=`xnum'
ret local kernel `"`kernel'"'
ret local method `"`method'"'

end
