** Title: reg-subsample.do
** Author: Justin Abraham
** Desc: Outputs regression table comparing full and subsample estimates
** Output: reg-subsample.tex


/* Create empty table */

clear all
eststo clear
estimates drop _all

loc columns = 8

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
	reg `yvar'_1 uct insured inc_highgroup_0 inc_midgroup_0 `yvar'_0
	est store spec1_`varindex'
	loc surlist1 "`surlist1' spec1_`varindex'"

	reg `yvar'_1 uct insured inc_highgroup_0 inc_midgroup_0 `yvar'_0, vce(r)
	loc N = `e(N)'

	/* Column 1: Insurance */

	pstar insured, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col1
	estadd loc thisstat`countse' = "`r(sestar)'": col1

	/* Column 2: UCT */

	pstar uct, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col2
	estadd loc thisstat`countse' = "`r(sestar)'": col2

	/* Column 3: UCT vs Ins */

	test uct = insured

	pstar, p(`r(p)') prec(2) pstar pnopar
	estadd loc thisstat`count' = "`r(pstar)'": col3

	* Model to be displayed:
	reg `yvar'_1 uct insured inc_highgroup_0 inc_midgroup_0 `yvar'_0 if havenationalid_0
	est store spec2_`varindex'
	loc surlist2 "`surlist1' spec1_`varindex'"

	reg `yvar'_1 uct insured inc_highgroup_0 inc_midgroup_0 `yvar'_0 if havenationalid_0, vce(r)

	/* Column 4: Insurance */

	pstar insured, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col4
	estadd loc thisstat`countse' = "`r(sestar)'": col4

	/* Column 5: UCT */

	pstar uct, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col5
	estadd loc thisstat`countse' = "`r(sestar)'": col5

	/* Column 6: UCT vs Ins */

	test uct = insured
	pstar, p(`r(p)') prec(2) pstar pnopar
	estadd loc thisstat`count' = "`r(pstar)'": col6

	/* Column 7: Control Mean */

	sum `yvar'_1 if control 
	estadd loc thisstat`count' = round(`r(mean)', 0.01): col7
	pstar, se(`r(sd)') prec(2)
	estadd loc thisstat`countse' = "`r(sestar)'": col7

	/* Column 8: N */

	estadd loc thisstat`count' = `N': col8
	
	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar'_1 // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countp'"
	loc count = `count' + 3
	loc countse = `count' + 1
	loc ++varindex

}

	/* SUR Joint Tests */

	suest `surlist1', vce(r)

	test insured
 	pstar, p(`r(p)') pstar pnopar prec(2)
 	estadd local sur_p "`r(pstar)'": col1

	test uct 
 	pstar, p(`r(p)') pstar pnopar prec(2)
 	estadd local sur_p "`r(pstar)'": col2	
	
	test uct = insured
 	pstar, p(`r(p)') pstar pnopar prec(2)
 	estadd local sur_p "`r(pstar)'": col3

 	suest `surlist2', vce(r)

	test uct 
 	pstar, p(`r(p)') pstar pnopar prec(2)
 	estadd local sur_p "`r(pstar)'": col4

	test insured
 	pstar, p(`r(p)') pstar pnopar prec(2)
 	estadd local sur_p "`r(pstar)'": col5	

	test uct = insured
 	pstar, p(`r(p)') pstar pnopar prec(2)
 	estadd local sur_p "`r(pstar)'": col6		
	
	loc statnames "`statnames' sur_p" 
	loc varlabels "`varlabels' "\midrule Joint (\emph{p}-value)" "

	loc footnote "\emph{Notes:} Columns 1 - 2 report naive OLS estimates without correcting for selection. Columns 4 - 5 report estimates for the subsample of respondents who had a national ID at baseline. Columns 3 and 6 report the \emph{p}-values for Wald tests of the equality of the UCT and insurance effects after estimation. Standard errors are in parentheses. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct. level."

esttab col* using "$output_dir/Tables/reg/$regpath.tex", booktabs cells(none) title($regtitle) mgroups("Full OLS" "Subsample OLS" "Sample", pattern(1 0 0 1 0 0 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Insurance" "UCT" "\specialcell{Difference\\\emph{p}-value}" "Insurance" "UCT" "\specialcell{Difference\\\emph{p}-value}" "\specialcell{Control Mean\\(SD)}" "N") stats(`statnames', labels(`varlabels')) note("`footnote'") postfoot("\hline \multicolumn{@span}{p{\linewidth}}{\footnotesize @note}\\ \end{tabular}\\ \end{table}") compress replace

eststo clear

