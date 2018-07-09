** Title: Stress_append
** Author: Justin Abraham
** Desc: Harmonizes and appends all experiments
** Input: Cleaned experiments .dta
** Output: Stress_Final.dta

*********************
** Append datasets **
*********************

use "$data_dir/TSST_Cleaned.dta", clear
append using "$data_dir/CPT_Cleaned.dta" "$data_dir/CPR_Cleaned.dta", gen(experiment) force

la var experiment "Experiment"
replace experiment = 3 if experiment == 2

la def la_exp 0 "TSST-G" 1 "CPT" 2 "Productivity" 3 "CENT"
la val experiment la_exp

gen exp_tsst = experiment == 0
la var exp_tsst "TSST-G"

gen exp_cpt = experiment == 1
la var exp_cpt "CPT"

gen exp_prod = experiment == 2
la var exp_prod "Productivity"

gen exp_cpr = experiment == 3
la var exp_cpr "CENT"

*************************
** Clean combined data **
*************************

ren Subject subject
la var subject "Subject"

sort experiment sessionnum subject

egen sesh_temp = group(experiment sessionnum)
replace sessionnum = sesh_temp
la var sessionnum "Session"
drop sesh_temp

egen id_temp = group(sessionnum subject)
replace sid = id_temp
la var sid "Survey ID"
drop id_temp

ren busaranumber computernum
la var computernum "Computer no."

la var sessionname "Session name"

drop treatment treat
ren stress treatment
la var treatment "Treatment"
la def la_treat 0 "Control" 1 "Treatment"
la val treatment la_treat

replace control = 1 - treatment
la var control "Control"

gen stress_tsst = exp_tsst & treatment
la var stress_tsst "TSST-G"

gen stress_cpt = exp_cpt & treatment
la var stress_cpt "Cold Pressor"

gen stress_cpr = exp_prod & exp_cpr & treatment
la var stress_cpr "Centipede Game"

gen stress_regcpr = stress_cpr & sessiontype
la var stress_cpr "Regular Centipede Game"

gen stress_revcpr = stress_cpr & ~sessiontype
la var stress_cpr "Reversed Centipede Game"

gen sessiondate = date(substr(sessionname, 1, 6), "20YMD")
format sessiondate %tdDDMonCCYY
la var sessiondate "Session date"

ren subjectpool1 subjectpool
replace subjectpool = subjectpool - 1
la var subjectpool "Subject pool"
la def la_subjectpool 0 "Kibera" 1 "Viwandani" 2 "Kawangware"
la val subjectpool la_subjectpool

qui tab subjectpool, gen(area)

ren area1 kibera
la var kibera "Kibera"
ren area2 viwandani
la var viwandani "Viwandani"
ren area3 kawangware
la var kawangware "Kawangware"

******************
** Demographics **
******************

format birthyear %tdCCYY

qui sum birthyear, d
gen underage25 = birthyear > `r(p50)'
la var underage25 "Born after `r(p50)'"

drop age
gen age = year(sessiondate) - birthyear
la var age "Age"

replace gender = 0
la def la_gender 0 "Male" 1 "Female"
la var gender "Gender"

la var marital "Marital status"

drop married
gen married = marital == 2
la var married "Married or co-habitating"

gen std_school = education > 9
la var std_school "Completed std. 8"

gen unemployed = occupation == 27 | occupation == 28
la var unemployed "Unemployed"

*******************
** Questionnaire **
*******************

ren response* quest_response*

la var quest_response1 "Height (cm)"
replace quest_response1 = . if quest_response1 > 210 | quest_response1 < 100

la var quest_response2 "Weight (kg)"
replace quest_response2 = . if quest_response2 > 100 | quest_response2 < 30

la var quest_response3 "No. of siblings"
replace quest_response3 = . if quest_response3 < 0 | quest_response3 > 20

la var quest_response4 "Monthly income"
replace quest_response4 = . if quest_response4 < 0

la var quest_response5 "Disposable income"
replace quest_response5 = . if quest_response5 < 0

la var quest_response6 "No. of dependants"
replace quest_response6 = . if quest_response6 < 0

la var quest_response7 "Dependant"
replace quest_response7 = 2 - quest_response7

la var quest_response8 "Employed"
replace quest_response8 = 2 - quest_response8

la var quest_response9 "Indebted"
replace quest_response9 = 2 - quest_response9

la var quest_response10 "Smoking"
replace quest_response10 = 2 - quest_response10

la var quest_response11 "Alcohol, tea, or coffee"
replace quest_response11 = 2 - quest_response11

la var quest_response12 "Waking time"
la var quest_response13 "Trust Busara payments"

gen quest_bmi = quest_response2 / ((quest_response1 / 100)^2)
la var quest_bmi "Body mass index"

foreach v in quest_response4 quest_response5 {
	if $USDconvertflag replace `v' = `v' * $ppprate
	gen ln`v' = ln(`v')
	loc varlabel lower("`: var la `v''")
	la var ln`v' "Log `label'"
}

*********************
** Negative affect **
*********************

drop pre_VAS post_VAS

ren pre_VAS12 pre_stress
la var pre_stress "Self-reported stress"
ren mid_VAS12 mid_stress
la var mid_stress "Self-reported stress"
ren post_VAS12 post_stress
la var post_stress "Self-reported stress"

ren pre_VAS11 pre_frust
la var pre_frust "Frustration"
ren mid_VAS11 mid_frust
la var mid_frust "Frustration"
ren post_VAS11 post_frust
la var post_frust "Frustration"

gen pre_pain = pre_frust if exp_cpt
la var pre_pain "Pain"
gen mid_pain = mid_frust if exp_cpt
la var mid_pain "Pain"
gen post_pain = post_frust if exp_cpt
la var post_pain "Pain"

replace pre_frust = . if exp_cpt
replace mid_frust = . if exp_cpt
replace post_frust = . if exp_cpt

ren *_VAS* *_NAS*

foreach v of varlist *_frust *_stress *_NAS* {

	egen `v'_z = weightave(`v'), normby(control)
	loc varlabel = lower("`: var la `v''")
	la var `v'_z "`varlabel' (SD)"

}

egen pre_NAStot_z = rowmean(pre_NAS*_z)
la var pre_NAStot_z "Negative affect (SD)"

egen mid_NAStot_z = rowmean(mid_NAS*_z)
la var mid_NAStot_z "Negative affect (SD)"

egen post_NAStot_z = rowmean(post_NAS*_z)
la var post_NAStot_z "Negative affect (SD)"

gen pre_stress_r = .
la var pre_stress_r "Self-reported stress (SD)"

gen mid_stress_r = .
la var mid_stress_r "Self-reported stress (SD)"

gen post_stress_r = .
la var post_stress_r "Self-reported stress (SD)"

forval i = 1/10 {

	gen pre_NAS`i'_r = .
	gen mid_NAS`i'_r = .
	gen post_NAS`i'_r = .

}

foreach exp in exp_tsst exp_cpt exp_cpr {

	gen control_`exp' = control & `exp'

		foreach prefix in pre mid post {

			cap noi: egen `prefix'_stress_`exp' = weightave(`prefix'_stress) if `exp', normby(control_`exp')
			if _rc gen `prefix'_stress_`exp' = .

			forval i = 1/10 {

				cap noi: egen `prefix'_NAS`i'_`exp' = weightave(`prefix'_NAS`i') if `exp', normby(control_`exp')
				if _rc gen `prefix'_NAS`i'_`exp' = .

			}

		}

	forval i = 1/10 {

		replace pre_NAS`i'_r = pre_NAS`i'_`exp' if `exp'
		replace mid_NAS`i'_r  = mid_NAS`i'_`exp' if `exp'
		replace post_NAS`i'_r = post_NAS`i'_`exp' if `exp'

	}

	replace pre_stress_r = pre_stress_`exp' if `exp'
	replace mid_stress_r  = mid_stress_`exp' if `exp'
	replace post_stress_r = post_stress_`exp' if `exp'

}


	egen pre_NAStot_r = rowmean(pre_NAS1_r-pre_NAS10_r)
	la var pre_NAStot_r "Negative affect (SD)"

	egen mid_NAStot_r  = rowmean(mid_NAS1_r-mid_NAS10_r)
	la var mid_NAStot_r "Negative affect (SD)"

	egen post_NAStot_r = rowmean(post_NAS1_r-post_NAS10_r)
	la var post_NAStot_r "Negative affect (SD)"

**********************
** Risk preferences **
**********************

ren risk risk_category
egen risk_category_z = weightave(risk_category), normby(control)

ren crra risk_crra
la var risk_crra "Coefficient of relative risk aversion"

egen risk_avgboxes = rowmean(boxchoice?)
la var risk_avgboxes "Avg. no. of boxes opened"

egen risk_avgratio = rowmean(riskratio*)
la var risk_avgratio "Avg. risk ratio"

egen risk_ratio_z = weightave(riskratio*), normby(control)
la var risk_ratio_z "Std. risk ratio"

ren riskratio* risk_ratio*

**********************
** Time preferences **
**********************

* Root describes variable for option i = 1-6
* Suffix indicates time horizon in months

forval i = 1/6 {

	ren SSAmt0m1m`i' time_SSamount`i'_0m1m
	ren SSAmt0m2m`i' time_SSamount`i'_0m2m
	ren SSAmt0m3m`i' time_SSamount`i'_0m3m
	ren SSAmt0m6m`i' time_SSamount`i'_0m6m
	ren SSAmt0m9m`i' time_SSamount`i'_0m9m
	ren SSAmt0m12m`i' time_SSamount`i'_0m12m
	ren SSAmt1m2m`i' time_SSamount`i'_1m2m
	ren SSAmt6m9m`i' time_SSamount`i'_6m9m
	ren SSAmt6m12m`i' time_SSamount`i'_6m12m

	ren Response0m1m`i' time_response`i'_0m1m
	ren Response0m2m`i' time_response`i'_0m2m
	ren Response0m3m`i' time_response`i'_0m3m
	ren Response0m6m`i' time_response`i'_0m6m
	ren Response0m9m`i' time_response`i'_0m9m
	ren Response0m12m`i' time_response`i'_0m12m
	ren Response1m2m`i' time_response`i'_1m2m
	ren Response6m9m`i' time_response`i'_6m9m
	ren Response6m12m`i' time_response`i'_6m12m

}

** Larger, later amount is different across experiments **

gen time_LLamount = 200
replace time_LLamount = 1000 if exp_cpr == 1
la var time_LLamount "Later, larger amt."

** PPP conversion of monetary values **

foreach v of varlist *amount* time_endowment *pay* {

	if $USDconvertflag replace `v' = `v' * $ppprate

}

** Loop over questions and time delays **

loc i = 1

foreach delay in 0m1m 0m2m 0m3m 0m6m 0m9m 0m12m 1m2m 6m9m 6m12m {

	forval j = 1/6 {

		ren time_SSamount`j'_`delay' time_SSamount`j'_`i'
		la var time_SSamount`j'_`i' "Shorter, sooner amt."

		ren time_response`j'_`delay' time_response`j'_`i'
		la var time_response`j'_`i' "Choose SS amt."

	}

	loc t0 = real(substr("`delay'", 1, 1))
	loc t = real(substr("`delay'", 3, length("`delay'") - 3))

	** Check data quality **

	gen time_measured_`i' = time_response1_`i' != .
	la var time_measured_`i' "Observed time horizon"

	gen time_consistent_`i' = time_response1_`i' == time_response6_`i'
	la var time_consistent_`i' "Consistency"

	drop time_response6_`i' time_SSamount6_`i' // Since this is identical to choice 1

	** Delay-specific variables **

	egen time_frac_`i' = rowmean(time_response*_`i')
	replace time_frac_`i' = 1 - time_frac_`i'
	la var time_frac_`i' "Avg. patient choice"

	gen time_indiffraw_`i' = time_SSamount5_`i' - abs(time_SSamount5_`i' - time_SSamount4_`i') / 2 if time_response5_`i' == 1
	replace time_indiffraw_`i' = time_SSamount5_`i' + abs(time_SSamount5_`i' - time_SSamount4_`i') / 2 if time_response5_`i' == 0
	la var time_indiffraw_`i' "Indifference point (raw)"

	gen time_indiff_`i' = time_indiffraw_`i' / time_LLamount
	la var time_indiff_`i' "Indifference point"

	gen time_exponential_`i' = -ln(time_indiff_`i'/time_LLamount)/(`t'-`t0'/12)
	la var time_exponential_`i' "Exp. discount factor"

	gen time_hyperbolic_`i' = (time_LLamount/time_indiff_`i' - 1)/(`t'-`t0'/12)
	la var time_hyperbolic_`i' "Hyp. discount factor"

	** Top-code geometric df for outliers **

	gen time_georaw_`i' = (time_indiffraw_`i'/time_LLamount)^-(12/`t'-`t0') - 1

	winsor time_georaw_`i', p(0.05) highonly gen(time_geometric_`i')
	la var time_geometric_`i' "Geo. discount factor"

	loc ++i

}

** Area under the curve **

gen time_auc = (3/12)*((time_LLamount + time_indiff_3) / 2) + (3/12)*((time_indiff_3 + time_indiff_4) / 2) + (3/12)*((time_indiff_4 + time_indiff_5) / 2) + (3/12)*((time_indiff_5 + time_indiff_6) / 2) if exp_tsst == 1 | exp_cpt == 1

replace time_auc = (1/12)*((time_LLamount + time_indiff_1) / 2) + (1/12)*((time_indiff_1 + time_indiff_2) / 2) + (1/12)*((time_indiff_2 + time_indiff_3) / 2) + (3/12)*((time_indiff_3 + time_indiff_4) / 2) + (6/12)*((time_indiff_4 + time_indiff_6) / 2) if exp_cpr == 1

la var time_auc "Area under the curve"

** Individual-level variables **

egen time_avgindiff = rowmean(time_indiff_?)
la var time_avgindiff "Avg. indifference point"

egen time_avgfrac = rowmean(time_frac_?)
la var time_avgfrac "Prop. of patient choice"

egen time_avggeometric = rowmean(time_geometric_?)
la var time_avggeometric "Avg. geometric discounting"

egen time_avgexponential = rowmean(time_exponential_?)
la var time_avgexponential "Avg. exponential decay"

egen time_avghyperbolic = rowmean(time_hyperbolic_?)
la var time_avghyperbolic "Avg. hyperbolic decay"

gen time_stationarity = time_exponential_9 - time_exponential_6
la var time_stationarity "Dept. from stationarity"

gen time_decrimp1 = time_exponential_7 - time_exponential_1
gen time_decrimp3 = time_exponential_8 - time_exponential_3
gen time_decrimp6 = time_exponential_9 - time_exponential_4

egen time_decrimp = rowmean(time_decrimp?)
la var time_decrimp "Decreasing impatience"

***********************
** Save wide dataset **
***********************

loc varlist "sid experiment sessionname sessionnum sessiondate sessiontype subject treatment control exp_* stress_* subjectpool kibera viwandani kawangware"

order `varlist' age married children std_school unemployed incomestream subjectpool kibera viwandani kawangware *quest_* pre_* mid_* post_* time_* cpr_* risk_*, first
keep `varlist' age married children std_school unemployed incomestream subjectpool kibera viwandani kawangware *quest_* pre_* mid_* post_* time_* cpr_* risk_*

foreach v of varlist age married children std_school unemployed incomestream kibera viwandani kawangware *quest_* pre_* time_endowment {

	gen `v'_miss = mi(`v')
	gen `v'_full = `v' if ~mi(`v')
	replace `v'_full = 0 if mi(`v')

}

keep if ~mi(time_avgindiff) // Keep only analytic sample

saveold "$data_dir/Stress_FinalWide.dta", replace

***************************
** Panel reshape for NAS **
***************************

reshape long pre_NAS mid_NAS post_NAS pre_NAS@_z mid_NAS@_z post_NAS@_z pre_NAS@_r mid_NAS@_r post_NAS@_r pre_NAS@_full pre_NAS@_miss pre_NAS@_z_full pre_NAS@_z_miss pre_NAS@_r_full pre_NAS@_r_miss, i(sid) j(item)

la var item "NAS item"

la var post_NAS "NAS item (endline)"
la var post_NAS_z "Std. NAS item (endline)"
la var post_NAS_r "Std. NAS item (endline)"

la var mid_NAS "NAS item (midline)"
la var mid_NAS_z "Std. NAS item (midline)"
la var mid_NAS_r "Std. NAS item (midline)"

saveold "$data_dir/Stress_FinalNAS.dta", replace

*********************************
** Panel reshape for titration **
*********************************

use "$data_dir/Stress_FinalWide.dta", clear

loc timevars "time_SSamount1_ time_SSamount2_ time_SSamount3_ time_SSamount4_ time_SSamount5_ time_response1_ time_response2_ time_response3_ time_response4_ time_response5_ time_frac_ time_consistent_ time_indiff_ time_indiffraw_ time_geometric_ time_georaw_ time_exponential_ time_hyperbolic_"

reshape long `timevars', i(sid) j(time_horizon)

la var time_horizon "Time horizon"
la def la_horizon 1 "0m - 1m" 2 "0m - 2m" 3 "0m - 3m" 4 "0m - 6m" 5 "0m - 9m" 6 "0m - 12m" 7 "1m - 2m" 8 "6m - 9m" 9 "6m - 12m"
la val time_horizon la_horizon

recode time_horizon (1/6 = 1) (7/9 = 0), gen(time_immediate)
la var time_immediate "Immediate"

recode time_horizon (1 7 = 1) (2 = 2) (3 8 = 3) (4 9 = 6) (5 = 9) (6 = 12), gen(time_delaymo)
la var time_delaymo "Delay length (months)"

gen time_delayyr = time_delaymo / 12
la var time_delayyr "Delay length (years)"

ren *_ *

egen stid = group(sid time_horizon)

reshape long time_SSamount time_response, i(stid) j(time_question)
la var time_question "Titration question"

drop stid

gen time_patient = 1 - time_response
la var time_patient "Patient choice"

la var time_indiff "Indiff. point"
la var time_geometric "Geometric disc."
la var time_exponential "Exponential decay"

saveold "$data_dir/Stress_FinalTime.dta", replace
