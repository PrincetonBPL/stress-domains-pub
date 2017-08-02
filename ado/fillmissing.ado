*! version 1.0.0  31may2013
* This program, written by Johannes Haushofer, May 31, 2013, takes a varlist, 
* and creates a new variable called "var_full" where all missings of var are replaced 
* with zero, and another variable called "var_missing" which is a dummy for "var==.". 
* With the "replace" option, the command replaces any existing variables var_full and/or var_missing.

* SYNTAX: fillmissing(varlist) [, replace]

 program define fillmissing
	syntax varlist(min=1) [if] [in] [, BY(string)] [,replace]
	
	dis `"`replace'"'
	foreach x of varlist `varlist' {
		if `"`replace'"' != "" {
			cap drop `x'_full
			cap drop `x'_missing
			cap drop `x'_miss
			}
		qui g `x'_full = `x'
		qui g `x'_miss = `x'_full==.
		qui replace `x'_full = 0 if `x'_full == .
		dis "Generated new variables `x'_full and `x'_miss"
		qui local l: variable label `x'
		label variable `x'_full "`l' - Full"
		label variable `x'_miss "`l' - Missing"
		}
end

