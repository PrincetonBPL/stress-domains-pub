** Title: reg-spillovers.do
** Author: Justin Abraham
** Desc: Outputs table of p-values summarizing spillover effects on all outcomes
** Output: reg-spillovers.tex


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

loc surlist1 ""				// List of stored estimates for standard SUR
loc surlist2 ""				// List of stored estimates for Heckman SUR

/* Custom fill cells */

use "$data_dir/Final/UMIP_FinalData_$S_DATE", clear 

foreach yvar in $regvars {

	* Model to be displayed:
	reg `yvar'_1 insured uct `spillvars' inc_highgroup_0 inc_midgroup_0 `yvar'_0, vce(robust)
	est store spec1_`varindex'
	loc surlist1 "`surlist1' spec1_`varindex'"
	loc N = `e(N)'

	/* Column 1: Insurance */

	pstar insured, pstar pnopar prec(2)
	estadd loc thisstat`count' = "`r(pstar)'": col1

	/* Column 2: UCT */

	pstar uct, pstar pnopar prec(2)
	estadd loc thisstat`count' = "`r(pstar)'": col2

	/* Column 3: UCT vs Ins */

	test uct = insured
	pstar, p(`r(p)') pstar pnopar prec(2)
	estadd loc thisstat`count' = "`r(pstar)'": col3

	* Model to be displayed:
	ivregress 2sls `yvar'_1 insured uct (`spillvars2' = `spillvars') inc_highgroup_0 inc_midgroup_0 `yvar'_0, vce(robust)
	est store spec2_`varindex'
	loc surlist2 "`surlist2' spec2_`varindex'"

	/* Column 4: Heckman Ins */

	pstar insured, pstar pnopar prec(2)
	estadd loc thisstat`count' = "`r(pstar)'": col4

	/* Column 5: Heckman UCT */
	
	pstar uct, pstar pnopar prec(2)
	estadd loc thisstat`count' = "`r(pstar)'": col5
	
	/* Column 6: Heckman UCT vs Ins */
	
	test uct = insured
	pstar, p(`r(p)') pstar pnopar prec(2)
	estadd loc thisstat`count' = "`r(pstar)'": col6
	
	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar'_1 // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse'"
	loc count = `count' + 2 // How many lines to afford each row variable
	loc countse = `count' + 1
	loc ++varindex

}

	/* SUR Joint Tests */

	/* suest `surlist1'

	test uct 
 	pstar, p(`r(p)') pstar pnopar prec(2)
 	estadd local sur_p "`r(pstar)'": col1
	test insured
 	pstar, p(`r(p)') pstar pnopar prec(2)
 	estadd local sur_p "`r(pstar)'": col2	
	test uct = insured
 	pstar, p(`r(p)') pstar pnopar prec(2)
 	estadd local sur_p "`r(pstar)'": col3

 	suest `surlist2'

	test uct 
 	pstar, p(`r(p)') pstar prec(2)
 	estadd local sur_p "`r(pstar)'": col4
	test insured
 	pstar, p(`r(p)') pstar prec(2)
 	estadd local sur_p "`r(pstar)'": col5	
	test uct = insured
 	pstar, p(`r(p)') pstar prec(2)
 	estadd local sur_p "`r(pstar)'": col6		
	
	loc statnames "`statnames' sur_p" 
	loc varlabels "`varlabels' "\midrule Joint (\emph{p}-value)" " */

/* Add scalars */

esttab col* using "$output_dir/Tables/reg/$regpath.tex", booktabs cells(none) nonum title($regtitle) mgroups("ITT" "ITT + Heckman Two-Stage", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Insurance" "UCT" "Difference" "Insurance" "UCT" "Difference") stats(`statnames', labels(`varlabels')) compress replace

eststo clear

