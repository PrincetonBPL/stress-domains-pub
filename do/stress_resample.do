** Title: Stress_Resample
** Author: Justin Abraham
** Desc: Re-sample each experiment for adjusted standard errors
** Input: Stress_FinalTime.dta
** Output: Re_sampled dataset

use "$data_dir/Stress_FinalTime.dta", clear

tempfile main
save `main', replace

***********************
** Oversampling TSST **
***********************

qui tab sessionnum if exp_cpr
loc sessions = `r(r)'

forval i = 1/`sessions' {

	bsample 1 if exp_tsst, cluster(sessionnum)
	replace sessionnum = `i'

	tempfile tsst_bs`i'
	save `tsst_bs`i'', replace

	use `main', clear

}

use `tsst_bs1', clear

forval i = 2/`sessions' {

	append using `tsst_bs`i''

}

tempfile tsst_bs
save `tsst_bs', replace

***********************
** Oversampling CPT **
***********************

use `main', clear

qui tab sessionnum if exp_cpr
loc sessions = `r(r)'

forval i = 1/`sessions' {

	bsample 1 if exp_cpt, cluster(sessionnum)
	replace sessionnum = `i'

	tempfile cpt_bs`i'
	save `cpt_bs`i'', replace

	use `main', clear

}

use `cpt_bs1', clear

forval i = 2/`sessions' {

	append using `cpt_bs`i''

}

tempfile cpt_bs
save `cpt_bs', replace

***********************
** Subsampling CENT **
***********************

use `main', clear

qui tab sessionnum if exp_tsst
loc sessions = `r(r)'

forval i = 1/`sessions' {

	bsample 1 if exp_cpr, cluster(sessionnum)
	replace sessionnum = `i'

	tempfile cpr_bs`i'
	save `cpr_bs`i'', replace

	use `main', clear

}

use `cpr_bs1', clear

forval i = 2/`sessions' {

	append using `cpr_bs`i''

}

append using `tsst_bs' `cpt_bs'

egen sesh_temp = group(experiment sessionnum)
replace sessionnum = sesh_temp
drop sesh_temp

save "$data_dir/Stress_Resampled.dta", replace
