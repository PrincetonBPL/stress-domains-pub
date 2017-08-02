******************************************
***									   ***
*** COMMON POOL RESOURCE DATA CLEANING ***
***									   ***
******************************************
	* 7/18/2014 (CJ): Created
	* 4/07/2015 (JA): Compiled into master
	* 10/01/2015 (JA): Adapted to new folder structure; 21 sessions ran

******************
** Demographics **
******************

use "$data_dir/CPR_raw/demographics/CPR_Demographics.dta"

append using "$data_dir/CPR_raw/demographics/CPR150929_session1.dta" "$data_dir/CPR_raw/demographics/CPR150929_session2.dta" "$data_dir/CPR_raw/demographics/CPR150929_session3.dta" "$data_dir/CPR_raw/demographics/CPR150930_session4.dta" "$data_dir/CPR_raw/demographics/CPR_Demographics2", gen(append) force

replace identifydate = date("150929", "20YMD") if append > 0 & append < 4
replace identifydate = date("150930", "20YMD") if append == 4
replace identifydate = sessiondate if append == 5

replace sessionnumber = session if session == 3
replace sessionnumber = session_number if append == 5

replace busaranumber = 6 if identifydate == 20233 & sessionnumber == 4 & busaranumber == 4 & birthyear == 1970
replace busaranumber = busara_number if append == 5

replace kiberalocation = kibera_location if kiberalocation == ""

keep identify* *number birthyear gender education marital children subjectpool1 occupation* append

sort identifydate sessionnumber busaranumber
egen mid = group(identifydate sessionnumber busaranumber)

/* Clean demogaphics */

gen gender2 = 1
replace gender2 = 2 if gender == "Female"
drop gender
ren gender2 gender

encode education, gen(edu_temp)
recode edu_temp (3 = 17) (4 = 20) (5 = 25) (6 = 11) (7 = 12) (8 = 13) (9 = 14) (10 = 16) (11 = 20) (12 = 24) (13 = 17) (14 = 21) (15 = 6) (16 = 8) (17 = 9) (18 = 10) (20 = 23) (21 = 18) (22 = 23)
drop education
ren edu_temp education

encode marital, gen(mar_temp)
recode mar_temp (1 2 = 3) (3 4 = 2) (5 = 1)
drop marital
ren mar_temp marital

encode subjectpool1, gen(pool_temp)
recode pool_temp (1 = 3) (2 = 1) (3 = 2)
drop subjectpool1
ren pool_temp subjectpool1

encode occupation, gen(job_temp)
recode job_temp (1 = 4) (2 = 7) (3 23 = 9) (4 24 = 11) (5 = 23) (6 25 = 3) (7 37 = 14) (8 26 = 12) (9 27 = 1) (10 = 22) (11 = 15) (12 30 = 25) (13 = 2) (14 31 = 26) (16 32 = 17) (17 34 = 27) (18 35 = 28) (19 36 = 8) (20 = 4) (21 = 24) (22 = 7) (28 = 30) (29 = 10) (33 = 29)
drop occupation
ren job_temp occupation

drop append

tempfile demo
save `demo', replace

***************************
*** Combine Z-Tree Data ***
***************************

cd "$data_dir/CPR_raw/raw"

/* Append to local data sets to be analyzed */

loc zlist : dir "$data_dir/CPR_raw/raw" files "*.xls"
loc i = 1

foreach file in `zlist' {

	clear
	qui ztree2stata subjects using `file', except(TimePlot)
	gen sessionnum = `i'
	la variable sessionnum "Session"
	tempfile file`i'
	save `file`i'', replace
	loc ++i

}

use `file1', clear
loc j = `i' - 1

forvalues k = 2/`j' {
	append using `file`k''
	display "appended `k'"
}

*********************
*** Data Cleaning ***
*********************

** Merge ID's for demographics data

ren session sessionname
gen identifydate = date(substr(sessionname, 1, 6), "20YMD")
gen identifystart = StartTime
gen busaranumber = Subject

** Specify a groupID for the CPR game

egen sid = group(sessionnum Subject)
egen groupID = group(sessionnum Group) if TREATMENTID==8
egen groupid = max(groupID), by(sid)
order groupid groupID sid, after(Group)

** Create variable for treatment groups.  stress = 1 for 4 player, stress = 0 for 1 player **

egen stress = anymatch(sessionnum), values(4 5 6 9 12 13 16 17 19 22 24 25 28)
la variable stress "Treatment"
la define treat 0 "Control" 1 "Treated"
la value stress treat

** Create variable for regular and reverse games **

egen sessiontype = anymatch(sessionnum), values(7 8 9 10 11 12 13 15 18 19 21 24 26 28 29)
la variable sessiontype "Reversed"
la define rev 0 "Regular" 1 "Reversed"
la value sessiontype rev

egen treat = group(stress sessiontype)
la variable treat "Conditional treatment assignment"
la define contreat 1 "Control (Reg.)" 2 "Control (Rev.)" 3 "Treat (Reg.)" 4 "Treat (Rev.)"
la value treat contreat

gen stressXsessiontype = stress * sessiontype
la variable stressXsessiontype "Stress $\times$ Reversed"

** Fix Session 9 TREATMENTID **
replace TREATMENTID = 3 if sessionnum > 8 & treatment == 4
replace TREATMENTID = 5 if sessionnum > 8 & treatment == 6
replace TREATMENTID = 8 if sessionnum > 8 & treatment == 9

*************
* Clean VAS *
*************

* Key for VAS *
/*
	1 = Distressed
	2 = Upset
	3 = Guilty
	4 = Ashamed
	5 = Hostile
	6 = Irritable
	7 = Nervous
	8 = Jittery
	9 = Scared
	10 = Afraid
	11 = Frustrated
	12 = Stressed

*/

	forvalues i=1/12 {

		gen pre1_VAS`i' = response`i' if TREATMENTID== 1
		egen pre_VAS`i' = max(pre1_VAS`i'), by(sid)
		drop pre1_VAS`i'

		gen post1_VAS`i' = response`i' if TREATMENTID== 9
		egen post_VAS`i' = max(post1_VAS`i'), by(sid)
		drop post1_VAS`i'

	}

	gen mid1_VAS11 = response1 if TREATMENTID== 7
	replace mid1_VAS11 = response1 if TREATMENTID== 8 & (sessionnum == 4 | sessionnum == 19 | sessionnum == 24)
	egen mid_VAS11 = max(mid1_VAS11), by(sid)
	drop mid1_VAS11

	gen mid1_VAS2 = response2 if TREATMENTID== 7
	replace mid1_VAS2 = response2 if TREATMENTID== 8 & (sessionnum == 4 | sessionnum == 19 | sessionnum == 24)
	egen mid_VAS2 = max(mid1_VAS2), by(sid)
	drop mid1_VAS2

	gen mid1_VAS5 = response3 if TREATMENTID== 7
	replace mid1_VAS5 = response3 if TREATMENTID== 8 & (sessionnum == 4 | sessionnum == 19 | sessionnum == 24)
	egen mid_VAS5 = max(mid1_VAS5), by(sid)
	drop mid1_VAS5

	gen mid1_VAS6 = response4 if TREATMENTID== 7
	replace mid1_VAS6 = response4 if TREATMENTID== 8 & (sessionnum == 4 | sessionnum == 19 | sessionnum == 24)
	egen mid_VAS6 = max(mid1_VAS6), by(sid)
	drop mid1_VAS6

	gen mid1_VAS12 = response5 if TREATMENTID== 7
	replace mid1_VAS12 = response5 if TREATMENTID== 8 & (sessionnum == 4 | sessionnum == 19 | sessionnum == 24)
	egen mid_VAS12 = max(mid1_VAS12), by(sid)
	drop mid1_VAS12

*************************
* Clean Risk Preference *
*************************

egen risk = max(MPLChoice), by(sid)
la var risk "Risk"

gen crra = risk
recode crra (1=3.45971) (2=2.31018) (3=0.933116) (4=0.602097) (5=0.249306) (6=0)

***********************************
* Extract raw titration responses *
***********************************

tempfile main
save `main', replace

keep if TREATMENTID == 10 | TREATMENTID == 11
keep sid TREATMENTID SSAmt0m3m* Response0m3m* SSAmt0m6m* Response0m6m* SSAmt0m12m* Response0m12m* SSAmt6m12m* Response6m12m*

reshape wide SSAmt0m3m* Response0m3m* SSAmt0m6m* Response0m6m* SSAmt0m12m* Response0m12m* SSAmt6m12m* Response6m12m*, i(sid) j(TREATMENTID)

merge 1:m sid using `main'
drop _merge

forval i =1/6 {

	gen Response0m1m`i' = Response0m3m`i'10
	gen SSAmt0m1m`i' = SSAmt0m3m`i'10

	gen Response0m2m`i' = Response0m6m`i'10
	gen SSAmt0m2m`i' = SSAmt0m6m`i'10

	gen Response0m3m`i'_short = Response0m12m`i'10
	gen SSAmt0m3m`i'_short = SSAmt0m12m`i'10

	gen Response1m2m`i' = Response6m12m`i'10
	gen SSAmt1m2m`i' = SSAmt6m12m`i'10

	replace Response0m3m`i' = Response0m3m`i'11
	replace SSAmt0m3m`i' = SSAmt0m3m`i'11

	replace Response0m6m`i' = Response0m6m`i'11
	replace SSAmt0m6m`i' = SSAmt0m6m`i'11

	replace Response0m12m`i' = Response0m12m`i'11
	replace SSAmt0m12m`i' = SSAmt0m12m`i'11

	replace Response6m12m`i' = Response6m12m`i'11
	replace SSAmt6m12m`i' = SSAmt6m12m`i'11

	drop Response0m3m`i'1* SSAmt0m3m`i'1* Response0m6m`i'1* SSAmt0m6m`i'1* Response0m12m`i'1* SSAmt0m12m`i'1* Response6m12m`i'1* SSAmt6m12m`i'1*

}

tempfile main
save `main', replace

/* Game earnings data */

* time pressed each round
* points earned each round
* average time
* average points

keep if treatment == 7 | treatment == 9

gen temp_tp = treatment * 100 + Period

keep sid RT RoundProfit temp_tp

reshape wide RT RoundProfit, i(sid) j(temp_tp)

ren RT7* cpr_responsetime_1*
ren RoundProfit7* cpr_payoff_1*

ren RT9* cpr_responsetime_2*
ren RoundProfit9* cpr_payoff_2*

egen cpr_avgtime_1 = rmean(cpr_responsetime_1*)
egen cpr_avgtime_2 = rmean(cpr_responsetime_2*)
egen cpr_avgtime = rmean(cpr_responsetime*)
la var cpr_avgtime "Avg. response time (sec.)"

format cpr_*time* %9.0g

egen cpr_avgpay_1 = rmean(cpr_payoff_1*)
egen cpr_avgpay_2 = rmean(cpr_payoff_2*)
egen cpr_avgpay = rmean(cpr_payoff*)
la var cpr_avgpay "Avg. payoff"

keep sid cpr_*

merge 1:m sid using `main'
drop _merge

tempfile main
save `main', replace

/* Calculate titration endowment */

keep if treatment > 14 & PayAmt1 != .

gen cpr_randpay_1 = PayAmt1
la var cpr_randpay_1 "Randomly selected payoff (Round 1)"
gen cpr_randpay_2 = PayAmt2
la var cpr_randpay_2 "Randomly selected payoff (Round 2)"
gen cpr_randpay = cpr_randpay_1 + cpr_randpay_2

gen time_endowment = FlatPay + cpr_avgpay
la var time_endowment "Pre-titration endowment"

keep sid time_endowment cpr_randpay*

merge 1:m sid using `main'
drop _merge

tempfile main
save `main', replace

/* Grab questionnaire response */

keep if (TREATMENTID == 12 | TREATMENTID == 13) & response1 != .
keep sid response*

merge 1:m sid using `main'
drop _merge

duplicates drop sid, force // check this

/* Merge demographics */

sort identifydate identifystart

gen sessionnumber = 0

qui tab identifydate, matrow(datemat)
loc daterows = rowsof(datemat)

forval i = 1/`daterows' {

	qui tab sessionnum if identifydate == datemat[`i', 1], matrow(seshmat)
	loc seshrows = rowsof(seshmat)

	forval j = 1/`seshrows' {

		replace sessionnumber = `j' if sessionnum == seshmat[`j', 1]

	}

}

sort identifydate sessionnumber busaranumber
egen mid = group(identifydate sessionnumber busaranumber)

merge 1:1 mid using `demo'
drop if _merge == 2
drop _merge mid

drop if sessionnum == 19 | sessionnum == 24

qui compress
saveold "$data_dir/CPR_Cleaned.dta", replace
