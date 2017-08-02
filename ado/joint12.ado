*! version 1.0.1 , 20jun2000
program define joint12 , rclass
* Arie Beresteanu and Charles Manski
* Northwestern University
version 6.0

syntax varlist(min=3 max=6) [if] ,/*
*/ Low(string) High(string) 

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


tempvar mm1 mm2 mm3 mm4 mmt mmtz mmt1
qui gen long `mm1'=0
qui gen long `mm2'=0
qui gen long `mm3'=0
qui gen long `mm4'=0
qui gen long `mmt'=0
qui gen long `mmtz'=0
qui gen long `mmt1'=0

	tokenize `low'
	local lownum : word count `low'
	local i 1
	while `i'<=`lownum' {
	local l`i'=``i''
	local i=`i'+1
	}	

	tokenize `high'
	local highnum : word count `high'
	local i 1
	while `i'<=`highnum' {
	local h`i'=``i''
	local i=`i'+1
	}	

	if `lownum'!=`xnum' {
			di in red `"number of covariates don't match length of lower bound"'
			exit 198
				}

	if `highnum'!=`xnum' {
			di in red `"number of covariates don't match length of upper bound"'
			exit 198
				}


qui replace `mm1'=1 if `ix1'>=`l1' & `ix1'<=`h1'
qui replace `mmt'=`mm1'

if `lownum' > 1 {
		qui replace `mm2'=1 if `ix2'>=`l2' & `ix2'<=`h2'
		qui replace `mmt'=`mmt'*`mm2'
		}
if `lownum' > 2 {
		qui replace `mm3'=1 if `ix3'>=`l3' & `ix3'<=`h3'
		qui replace `mmt'=`mmt'*`mm3'
		}
if `lownum' > 3 {
		qui replace `mm4'=1 if `ix4'>=`l4' & `ix4'<=`h4'
		qui replace `mmt'=`mmt'*`mm4'
		}
qui replace `mmtz'=1 if `iz'==1
qui replace `mmt1'=`mmtz'*`mmt'

		qui count if `l1'!=.
		local n = r(N)
		
qui sum `iz' 
local pz=r(mean)
local nz=r(sum)
qui sum `mmt1' ,detail
local px=r(sum)/`nz'
local pe=`px'*`pz'/(`px'*`pz'+1-`pz')
qui sum `iy' [w=`mmt1']
local yh1=r(mean)
local yhl=`yh1'*`pe'
local yhu=`yh1'*`pe'+`pe'


ret clear
ret scalar probL = `pe'
ret scalar probU = 1
ret scalar yhatL = `yhl'
ret scalar yhatU = `yhu'
ret scalar n = `n'
ret scalar xnum=`xnum'

global S_1=`pe'
global S_2=1
global S_3=`yhl'
global S_4=`yhu'

end

