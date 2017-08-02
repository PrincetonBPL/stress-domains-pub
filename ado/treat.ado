*! version 1.0.1 , 20Mar2000
program define treat, rclass
* Arie Beresteanu and Charles Manski
* Northwestern University
version 6.0

syntax varlist(min=3 max=6) [if] ,/*
*/ AT(string) [ CONtinuous /* 
*/ W1(real 0.0) W2(real 0.0) W3(real 0.0) W4(real 0.0)/*
*/ BIweight EPan GAUss RECtangle /*
*/ TRIangle Boot(integer 0) Level(real 95) *]

tokenize `varlist'
local xnum : word count `varlist'
local xnum=`xnum'-2
local iy `1'
local iz `2'
local i 1
while `i'<=`xnum' {
	local j=`i'+2
	local ix`i' ``j''
	local i=`i'+1
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
	local i 1
	while `i'<=`atnum' {
	qui local at`i' ``i''
	local i=`i'+1
	}	
if `atnum'!=`xnum' {
	di in red "number of grid variables does not match number of covariates"
	exit 198
} 

qui count if `at1'!=.
local n=r(N)



tempvar p0 p1 yh0 yh1 mm mm0 mm1
qui gen long `p1'=.
qui gen long `p0'=.
qui gen long `yh1'=.
qui gen long `yh0'=.
qui gen `mm'=.
qui gen `mm0'=.
qui gen `mm1'=.

if `"`continuous'"' !=`""' {
	qui kernreg `iz' `ix1' `ix2' `ix3' `ix4', at(`at1' `at2' `at3' `at4') /*
		*/  gen(`p1') `epan' `biweigh' `triangl' `gauss' `rectang' /*
		*/ w1(`w1') w2(`w2') w3(`w3') w4(`w4')
	qui replace `p0'=1-`p1'
	qui kernreg `iy' `ix1' `ix2' `ix3' `ix4' if `iz'==1, at(`at1' `at2' `at3' `at4') /*
		*/  gen(`yh1') `epan' `biweigh' `triangl' `gauss' `rectang' /*
		*/ w1(`w1') w2(`w2') w3(`w3') w4(`w4')
	qui kernreg `iy' `ix1' `ix2' `ix3' `ix4' if `iz'==0, at(`at1' `at2' `at3' `at4') /*
		*/ gen(`yh0') `epan' `biweigh' `triangl' `gauss' `rectang' /*
		*/ w1(`w1') w2(`w2') w3(`w3') w4(`w4')
	local method= "continuous"
	}
else {
	local i 1
	while `i'<=`n' {
		local j 1
		local z=""
		while `j'<=`xnum' {
			local zz=string(`at`j''[`i'])
			local z="`z' `zz'"
			local j=`j'+1
		}
	treat2 `iy' `iz' `ix1' `ix2' `ix3' `ix4', at(`z') 
		qui replace `p1'=r(prob1) in `i'
		qui replace `p0'=r(prob0) in `i'
		qui replace `yh1'=r(yhat1) in `i'
		qui replace `yh0'=r(yhat0) in `i'
		local i=`i'+1
	}
	local method= "discrete"
	local kernel="none"
}


tempvar bl1 bu1 bl0 bu0 tl tu
qui gen `bl1'=`yh1'*`p1'
qui gen `bl0'=`yh0'*`p0'
qui gen `bu1'=`yh1'*`p1'+`p0'
qui gen `bu0'=`yh0'*`p0'+`p1'
qui gen `tl'=`yh1'*`p1'-`yh0'*`p0'-`p1'
qui gen `tu'=`yh1'*`p1'+`p0'-`yh0'*`p0'

local prob0 "prob0"
local prob1 "prob1"
local yhat0 "yhat0"
local yhat1 "yhat1"
local treatL "treatL"
local treatU "treatU"
local boundL0 "boundL0"
local boundL1 "boundL1"
local boundU0 "boundU0"
local boundU1 "boundU1"


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
capture confirm new variable yhat0
if _rc==110 {
	qui replace `yhat0'=`yh0'
}
else {
	qui gen `yhat0'=`yh0'
}

capture confirm new variable yhat1
if _rc==110 {
	qui replace `yhat1'=`yh1'
}
else {
	qui gen `yhat1'=`yh1'
}
capture confirm new variable boundL0
if _rc==110 {
	qui replace `boundL0'=`bl0'
}
else {
	qui gen `boundL0'=`bl0'
}
capture confirm new variable boundL1
if _rc==110 {
	qui replace `boundL1'=`bl1'
}
else {
	qui gen `boundL1'=`bl1'
}
capture confirm new variable boundU0
if _rc==110 {
	qui replace `boundU0'=`bu0'
}
else {
	qui gen `boundU0'=`bu0'
}
capture confirm new variable boundU1
if _rc==110 {
	qui replace `boundU1'=`bu1'
}
else {
	qui gen `boundU1'=`bu1'
}
capture confirm new variable treatU
if _rc==110 {
	qui replace `treatU'=`tu'
}
else {
	qui gen `treatU'=`tu'
}
capture confirm new variable treatL
if _rc==110 {
	qui replace `treatL'=`tl'
}
else {
	qui gen  `treatL'=`tl'
}

if `boot'>0 {
	local pr0_lb "pr0_lb"
	local pr0_ub "pr0_ub"
	local pr1_lb "pr1_lb"
	local pr1_ub "pr1_ub"
	local yh0_lb "yh0_lb"
	local yh0_ub "yh0_ub"
	local yh1_lb "yh1_lb"
	local yh1_ub "yh1_ub"
	local bdL1_lb "bdL1_lb"
	local bdL1_ub "bdL1_ub"
	local bdU1_lb "bdU1_lb"
	local bdU1_ub "bdU1_ub"
	local bdL0_lb "bdL0_lb"
	local bdL0_ub "bdL0_ub"
	local bdU0_lb "bdU0_lb"
	local bdU0_ub "bdU0_ub"
	local trL_lb "trL_lb"
	local trL_ub "trL_ub"
	local trU_lb "trU_lb"
	local trU_ub "trU_ub"
	tempvar p0_lb p0_ub p1_lb p1_ub y0_lb y0_ub y1_lb y1_ub bl1_lb bl1_ub bu1_lb bu1_ub bl0_lb bl0_ub bu0_lb bu0_ub tl_lb tl_ub tu_lb tu_ub
	qui gen `p0_lb'=.
	qui gen `p0_ub'=.
	qui gen `p1_lb'=.
	qui gen `p1_ub'=.
	qui gen `y0_lb'=.
	qui gen `y0_ub'=.
	qui gen `y1_lb'=.
	qui gen `y1_ub'=.
	qui gen `bl1_lb'=.
	qui gen `bl1_ub'=.
	qui gen `bu1_lb'=.
	qui gen `bu1_ub'=.
	qui gen `bl0_lb'=.
	qui gen `bl0_ub'=.
	qui gen `bu0_lb'=.
	qui gen `bu0_ub'=.
	qui gen `tl_lb'=.
	qui gen `tl_ub'=.
	qui gen `tu_lb'=.
	qui gen `tu_ub'=.
	di "Running `boot' bootstrap simulation for each grid point - please wait"
	local i 1
	while `i'<=`n' {
		local j 1
		local z=""
		while `j'<=`xnum' {
			local zz=string(`at`j''[`i'])
			local z="`z' `zz'"
			local j=`j'+1
		}
	di "grid point #`i'"	
	qui bs "treat2 `iy' `iz' `ix1' `ix2' `ix3' `ix4', at(`z') `continuous' w1(`w1') w2(`w2') w3(`w3') w4(`w4') `epan' `biweigh' `triangl' `gauss' `rectang' " "r(prop0) r(prop1) r(yhat0) r(yhat1) r(boundL0) r(boundU0) r(boundL1) r(boundU1) r(treatL) r(treatU)"  , reps(`boot') l(`level') saving(treatbs) replace
	merge using treatbs
	qui sum bs1,detail
	qui replace `p0_lb' =r(p5) in `i'
	qui replace `p0_ub'=r(p95) in `i'
	qui sum bs2,detail
	qui replace `p1_lb' =r(p5) in `i'
	qui replace `p1_ub'=r(p95) in `i'
	qui sum bs3,detail
	qui replace `y0_lb' =r(p5) in `i'
	qui replace `y0_ub'=r(p95) in `i'
	qui sum bs4,detail
	qui replace `y1_lb' =r(p5) in `i'
	qui replace `y1_ub'=r(p95) in `i'
	qui sum bs5,detail
	qui replace `bl0_lb' =r(p5) in `i'
	qui replace `bl0_ub'=r(p95) in `i'
	qui sum bs6,detail
	qui replace `bu0_lb' =r(p5) in `i'
	qui replace `bu0_ub'=r(p95) in `i'
	qui sum bs7,detail
	qui replace `bl1_lb' =r(p5) in `i'
	qui replace `bl1_ub'=r(p95) in `i'
	qui sum bs8,detail
	qui replace `bu1_lb' =r(p5) in `i'
	qui replace `bu1_ub'=r(p95) in `i'
	qui sum bs9,detail
	qui replace `tl_lb' =r(p5) in `i'
	qui replace `tl_ub'=r(p95) in `i'
	qui sum bs10,detail
	qui replace `tu_lb' =r(p5) in `i'
	qui replace `tu_ub'=r(p95) in `i'
	drop _merge bs1 bs2 bs3 bs4 bs5 bs6 bs7 bs8 bs9 bs10
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
	capture confirm new variable yh0_lb
	if _rc==110 {
		qui replace `yh0_lb'=`y0_lb'
	}
	else {
		qui gen `yh0_lb'=`y0_lb'
	}
	capture confirm new variable yh0_ub
	if _rc==110 {
		qui replace `yh0_ub'=`y0_ub'
	}
	else {
		qui gen `yh0_ub'=`y0_ub'
	}
	capture confirm new variable yh1_lb
	if _rc==110 {
		qui replace `yh1_lb'=`y1_lb'
	}
	else {
		qui gen `yh1_lb'=`y1_lb'
	}
	capture confirm new variable yh1_ub
	if _rc==110 {
		qui replace `yh1_ub'=`y1_ub'
	}
	else {
		qui gen `yh1_ub'=`y1_ub'
	}
	capture confirm new variable bdL1_lb
	if _rc==110 {
		qui replace `bdL1_lb'=`bl1_lb'
	}
	else {
		qui gen `bdL1_lb'=`bl1_lb'
	}
	capture confirm new variable bdL1_ub
	if _rc==110 {
		qui replace `bdL1_ub'=`bl1_ub'
	}
	else {
		qui gen `bdL1_ub'=`bl1_ub'
	}
	capture confirm new variable bdU1_lb
	if _rc==110 {
		qui replace `bdU1_lb'=`bu1_lb'
	}
	else {
		qui gen `bdU1_lb'=`bu1_lb'
	}
	capture confirm new variable bdU1_ub
	if _rc==110 {
		qui replace `bdU1_ub'=`bu1_ub'
	}
	else {
		qui gen `bdU1_ub'=`bu1_ub'
	}
	capture confirm new variable bdL0_lb
	if _rc==110 {
		qui replace `bdL0_lb'=`bl0_lb'
	}
	else {
		qui gen `bdL0_lb'=`bl0_lb'
	}
	capture confirm new variable bdL0_ub
	if _rc==110 {
		qui replace `bdL0_ub'=`bl0_ub'
	}
	else {
		qui gen `bdL0_ub'=`bl0_ub'
	}
	capture confirm new variable bdU0_lb
	if _rc==110 {
		qui replace `bdU0_lb'=`bu0_lb'
	}
	else {
		qui gen `bdU0_lb'=`bu0_lb'
	}
	capture confirm new variable bdU0_ub
	if _rc==110 {
		qui replace `bdU0_ub'=`bu0_ub'
	}
	else {
		qui gen `bdU0_ub'=`bu0_ub'
	}
	capture confirm new variable trL_lb
	if _rc==110 {
		qui replace `trL_lb'=`tl_lb'
	}
	else {
		qui gen `trL_lb'=`tl_lb'
	}
	capture confirm new variable trL_ub
	if _rc==110 {
		qui replace `trL_ub'=`tl_ub'
	}
	else {
		qui gen `trL_ub'=`tl_ub'
	}
	capture confirm new variable trU_lb
	if _rc==110 {
		qui replace `trU_lb'=`tu_lb'
	}
	else {
		qui gen `trU_lb'=`tu_lb'
	}
	capture confirm new variable trU_ub
	if _rc==110 {
		qui replace `trU_ub'=`tu_ub'
	}
	else {
		qui gen `trU_ub'=`tu_ub'
	}

}
ret scalar n = `n'
ret scalar xnum=`xnum'
ret local kernel `"`kernel'"'
ret local method `"`method'"'

end
