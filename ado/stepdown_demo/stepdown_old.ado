*! version 1.0.0  27may2013
*stepdown reg (hap1 sat1) treat spillover if ~purecontrol, options(r cluster(village)) iter(100) 
program define stepdown_old, rclass
	gettoken cmd 0 : 0
	gettoken depvars 0 : 0, parse("(") match(par)
*	gettoken treat 0 : 0
*	gettoken varlist 0 : 0, parse(",") 
syntax varlist [if] [in], ITER(integer) [OPTions(string)] [TYPE(string)]

gettoken treat varlist : varlist
*syntax [varlist] [if] [in], ITER(integer) [OPTions(string)] [TYPE(string)]


dis "depvars: `depvars'; treat: `treat'; varlist: `varlist'; options: `options'; iter: `iter'"

quietly { 
if "`iter'" == "" {
	local iter 100
	dis "Number of iterations not specified; `iter' assumed."
	}

if "`type'" == "" {
	local type "fwer"
	dis "FWER or FDR not specified; default to FWER."
	}
	
* generate variables to store actual and simulated t-stats/p-vals 
local counter = 1
gen str20 varname = ""
gen float tstat = .
gen float act_pval = .
gen float tstatsim = .
gen float pvalsim = .
gen float pvals = .

foreach x of varlist `depvars' {

	di "`cmd' `x' `treat' `varlist' `if' `in' , `options'"
	`cmd' `x' `treat' `varlist' `if' `in' , `options'

    replace tstat = abs(_b[`treat']/_se[`treat']) in `counter'
    replace act_pval = 2*ttail(e(N),abs(tstat)) in `counter'
    replace varname = "`x'" in `counter'
    local `x'_ct_0 = 0
    local counter = `counter' + 1
}

* sort the p-vals by the actual (observed) p-vals (this will reorder some of the obs, but that shouldn't matter)
gsort act_pval
local endvar = `counter' - 1
dis "Endvar: `endvar'"

* generate the variable that will contain the simulated (placebo) treatments
gen byte simtreatment = .
gen float simtreatment_uni = .
local count = 1

* run 10,000 iterations of the simulation, record results in p-val storage counters
quietly { 
while `count' <= `iter' {
	* in this section we assign the placebo treatments and run regressions using the placebo treatments
	replace simtreatment_uni = uniform()
	replace simtreatment = (simtreatment_uni>0.5)
	replace tstatsim = .
	replace pvalsim = .
	foreach lhsvar of numlist 1/`endvar' {
	    local depvar = varname[`lhsvar']
		`cmd' `depvar' simtreatment `varlist' `if' `in' , `options'
    	replace tstatsim = abs(_b[simtreatment]/_se[simtreatment]) in `lhsvar'
        replace pvalsim = 2*ttail(e(N),abs(tstatsim)) in `lhsvar'
    }
	* in this section we perform the "step down" procedure that replaces simulated p-vals with the minimum of the set of simulated p-vals associated with outcomes that had actual p-vals greater than or equal to the one being replaced.  For each outcome, we keep count of how many times the ultimate simulated p-val is less than the actual observed p-val.
    local countdown `endvar'
    while `countdown' >= 1 {
        replace pvalsim = min(pvalsim,pvalsim[_n+1]) in `countdown'
        local depvar = varname[`countdown']
        if pvalsim[`countdown'] <= act_pval[`countdown'] {
            local `depvar'_ct_0 = ``depvar'_ct_0' + 1
            dis "Counter `depvar': ``depvar'_ct_0'"
            }
        local countdown = `countdown' - 1
    	}
    local count = `count' + 1

}

foreach lhsvar of numlist 1/`endvar' {
	local thisdepvar =varname[`lhsvar']
    replace pvals = max(round(``thisdepvar'_ct_0'/`iter',.001), pvals[`lhsvar'-1]) in `lhsvar'
    }
} // quietly     
*return local mymean = `r(mean)'
} //quietly
	
end 
exit
