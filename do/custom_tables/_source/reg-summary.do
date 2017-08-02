** Title: reg-summary.do
** Author: Justin Abraham
** Desc: Outputs table of coefficients summarizing effects on all outcomes
** Output: reg-summary.tex


/* Create empty table */

clear all
eststo clear
estimates drop _all

loc columns = 6

set obs 10
gen x = 1
gen y = 1

forval i = 1/`columns' {
	eststo col`i': reg x y
}

loc count = 1				// Cell first line
loc countse = `count' + 1	// Cell second line

loc statnames "" 			// Added scalars to be filled
loc varlabels "" 			// Labels for row vars to be filled
loc varindex = 1

/* Custom fill cells */

use "$data_dir/Final/UMIP_FinalData_$S_DATE", clear 

foreach yvar in $regvars {

	* Model to be displayed:
	reg `yvar'_1 uct insured inc_highgroup_0 inc_midgroup_0 `yvar'_0, vce(r)
	loc N = `e(N)'

	/* Column 1: Insurance */

	pstar insured, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col1

	/* Column 2: UCT */

	pstar uct, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col2

	/* Column 3: UCT vs Ins */

	test uct = insured
	pstar, p(`r(p)') prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col3

	* Model to be displayed:
	heckman `yvar'_1 uct insured inc_highgroup_0 inc_midgroup_0 `yvar'_0, select($heckvars) twostep

	loc bins = _b[insured]
	loc buct = _b[uct]

	loc seins = _se[insured]
	loc seuct = _se[uct]

	loc df_r = e(N) - e(df_m)
	loc pins = (2 * ttail(`df_r', abs(_b[insured]/_se[insured])))
	loc puct = (2 * ttail(`df_r', abs(_b[uct]/_se[uct])))

	/* Column 4: Heckman Ins */

	pstar, b(`bins') se(`seins') p(`pins') prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col4

	/* Column 5: Heckman UCT */
	
	pstar, b(`buct') se(`seuct') p(`puct') prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col5
	
	/* Column 6: Heckman UCT vs Ins */
	
	test uct = insured
	pstar, p(`r(p)') prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col6
	
	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar'_1 // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse'"
	loc count = `count' + 2 // How many lines to afford each row variable
	loc countse = `count' + 1
	loc ++varindex

}

/* Add scalars */

esttab col* using "$output_dir/Tables/reg/$regpath.tex", booktabs cells(none) nonum title($regtitle) mgroups("ITT" "ITT + Heckman Two-Stage", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Insurance" "UCT" "Difference" "Insurance" "UCT" "Difference") stats(`statnames', labels(`varlabels')) compress replace

eststo clear

