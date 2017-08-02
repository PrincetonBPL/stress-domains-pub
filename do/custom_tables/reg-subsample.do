** Title: reg-subsample.do
** Author: Justin Abraham
** Desc: Outputs regression tables with FWER adjusted p-values for regression with full controls
** Input: UMIP Master.dta
** Output: reg-subsample.tex

/* Create empty table */

clear all
eststo clear
estimates drop _all

loc columns = 4

set obs 10
gen x = 1
gen y = 1

forval i = 1/`columns' {
	eststo col`i': reg x y
}

loc count = 1				// Cell first line
loc countse = `count' + 1	// Cell second line
loc countp = `countse' + 1  // Cell third line

loc statnames "" 			// Added scalars to be filled
loc varlabels "" 			// Labels for row vars to be filled
loc varindex = 1

loc surlist1 ""				// List of stored estimates for standard SUR
loc surlist2 ""				// List of stored estimates for Heckman SUR

/* Stepdown procedure */

use "$data_dir/FinalCleaned_$stamp.dta", clear

loc endvars ""

foreach yvar in $regvars {
	loc endvars "`endvars' `yvar'_1"
}

gen treat = regret

stepdown reg (`endvars') treat lottery, iter($iterations)	
mat A = r(p)
matlist A

stepdown reg (`endvars') treat lottery $controlvars, iter($iterations)	
mat C = r(p)
matlist C

drop treat

/* Custom fill cells */

foreach yvar in $regvars {

	* Model to be displayed:
	reg `yvar'_1 regret if ~control
	est store spec1_`varindex'
	loc surlist1 "`surlist1' spec1_`varindex'"

	reg `yvar'_1 regret if ~control, vce(r)
	loc N = `e(N)'

	/* Column 1: Regret */

	pstar regret, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col1
	estadd loc thisstat`countse' = "`r(sestar)'": col1
	loc p_adj = A[1, `varindex']
	pstar, p(`p_adj') prec(2) pbracket pstar
	estadd local thisstat`countp' = "`r(pstar)'": col1

	* Model to be displayed:
	reg `yvar'_1 regret $controlvars if ~control
	est store spec2_`varindex'
	loc surlist2 "`surlist1' spec1_`varindex'"

	reg `yvar'_1 regret $controlvars if ~control, vce(r)

	/* Column 2: Regret controls */

	pstar regret, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col2
	estadd loc thisstat`countse' = "`r(sestar)'": col2
	loc p_adj = C[1, `varindex']
	pstar, p(`p_adj') prec(2) pbracket pstar
	estadd local thisstat`countp' = "`r(pstar)'": col2

	/* Column 3: Lottery Mean */

	sum `yvar'_1 if lottery 
	estadd loc thisstat`count' = round(`r(mean)', 0.01): col3
	pstar, se(`r(sd)') prec(2)
	estadd loc thisstat`countse' = "`r(sestar)'": col3

	/* Column 4: N */

	estadd loc thisstat`count' = `N': col4
	
	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar'_1 // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countp'"
	loc count = `count' + 3
	loc countse = `count' + 1
	loc countp = `countse' + 1
	loc ++varindex

}

	/* SUR Joint Tests */

	suest `surlist1', vce(r)

	test regret 
 	pstar, p(`r(p)') pstar pnopar prec(2)
 	estadd local sur_p "`r(pstar)'": col1	

 	
 	suest `surlist2', vce(r)

	test regret 
 	pstar, p(`r(p)') pstar pnopar prec(2)
 	estadd local sur_p "`r(pstar)'": col2	
	
	loc statnames "`statnames' sur_p" 
	loc varlabels "`varlabels' "\midrule Joint (\emph{p}-value)" "

/* Footnote */

loc footnote "\emph{Notes:} Column 1 report OLS estimates for the effect of the regret treatment on the treated. Column 2 reports the estimate controlling for baseline covariates. Standard errors are in parentheses and FWER adjusted \emph{p}-values are in brackets. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct. level."

esttab col* using "$tab_dir/$regpath.tex", booktabs cells(none) title($regtitle) mtitle("Regret" "Regret with controls" "\specialcell{Lottery Mean\\(SD)}" "N") stats(`statnames', labels(`varlabels')) note("`footnote'") postfoot("\hline \multicolumn{@span}{p{\linewidth}}{\footnotesize @note}\\ \end{tabular}\\ \end{table}") compress replace

eststo clear

