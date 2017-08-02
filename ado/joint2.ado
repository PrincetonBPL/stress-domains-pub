*! version 1.0.1 , 20Mar2000
program define joint2 , rclass
* Arie Beresteanu and Charles Manski
* Northwestern University
version 6.0

syntax varlist(min=3 max=6) [if] ,/*
*/ AT(string) [ CONtinuous /* 
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


tempvar mm1 mm2 mm3 mm4 mmt mmt1
qui gen long `mm1'=0
qui gen long `mm2'=0
qui gen long `mm3'=0
qui gen long `mm4'=0
qui gen long `mmt'=0
qui gen long `mmt1'=0

	tokenize `at'
	local atnum : word count `at'
	local i 1
	while `i'<=`atnum' {
	local m`i'=``i''
	local i=`i'+1
	}	

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

	if `atnum'!=`xnum' {
			di in red `"number of covariates don't match length of grid point"'
			exit 198
				}
		qui count if `m1'!=.
		local n = r(N)
		

if `"`continuous'"' !=`""' {
	qui sum `iz'
	local pz=r(mean)
	qui kern2 `iz' `ix1' `ix2' `ix3' `ix4', at(`m1' `m2' `m3' `m4') /*
		*/  `epan' `biweigh' `triangl' `gauss' `rectang' /*
		*/ w1(`w1') w2(`w2') w3(`w3') w4(`w4')
	local px=r(xdens)
	local pe=`px'*`pz'/(`px'*`pz'+1-`pz')
	qui kern2 `iy' `ix1' `ix2' `ix3' `ix4' if `iz'==1, at(`m1' `m2' `m3' `m4') /*
		*/  `epan' `biweigh' `triangl' `gauss' `rectang' /*
		*/ w1(`w1') w2(`w2') w3(`w3') w4(`w4')
	local yh1=r(expect)
	local yhl=`yh1'*`pe'
	local yhu=`yh1'*`pe'+`pe'
	local method= "continuous"
	}
else {
	qui sum `iz' [w=`mmt']
	local pz=r(mean)
	qui sum `mmt'
	local px=r(mean)
	local pe=`px'*`pz'/(`px'*`pz'+1-`pz')
	qui sum `iy' [w=`mmt1']
	local yh1=r(mean)
	local yhl=`yh1'*`pe'
	local yhu=`yh1'*`pe'+`pe'
	local method= "discrete"
	local kernel="none"
	}

ret clear
ret scalar probL = `pe'
ret scalar probU = 1
ret scalar yhatL = `yhl'
ret scalar yhatU = `yhu'
ret scalar n = `n'
ret scalar xnum=`xnum'
ret local kernel `"`kernel'"'
ret local method `"`method'"'

global S_1=`pe'
global S_2=1
global S_3=`yhl'
global S_4=`yhu'

end

