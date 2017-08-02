*! version 1.0.1 , 20Mar2000
program define mono2, rclass
* Arie Beresteanu and Charles Manski
* Northwestern University
version 6.0

syntax varlist(min=2 max=6) [if] ,/*
*/ AT(string) [ CONtinuous DECrease CONVex CONCave /* 
*/ Low(real 0.0) High(real 1.0) /*
*/ W1(real 0.0) W2(real 0.0) W3(real 0.0) W4(real 0.0)/*
*/ BIweight EPan GAUss RECtangle  /*
*/ TRIangle *]

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
		local t=``i''
	}
	else {
		local k=`i'-1
		local m`k'=``i''
	}
	local i=`i'+1
}	
local atnum=`atnum'-1

tempvar mm1 mm2 mm3 mm4 mmt mmt0 mmt1 y0 y1 z1
qui gen long `mm1'=0
qui gen long `mm2'=0
qui gen long `mm3'=0
qui gen long `mm4'=0
qui gen long `mmt'=0
qui gen long `mmt0'=0
qui gen long `mmt1'=0
qui gen double `y0'=0
qui gen double `y1'=0
qui gen double `z1'=0

if `xnum'>=1 {
	qui replace `mm1'=1 if `ix1'==`m1'
	qui replace `mmt'=`mm1'
	if `atnum'>1 {
		qui replace `mm2'=1 if `ix2'==`m2'
		qui replace `mmt'=`mmt'*`mm2'
	}
	if `atnum'>2 {
		qui replace `mm3'=1 if `ix3'==`m3'
		qui replace `mmt'=`mmt'*`mm3'
	}
	if `atnum'>3 {
		qui replace `mm4'=1 if `ix4'==`m4'
		qui replace `mmt'=`mmt'*`mm4'
	}
	qui replace `mmt1'=1 if `iz'==1
	qui replace `mmt1'=`mmt1'*`mmt'
	qui replace `mmt0'=1 if `iz'==0
	qui replace `mmt0'=`mmt0'*`mmt'

}
else {
	qui replace `mmt'=1
}
if `low'>`high' {
	di in red '"Lower bound of outcome can not be bigger than the upper bound"'
	exit 198
}

if `"`decrease'"' !=`""' {
	qui replace `y0'=`iy' if `t'<=`iz'
	qui replace `y0'=`low' if `t'>`iz'
	qui replace `y1'=`iy' if `t'>=`iz'
	qui replace `y1'=`high' if `t'<`iz'
}
else {
	if `"`concave'"' !=`""' {
		qui replace `y0'=`iy'*`t'/`iz' if `t'<`iz'
		qui replace `y0'=`iy' if `t'>=`iz'
		qui replace	`y1'=`iy' if `t'<=`iz'
		qui replace `y1'=`iy'*`t'/`iz' if `t'>`iz'
	}
	else {
		qui replace `y0'=`iy' if `t'>=`iz'
		qui replace `y0'=`low' if `t'<`iz'
		qui replace `y1'=`iy' if `t'<=`iz'
		qui replace `y1'=`high' if `t'>`iz'
	}
}

qui replace `z1'=1 if `iz'>=`t'

if `"`continuous'"' !=`""' & `atnum'>0 {
	qui kern2 `z1' `ix1' `ix2' `ix3' `ix4', at(`m1' `m2' `m3' `m4') /*
		*/ `epan' `biweigh' `triangl' `gauss' `rectang' /*
		*/  w1(`w1') w2(`w2') w3(`w3') w4(`w4')
	local p1=r(expect)
	local p0=1-`p1'
	qui kern2 `y0' `ix1' `ix2' `ix3' `ix4', at(`m1' `m2' `m3' `m4') /*
		*/ `epan' `biweigh' `triangl' `gauss' `rectang' /*
		*/  w1(`w1') w2(`w2') w3(`w3') w4(`w4')
	local lb=r(expect)
	qui kern2 `y1' `ix1' `ix2' `ix3' `ix4', at(`m1' `m2' `m3' `m4') /*
		*/ `epan' `biweigh' `triangl' `gauss' `rectang' /*
		*/  w1(`w1') w2(`w2') w3(`w3') w4(`w4')
	local ub=r(expect)
	local method= "continuous"
}
else {
	qui sum `z1' [w=`mmt']
	local p1=r(mean)
	local p0=1-`p1'
	qui sum `y0' [w=`mmt']
	local lb=r(mean)
	qui sum `y1' [w=`mmt']
	local ub=r(mean)
	local method= "discrete"
	local kernel="none"
}

qui count
local n = r(N)
ret clear
ret scalar prop1 = `p1'
ret scalar prop0 = `p0'
ret scalar LB = `lb'
ret scalar UB = `ub'
ret scalar n = `n'
ret scalar xnum=`xnum'
ret local kernel `"`kernel'"'
ret local method `"`method'"'

global S_1=`p0'
global S_2=`p0'
global S_3=`lb'
global S_4=`ub'


end
