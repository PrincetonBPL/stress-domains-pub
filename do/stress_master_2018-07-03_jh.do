** Title: Stress_Master.do
** Author: Justin Abraham
** Desc: Stress project master do file for re-creating dataset and running analysis
** Dependencies: Stuff from all five experiments
** Note: Change to appropriate user and server filepath

version 13.1

clear all
set maxvar 10000
set matsize 11000
set more off

timer clear
timer on 1

***********
** Setup **
***********

/* Specify directories */

if c(os) == "MacOSX" gl user "/Users/`c(username)'"
else if c(os) == "Windows" gl user "C:\Users\\`c(username)'"
else if c(os) == "Unix" gl user "/usr/`c(username)'"
di "$user"
gl root_dir "$user//Box Sync/_Busara Field/_Project Folders (Internal)/_Old/Stress_domains/code"
if "$user" == "/Users/haushofer" {
	gl root_dir "$user//Box/_Busara Field/_Project Folders (Internal)/_Old/Stress_domains/code"
	}
di "$root_dir"           				// Experiment main drectory

cd "$root_dir"

glo root_dir "`c(pwd)'"
glo ado_dir "$root_dir/ado"  		// .ado files
glo do_dir "$root_dir/do" 			// .do files
glo data_dir "$root_dir/data"	 	// Data
glo tab_dir "$root_dir/latex"		// Tables

adopath + "$ado_dir"

/* What do you want to do? */

glo cleandataflag = 1				// Convert and clean Z-Tree data
glo appenddataflag = 0				// Harmonize all experiments into unified dataset
glo summaryflag = 0					// Output summary statistics
glo regtablesflag = 0				// Output regression tables

/* Analysis options */

glo nasflag = 0						// Manipulation checks
glo timeflag = 0					// Panel regression on temporal discounting
glo riskflag = 0					// Regression on risk preferences

glo permutations = 10000			// Permutations for randmization inference (should be 10,000)
glo USDconvertflag = 1 				// Convert KES to USD
glo ppprate = 1 / 39.56				// KES to USD ppp factor (Source: World Bank, International Comparison Program database)

/* List of variables */

glo ydemo "age married children std_school unemployed quest_response4 quest_response5 quest_response9 quest_bmi"
glo yquest "quest_response1 quest_response2 quest_response3 quest_response4 quest_response5 quest_response6 quest_response7 quest_response8 quest_response9 quest_response10 quest_response11 quest_response12"
glo ypre "pre_frust pre_stress pre_pain pre_NAStot_z"
glo ypost "post_frust post_stress post_NAS post_MSI"
glo ytime "time_avgfrac time_avgindiff time_avgexponential time_auc time_decrimp time_stationarity"
glo yrisk "risk_crra"
glo ycontrol "age married children std_school unemployed quest_response4 quest_response5 quest_response9 quest_bmi"

***************************************
*************** Program ***************
***************************************

/* Stop! Can't touch this */

set seed 961146629

glo currentdate = date("$S_DATE", "DMY")
glo stringdate : di %td_CY.N.D date("$S_DATE", "DMY")
glo stamp = trim("$stringdate")
glo errormsg "Errors:"

/* Clean and merge data */

if $cleandataflag {

	cap noisily {

		do "$do_dir/tsst_clean.do"
		do "$do_dir/cpt_clean.do"
		do "$do_dir/cpr_clean.do"

	}

	if _rc glo errormsg "$errormsg Data cleaning error;"

}

if $appenddataflag {

	cap noisily: do "$do_dir/stress_append.do"
	if _rc glo errormsg "$errormsg Append data error;"

}

/* Analysis */

if $summaryflag {
	cap noisily: do "$do_dir/stress_summary.do"
	if _rc glo errormsg "$errormsg Summary statistics error;"
}

if $regtablesflag {
	cap noisily: do "$do_dir/stress_analysis.do"
	if _rc glo errormsg "$errormsg Regression error."
}

/* Complete program */

if length("$errormsg") < 8 glo errormsg "Errors: none"

timer off 1
qui timer list
di "Finished in `r(t1)' seconds."
di as err "$errormsg"
