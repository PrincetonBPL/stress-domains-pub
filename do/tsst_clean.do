** Title: TSST_Clean
** Author: Justin Abraham
** Desc: Combines and cleans Z-Tree data from TSST experiment. Sourced from older script.
** Input: Bunch of excel files
** Output: TSST_Cleaned_$stamp.dta
** Notes: Code for importing 2012 data has been omitted

********************
*** Combine Data ***
********************

* local files : dir "$data_dir/TSST_raw/2012" files "*.xls"
* local i = 1

* cd "$data_dir/TSST_raw/2012"

* foreach file in `files' {
* 	clear
* 	ztree2stata subjects using `file'
* 	gen sessionnum = `i'
* 	tempfile file`i'
* 	save `file`i'', replace
* 	local i = `i' + 1
* }

* local i = `i' - 1
* use `file1', clear
* forvalues j = 2/`i' {
* 	append using `file`j''
* 	display "appended `j'"
* }
* save "$data_dir/TSST_raw/rawsessions2012.dta", replace

local files : dir "$data_dir/TSST_raw/2013" files "*.xls"
local i = 1

cd "$data_dir/TSST_raw/2013"

foreach file in `files' {
	clear
	ztree2stata subjects using `file'
	gen sessionnum = `i'
	tempfile file`i'
	save `file`i'', replace
	local i = `i' + 1
}

local i = `i' - 1
use `file1', clear
forvalues j = 2/`i' {
	append using `file`j''
	display "appended `j'"
}

replace sessionnum = sessionnum + 17
gen year = 2013

* append using "$data_dir/TSST_raw/rawsessions2012.dta", force
* replace year = 2012 if year == .

tempfile subjects
save `subjects', replace

** Obtain sessions table **

local files : dir "$data_dir/TSST_raw/2013" files "*.xls"
local i = 1

cd "$data_dir/TSST_raw/2013"

foreach file in `files' {
	clear
	ztree2stata session using `file'
	gen sessionnum = `i'
	tempfile sfile`i'
	save `sfile`i'', replace
	local i = `i' + 1
}

local i = `i' - 1
use `sfile1', clear
forvalues j = 2/`i' {
	append using `sfile`j''
	display "appended `j'"
}

tempfile session
save `session', replace

****************
** Clean data **
****************

use `subjects'

merge m:1 sessionnum Subject treatment using `session'
drop _merge

order sessionnum
egen sid = group(sessionnum Subject)

* Drop pilot sessions
drop if sessionnum < 3

* Mark treatment and control
gen stress = 1
replace stress = 0 if sessionnum == 28 | sessionnum == 30 | sessionnum == 31 ///
| sessionnum == 12 | sessionnum == 13 | sessionnum == 16 | sessionnum == 17

* Drop empty variables
ds, not(type string)
foreach varname of varlist `r(varlist)' {
 quietly sum `varname'
 if `r(N)'==0 {
  drop `varname'
 }
}

* Drop time variables
drop RT* TimeOK* TimePlot*

tempfile main
save `main'

** Grab Experiential **
keep if TREATMENTID==5 & treatment >6
gen riskratio = boxchoice / NumBoxes
keep sid Period boxchoice NumBoxes riskratio
reshape wide boxchoice NumBoxes riskratio, i(sid) j(Period)

merge 1:m sid using `main'
drop _merge*

** Grab pre-titration endowment **

tempfile main
save `main'

keep if treatment == 8
keep sid FinalProfit

gen time_endowment = FinalProfit + 200
la var time_endowment "Pre-titration endowment"

merge 1:m sid using `main'
drop _merge

***********************
***    Clean VAS    ***
***********************

forvalues i=1/11 {
		gen pre1_VAS`i' = response`i' if TREATMENTID== 1 & treatment == 2
		egen pre_VAS`i' = max(pre1_VAS`i'), by(sid)
		drop pre1_VAS`i'
		gen post1_VAS`i' = response`i' if TREATMENTID== 1 & treatment == 8
		egen post_VAS`i' = max(post1_VAS`i'), by(sid)
		drop post1_VAS`i'
	}

forvalues i=1/11{
	gen diff_VAS`i' = post_VAS`i' - pre_VAS`i'
}
egen totdiff = rowtotal(diff_VAS*)
egen prevas = rowtotal(pre_VAS*)
egen postvas = rowtotal(post_VAS*)

***********************
*** Clean Titration ***
***********************

** Fix session 18 overwrite **

* forval i = 1/6 {

* 	replace SSAmt6m12m`i' = SSAmt`i' if sessionnum == 18

* }

drop if SSAmt6m12m1 & sessionnum == 18 // Just drop them

** Generate Indifference Points **
gen indiff1 = SSAmt0m3m5 - abs(SSAmt0m3m5-SSAmt0m3m4)/2 if Response0m3m5==1
replace indiff1 = SSAmt0m3m5 + abs(SSAmt0m3m5-SSAmt0m3m4)/2 if Response0m3m5==0

gen indiff2 = SSAmt0m6m5 - abs(SSAmt0m6m5-SSAmt0m6m4)/2 if Response0m6m5==1
replace indiff2 = SSAmt0m6m5 + abs(SSAmt0m6m5-SSAmt0m6m4)/2 if Response0m6m5==0

gen indiff3 = SSAmt0m9m5 - abs(SSAmt0m9m5-SSAmt0m9m4)/2 if Response0m9m5==1
replace indiff3 = SSAmt0m9m5 + abs(SSAmt0m9m5-SSAmt0m9m4)/2 if Response0m9m5==0

gen indiff4 = SSAmt0m12m5 - abs(SSAmt0m12m5-SSAmt0m12m4)/2 if Response0m12m5==1
replace indiff4 = SSAmt0m12m5 + abs(SSAmt0m12m5-SSAmt0m12m4)/2 if Response0m12m5==0

gen indiff5 = SSAmt6m9m5 - abs(SSAmt6m9m5-SSAmt6m9m4)/2 if Response6m9m5==1
replace indiff5 = SSAmt6m9m5 + abs(SSAmt6m9m5-SSAmt6m9m4)/2 if Response6m9m5==0

gen indiff6 = SSAmt6m12m5 - abs(SSAmt6m12m5-SSAmt6m12m4)/2 if Response6m12m5==1
replace indiff6 = SSAmt6m12m5 + abs(SSAmt6m12m5-SSAmt6m12m4)/2 if Response6m12m5==0

** Generate Area under the Curve **
	*Use trapezoid formula h*(b1+b2/2)

gen auc = 0.25*(200+indiff1)/2 + 0.25*(indiff1+indiff2)/2 + 0.25*(indiff2+indiff3)/2 + 0.25*(indiff3+indiff4)/2

** Generate Exponential Discount Rates **
gen delta1 = -ln(indiff1/200)/.25
gen delta2 = -ln(indiff2/200)/.5
gen delta3 = -ln(indiff3/200)/.75
gen delta4 = -ln(indiff4/200)
gen delta5 = -ln(indiff5/200)/.25
gen delta6 = -ln(indiff6/200)/.5

** Generate Hyperbolic Discount Rates **
gen hdelta1 = (200/indiff1 - 1)/0.25
gen hdelta2 = (200/indiff2 - 1)/0.5
gen hdelta3 = (200/indiff3 - 1)/0.75
gen hdelta4 = (200/indiff4 - 1)
gen hdelta5 = (200/indiff5 - 1)/0.25
gen hdelta6 = (200/indiff6 - 1)/0.5

** Index for Decreasing Impatience **
gen decreaseimpatience = delta2-delta4
gen decreaseimpatience2 = delta1-delta2

gen hdecreaseimpatience = hdelta2-hdelta4
gen hdecreaseimpatience2 = hdelta1-hdelta2

** Index for Departure from Stationarity **
gen departure = delta2-delta6
gen departure2 = delta1-delta5

gen hdeparture = hdelta2-hdelta6
gen hdeparture2 = hdelta1-hdelta5


** Generate fraction of patient responses **
egen fract1 = rowmean(Response0m3m*)
egen fract2 = rowmean(Response0m6m*)
egen fract3 = rowmean(Response0m9m*)
egen fract4 = rowmean(Response0m12m*)
egen fract5 = rowmean(Response6m9m*)
egen fract6 = rowmean(Response6m12m*)

replace fract1 = 1-fract1
replace fract2 = 1-fract2
replace fract3 = 1-fract3
replace fract4 = 1-fract4
replace fract5 = 1-fract5
replace fract6 = 1-fract6

** Grab questionnaire responses **
tempfile main
save `main'

keep if TREATMENTID == 7
keep sid response*

tempfile quest
save `quest'

use `main'
drop response? response??

merge m:1 sid using `quest'

* keep if fract6!=.
keep if treatment == 9

******************************
*** Merge Demographic Data ***
******************************
rename session session2
rename Subject ztreeclientnumber
rename sessionnum session

merge 1:1 ztreeclientnumber session using "$data_dir/TSST_raw/Demographics_B03tsst.dta", gen(_merge2)
keep if _merge2 == 3
rename session sessionnum
rename ztreeclientnumber Subject
rename session2 session
gen age = 2013 - birthyear
gen married = 0
replace married = 1 if marital == 2

****************************
** Harmonizing for append **
****************************

* Post to midline for PANAS and stress

ren post_* mid_*

* This is self-reported stress
ren pre_VAS11 pre_VAS12
ren mid_VAS11 mid_VAS12

drop _merge*
replace sid = sid - 8
ren session sessionname

saveold "$data_dir/TSST_Cleaned.dta", replace
