*! version 1.0.0  31may2013
* This program, written by Johannes Haushofer, May 31, 2013, takes a varlist, 
* and creates a new variable called "var_full" where all missings of var are replaced 
* with zero, and another variable called "var_missing" which is a dummy for "var==.". 
* With the "replace" option, the command replaces any existing variables var_full and/or var_missing.

* SYNTAX: fillmmisstime2(varlist) [, replace]

 program define fillmisstime2
	syntax varlist(min=1) [if] [in] [, BY(string)] [,replace]
	
	foreach x of varlist `varlist' {
		if `"`replace'"' != "" {
		dis "loop1"
			if "`var_ending'" == "00" | "`var_ending'" == "01" | "`var_ending'" == "10" | "`var_ending'" == "11"{
				qui local length = length("`x'")
				qui local varname = substr("`x'",1,`length'-2)
				qui local timetag = substr("`x'",`length'-1,.)
				cap drop `varname'_full`timetag'
				cap drop `varname'_miss`timetag'
				}
			else {
				qui local length = length("`x'")
				qui local varname = substr("`x'",1,`length'-1)
				qui local timetag = substr("`x'",`length',.)
				cap drop `varname'_full`timetag'
				cap drop `varname'_miss`timetag'
				}
			}
		local var_ending = substr("`x'",-2,.)
		local var_ending1 = substr("`x'",-1,.)
		display "`var_ending'"
		if "`var_ending'" == "00" | "`var_ending'" == "01" | "`var_ending'" == "10" | "`var_ending'" == "11"{
				dis "loop2"

			qui g `x'_full = `x'
			qui local length = length("`x'")
			qui local varname = substr("`x'",1,`length'-2)
			qui local timegendertag = substr("`x'",`length'-1,.)
			qui ren `x'_full `varname'_full`timegendertag'
		
			qui g `varname'_miss`timegendertag' = `varname'_full`timegendertag'==.
			qui replace `varname'_full`timegendertag' = 0 if `varname'_full`timegendertag' == .
			dis "Generated new variables `varname'_full`timegendertag' and `varname'_miss`timegendertag'"
			qui local l: variable label `x'
			label variable `varname'_full`timegendertag' "`l' - Full"
			label variable `varname'_miss`timegendertag' "`l' - Missing"
		}
		else if "`var_ending1'" == "0" | "`var_ending1'" == "1" {
				dis "loop3"

			if `"`replace'"' != "" {
				cap drop `x'_full
				}
			qui g `x'_full = `x'
			qui local length = length("`x'")
			qui local varname = substr("`x'",1,`length'-1)
			qui local timegendertag = substr("`x'",`length',.)
			qui ren `x'_full `varname'_full`timegendertag'
		
			qui g `varname'_miss`timegendertag' = `varname'_full`timegendertag'==.
			qui replace `varname'_full`timegendertag' = 0 if `varname'_full`timegendertag' == .
			dis "Generated new variables `varname'_full`timegendertag' and `varname'_miss`timegendertag'"
			qui local l: variable label `x'
			label variable `varname'_full`timegendertag' "`l' - Full"
			label variable `varname'_miss`timegendertag' "`l' - Missing"
		}

		else{
			qui g `x'_full = `x'
			
			qui local length = length("`x'")
			qui local varname = substr("`x'",1,`length'-1)
			qui local timetag = substr("`x'",`length',.)
			qui ren `x'_full `varname'_full`timetag'
		
			qui g `varname'_miss`timetag' = `varname'_full`timetag'==.
			qui replace `varname'_full`timetag' = 0 if `varname'_full`timetag' == .
			dis "Generated new variables `varname'_full`timetag' and `varname'_miss`timetag'"
			qui local l: variable label `x'
			label variable `varname'_full`timetag' "`l' - Full"
			label variable `varname'_miss`timetag' "`l' - Missing"
		}
		}
end

