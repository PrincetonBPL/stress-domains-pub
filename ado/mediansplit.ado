*! version 1.0.0  27may2013
* This is an add-on to egen, written by Johannes Haushofer, June 2, 2013. The command is as follows: 
* mediansplit var [, replace] [, gen(newvar)]
* Returns the median of the input variable in  r(median).

program define mediansplit, rclass
	syntax varlist(max=1) [if] [in] ,GENerate(string)
	
	tempvar touse
	qui mark `touse' `if' `in'

	quietly sum `varlist' if `touse', detail
	return local median = `r(p50)'
	qui gen `generate' = .
	qui replace `generate' = 1 if `varlist' > `r(p50)' & `touse' & `varlist'~=.
	qui replace `generate' = 0 if `varlist' <= `r(p50)' & `touse' & `varlist'~=.
	dis "Median split of `varlist' at `r(p50)', generated `generate'"	
end

