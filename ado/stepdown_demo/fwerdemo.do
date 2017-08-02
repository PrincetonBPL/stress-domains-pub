myclean 

/*use jhdata_ind.dta, clear
keep hap1 sat1 treat spillover surveyid
*keep if hap1 ~=.
keep in 1/1000
set seed 523654
replace sat1 = rnormal(0)
replace spillover = rnormal()
replace surveyid = runiform()
replace treat = 0
replace treat = 1 if _n>500
replace hap1 = rnormal(0)
replace hap1 = rnormal(0.5) if treat==1

stepdown reg (hap1 sat1) treat spillover, options(r cluster(surveyid)) iter(100) 
*/

clear
set obs 1000
set seed 523654
gen sat1 = rnormal(0)
gen spillover = rnormal()
gen surveyid = runiform()
gen treat = 0
replace treat = 1 if _n>500
gen hap1 = rnormal(0)
replace hap1 = rnormal(0.5) if treat==1

*stepdown reg (hap1 sat1) treat, iter(10)
*stepdown reg (hap1 sat1) treat spillover, iter(10)
stepdown_old reg (hap1 sat1) treat, options(r cluster(surveyid)) iter(500)
*stepdown reg (hap1 sat1) treat spillover, options(r cluster(surveyid)) iter(10)
