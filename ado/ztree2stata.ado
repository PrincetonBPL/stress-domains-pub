******** ztree2stata --- Read data file created by z-Tree. 
******** Kan Takeuchi at the University of Michigan. 
******** E-mail: <ktakeuch@umich.edu>
******** Mar 01, 2005. 
******** Feb 01, 2008.  Update "trim too long names" part.


program ztree2stata
version 8

local versiondate "Mar 01, 2005"

** Define the command first. 
syntax name(name=keepthistable) using/ [, TReatment(numlist >0 integer) STRing(namelist) EXCept(namelist) SAve CLEAR REPLACE]

tokenize `string'
local counter 1
while "``counter''"~=""{ 
	local StrVar`counter' ``counter''
	local ++counter
}
local NumStrVar = `counter'-1

tokenize `except'
local counter 1
while "``counter''"~=""{ 
	local Exception`counter' ``counter''
	local ++counter
}
local NumException = `counter'-1

** Read the data.
quietly{
	insheet using `using', `clear'

sum v2
local NumTreatment = _result(6)
local CurrentTreatment = `NumTreatment' 

** Check if the treatment in the option surely includes 
** actual treatment in the data.  If not, return error. 
if "`treatment'"~=""{
	local NG 0
	foreach temp of numlist `treatment'{
		if `temp' > `NumTreatment'{
			local NG 1
		}
	}
	if `NG'{
		noisily{
			di " The treament option unmatches with the data. "
			di " Note that the data includes only `NumTreatment' treatment(s)."
		}
		error 
		exit
	}
}

tempfile tempdata

** Begin from the last treatment. 
local NotFirstTreatment 0
while `CurrentTreatment' > 0 {
* But the CurrentTreatment should be included in `treatment'.
	local UseThisTreatment 0

	if "`treatment'"==""{
		local UseThisTreatment 1 
	}
	else{
		foreach temp of numlist `treatment'{
			if `CurrentTreatment' == `temp'{
				local UseThisTreatment 1
			}
		}
	}
	
    if `UseThisTreatment'{
	if `NotFirstTreatment'{
		insheet using `using', clear
		compress
	}
	rename v1 session
	rename v2 treatment
	rename v3 tables

	* delete irrelevant observations. 
	keep if tables== "`keepthistable'"
	keep if treatment == `CurrentTreatment'
	
	des 
	local NumVariable = _result(2)

	* Then, drop duplicated labels. 
	local temp = trim(v4[1])
	drop if v4=="`temp'"&_n~=1
	
	* Rename all of the rest variables. 
	* i is counting up from v4 to v`NumVariable'. 
	tempvar tempvarname
	local i = 4
	while `i' <= `NumVariable'{
		rename v`i' `tempvarname'`i'
		local ++i
	}

	local i = 4
	while `i' <= `NumVariable'{
		* We need to check if obs of v`i' are not all missing values.
		local emptydata = missing(`tempvarname'`i'[1])
		if `emptydata' {
			local j = ""
		} 
		else{
			local j = trim(`tempvarname'`i'[1])
		}
		
		* j is the variable name of `tempvarname'`i'.
		* Let's check whether this variable is one of exceptions or not. 
		local IsException = 0
		* This counter is conuting up Exceptions below.
		local counter = 1  
		while `counter' <= `NumException'{
			if index( "`j'" , "`Exception`counter''" ) > 0{ 
				local IsException = `counter'
			}
			local ++counter
		}

		* If `tempvarname'`i' variable does not include Exception's, then `IsException' == 0. 
		if `IsException'==0{
			* delete " [ " and " ] "
			local k = index( "`j'" , "[" )
			* if j includes " [ ", then k becomes positive. 
			if `k' > 0 {
				local L = length( "`j'" )
				* delete [ 
				local j = substr( "`j'" , 1, `k'-1 ) + substr( "`j'" , `k'+1, `L' ) 
	
				* delete ] 
				local k = index( "`j'" , "]" )
				local L = length( "`j'" )
		  		local j = substr( "`j'" , 1, `k'-1 ) + substr( "`j'" , `k'+1, `L' ) 
		 	}


			*trim too long names. 
			if length( "`j'")>30{
				local j=substr( " `j' " , 1 , 15)+substr( " `j' " , length("`j'")-14 ,length("`j'"))
			}
			* For this part I owe Mr. Joshua B. Miller.  Thanks, Joshua. 
    
			* Finally define the variable name. 
			local NewName = "`j'"
		} 
	
		* If `tempvarname'`i' variable includes Exception's, then `IsException' > 0. 
		if `IsException' > 0{
			local NewName = "`Exception`IsException''"+"`i'"
		}

		* Create another variable set that is numerical. 
		* First, check if it is not one of the string variables. 	
		local OK 1
		local counter 1
		while `counter' <= `NumStrVar'{
			if "`NewName'" == "`StrVar`counter''"{
				local OK 0
			}
			local ++counter
		}
		if "`j'"==""{
			local OK 0
		}

		* Encode if OK. 
		if `OK' {
			gen `tempvarname'`i'r =  real(`tempvarname'`i') if _n~=0
		}
		else{
			gen `tempvarname'`i'r =  `tempvarname'`i'
		}

		compress `tempvarname'`i'r
		drop `tempvarname'`i'

		* Finally rename the variable name. 
		if length("`NewName'") == 0 {
			drop `tempvarname'`i'r
		}
		if length("`NewName'") > 0 {
			rename `tempvarname'`i'r `NewName'
		}

		* Then, the counter is increasing. 
		local ++i
	} // End of while `i' < `NumVariable'{
	
	drop if _n==1

	if `NotFirstTreatment'{
		append using `tempdata'
	}
		
	save `tempdata', replace 

	local NotFirstTreatment 1
	} // The end of if `UseThisTreatment'{
	
	local --CurrentTreatment
}
compress
}  // The end of quietly{ 

display ""
display "ztree2stata version `versiondate'"

set more off
describe

if "`save'"~=""{
	local newfilename = subinstr("`using'",".xls",".dta",1)
	local newfilename = subinstr("`newfilename'",".dta","-`keepthistable'.dta",1)
	save "`newfilename'", `replace'
}
end

