** Title: ColdPressor_Clean
** Author: Justin Abraham
** Desc: Combines and cleans Z-Tree data from Cold Pressor experiment. Sourced from older script.
** Input: Bunch of excel files
** Output: ColdPressor_Cleaned_$stamp.dta

****************************
** Clean demographic data **
****************************

use "$data_dir/CPT_raw/demographics/_B04cptDemoData3.dta", clear

sort identifydate sessionnumber ztreeclient

replace sessionnumber = 1 if sessionnumber == .

* Fix June 8 to split into 2 sessions
replace sessionnumber = 2 if session==5 & identifystart >= clock("15:00:00", "hms")

* Fix July 11 to merge back a session
replace sessionnumber = 1 if session == 22 & sessionnumber ==2


egen session2 = group(session sessionnumber)
order session2, after(session)
drop session
rename session2 sessionnum

* Recreate ztree numbers
bysort sessionnum (busaranumber): gen ztreeclientnumber2 = _n

*egen maxnum = max(ztreeclientnumber2), by(sessionnum)
*order maxnum ztreeclientnumber2

drop ztreeclientnumber
rename ztreeclientnumber2 Subject
order Subject

save "$data_dir/CPT_raw/demographics/CleanedDemoData.dta", replace

***********************
** Merge Z-Tree data **
***********************

cd "$data_dir/CPT_raw"

forvalues i = 1/39 {
	clear
	ztree2stata subjects using `i'.xls
	gen sessionnum = `i'
	tempfile file`i'
	save `file`i'', replace
}

use `file1', clear
forvalues i = 2/39 {
	append using `file`i''
	display "appended `i'"
}

****************************
*** Create New Variables ***
****************************

	egen sid = group(session Subject)
	egen stress = max(control), by(sid)
	egen risk = max(MPLChoice), by(sid)
	egen bdprofit = max(BDProfit), by(sid)
	gen crazycheck1 = ChoseSS1 if TREATMENTID==3
	replace crazycheck1 = 1-crazycheck1
	egen crazy1 = max(crazycheck1), by(sid)
	gen crazycheck2 = ChoseSS2 if TREATMENTID==3
	egen crazy2 = max(crazycheck2), by(sid)

	ren session sessionname

	order sid sessionnum Subject stress watertemp1 risk crazy1 crazy2

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

	* Add treatment status for Session 10 & 11
	replace stress = 1 if sessionnum==10 & (Subject == 3 | Subject == 4)
	replace stress = 1 if sessionnum==11 & (Subject == 2 | Subject == 3 | Subject == 7)

	*** Clean VAS ***
	forvalues i=1/12 {
		gen pre1_VAS`i' = response`i' if TREATMENTID== 1
		egen pre_VAS`i' = max(pre1_VAS`i'), by(sid)
		drop pre1_VAS`i'
		gen post1_VAS`i' = response`i' if TREATMENTID== 9
		egen post_VAS`i' = max(post1_VAS`i'), by(sid)
		drop post1_VAS`i'
	}

	gen mid1_VAS11 = response1 if TREATMENTID== 4
	egen mid_VAS11 = max(mid1_VAS11), by(sid)
	drop mid1_VAS11

	gen mid1_VAS12 = response2 if TREATMENTID== 4
	egen mid_VAS12 = max(mid1_VAS12), by(sid)
	drop mid1_VAS12

	gen diff1_VAS11 = post_VAS11 - pre_VAS11
	gen diff1_VAS12 = post_VAS12 - pre_VAS12

	gen diff2_VAS11 = mid_VAS11 - pre_VAS11
	gen diff2_VAS12 = mid_VAS12 - pre_VAS12

	gen diff3_VAS11 = post_VAS11 - mid_VAS11
	gen diff3_VAS12 = post_VAS12 - mid_VAS12

	egen pre_VAS = rowtotal(pre_VAS*)
	egen post_VAS = rowtotal(post_VAS*)
	gen diff_VAS = post_VAS - pre_VAS

	* Create 10-item Panas
	gen panas1 = pre_VAS - pre_VAS11 - pre_VAS12
	gen panas3 = post_VAS - post_VAS11 - post_VAS12
	gen panasdiff = panas3 - panas1

	* Create 2-item Stress + Pain
	gen panas1_small = pre_VAS11 + pre_VAS12
	gen panas2_small = mid_VAS11 + mid_VAS12
	gen panas3_small = post_VAS11 + post_VAS12
	gen panasdiff21 = panas2_small - panas1_small
	gen panasdiff32 = panas3_small - panas2_small
	gen panasdiff31 = panas3_small - panas1_small

	*** Clean Small TP ***

	forvalues i=1/9 {
		gen TP_response`i' = 1 if finalchoice`i' < 120
		replace TP_response`i' = 0 if finalchoice`i' >120 & finalchoice`i' != .
	}

	egen TPfract1 = rowmean(TP_response1 TP_response2 TP_response3)
	egen TPfract2 = rowmean(TP_response4 TP_response5 TP_response6)
	egen TPfract3 = rowmean(TP_response7 TP_response8 TP_response9)

	egen fractTP1 = max(TPfract1), by(sid)
	egen fractTP2 = max(TPfract2), by(sid)
	egen fractTP3 = max(TPfract3), by(sid)

	replace fractTP1 = 1-fractTP1
	replace fractTP2 = 1-fractTP2
	replace fractTP3 = 1-fractTP3

	*Switching behavior

	gen TP1_switch1 = 1 if TP_response1 != TP_response2
	gen TP1_switch2 = 1 if TP_response2 != TP_response3
	egen numswitchTP1 = rowtotal(TP1_switch1 TP1_switch2)

	gen TP2_switch1 = 1 if TP_response4 != TP_response5
	gen TP2_switch2 = 1 if TP_response5 != TP_response6
	egen numswitchTP2 = rowtotal(TP2_switch1 TP2_switch2)

	gen TP3_switch1 = 1 if TP_response7 != TP_response8
	gen TP3_switch2 = 1 if TP_response8 != TP_response9
	egen numswitchTP3 = rowtotal(TP3_switch1 TP3_switch2)

	egen TPnumswitch1 = max(numswitchTP1), by(sid)
	egen TPnumswitch2 = max(numswitchTP2), by(sid)
	egen TPnumswitch3 = max(numswitchTP3), by(sid)

	gen TPsuperconsistent = 1 if numswitchTP1 == 1 & numswitchTP2 == 1 & numswitchTP3 ==1
	replace TPsuperconsistent = 0 if TPsuperconsistent==.

	egen superconsistentTP = max(TPsuperconsistent), by(sid)

	** Pre-titration endowment **

	tempfile main
	save `main', replace

	keep if treatment > 10

	gen pay_temp = nowprofit - MPLProfit - BDProfit

	egen time_endowment = max(pay_temp), by(sid)
	la var time_endowment "Pre-titration endowment" // No show-up or bonus fee

	keep sid time_endowment

	duplicates drop sid, force

	merge 1:m sid using `main'
	drop _merge

	***********************
	*** Clean Titration ***
	***********************

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

	egen fractmean = rowmean(fract1-fract6)

	** Generate Consistency Checks **
	gen cons1 = 1 if Response0m3m1==Response0m3m6
	gen cons2 = 1 if Response0m6m1==Response0m6m6
	gen cons3 = 1 if Response0m9m1==Response0m9m6
	gen cons4 = 1 if Response0m12m1==Response0m12m6
	gen cons5 = 1 if Response6m9m1==Response6m9m6
	gen cons6 = 1 if Response6m12m1==Response6m12m6

	******************
	*** Clean Risk ***
	******************
	/*
	1) 28 vs. 28
	2) 24 vs. 36
	3) 20 vs. 44
	4) 16 vs. 52
	5) 12 vs. 60
	6)  2 vs. 70

	1) r= 3.45971
	2) r= 1.16065
	3) r= 0.705582
	4) r= 0.498612
	5) r= 0

	Implied CRRA Range
	1) 3.45971<r
	2) 1.16065< r < 3.45971
	3) 0.705582< r <1.16065
	4) 0.498612< r <0.705582
	5) 0< r <0.498612
	6) r < 0

	Values used (midpoints except for extremes)
	1) 3.45971
	2) 2.31018
	3) 0.933116
	4) 0.602097
	5) 0.249306
	6) 0
	*/
	gen crra = risk
	recode crra (1=3.45971) (2=2.31018) (3=0.933116) (4=0.602097) (5=0.249306) (6=0)


	** Save Questionnaire **
	forvalues i = 1/13{
		gen aquest_re`i' = .
		replace aquest_re`i' = response`i' if TREATMENTID == 10
		egen quest_re`i' = max(aquest_re`i'), by(sid)
		drop aquest_re`i'
	}

	drop response*
	ren quest_re* response*

	drop BMI
	gen BMI = response2/[(response1/100)^2]

keep if fract6!=.

****************************
***  Merge in Demo Data  ***
****************************

merge 1:1 sessionnum Subject using "$data_dir/CPT_raw/demographics/CleanedDemoData.dta"
drop _merge
gen age = 2013-birthyear

	* Drop empty variables again
	ds, not(type string)
	foreach varname of varlist `r(varlist)' {
	 quietly sum `varname'
	 if `r(N)'==0 {
	  drop `varname'
	 }
	}


saveold "$data_dir/CPT_Cleaned.dta", replace

*****************
***  Reshape  ***
*****************
{
	* Keep Necessary Variables and Reshape *
* 	keep sid sessionnum Subject auc stress indiff* hdelta* delta* decreaseimpatience ///
* 	departure fract* risk cons* fractTP* TPnumswitch* superconsistentTP ///
* 	diff_VAS diff*_VAS* pre_VAS post_VAS bdprofit crazy* crra fractmean ///
* 	quest_re1-age sessionname

* 	reshape long indiff delta hdelta fract cons, i(sid) j(type)

* save "$data_dir/CPT/CPT_CleanedPanel_$stamp.dta", replace
}
