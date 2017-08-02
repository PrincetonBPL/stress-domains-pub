** Title: reg-heckmanlee.do
** Author: Justin Abraham
** Desc: Outputs regression table displaying Lee treatment effects
** Output: reg-lee.tex


/* Create empty table */

clear all
eststo clear
estimates drop _all

loc columns = 7

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

/* Custom fill cells */

use "$data_dir/Final/UMIP_FinalData_$S_DATE", clear

di "$regtitle"
di "$regvars" 

foreach yvar in $regvars {

	di "`yvar'"

	capture noisily {

	* Model to be displayed:
	leebounds `yvar'_1 insured if ~uct, tight(inc_group_0) cieffect

	/* Column 1: Ins upper */

	pstar upper, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col1
	estadd loc thisstat`countse' = "`r(sestar)'": col1

	/* Column 2: Ins lower */

	pstar lower, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col2
	estadd loc thisstat`countse' = "`r(sestar)'": col2

	* Model to be displayed:
	leebounds `yvar'_1 uct if ~insured, tight(inc_group_0) cieffect

	/* Column 3: UCT upper */

	pstar upper, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col3
	estadd loc thisstat`countse' = "`r(sestar)'": col3

	/* Column 4: UCT lower */

	pstar lower, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col4
	estadd loc thisstat`countse' = "`r(sestar)'": col4

	* Model to be displayed:
	leebounds `yvar'_1 insured if treat, tight(inc_group_0) cieffect

	/* Column 5: Diff upper */
	
	pstar upper, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col5
	estadd loc thisstat`countse' = "`r(sestar)'": col5
	
	/* Column 6: Diff lower */
	
	pstar lower, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col6
	estadd loc thisstat`countse' = "`r(sestar)'": col6

	/* Column 7: Control Mean */

	sum `yvar'_1 if control
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col7
	estadd loc thisstat`countse' = "`r(sestar)'": col7
	
	}

	/* Row Labels */
	if _rc == 0 {
	
		loc thisvarlabel: variable label `yvar'_1 // Extracts label from row var
		local varlabels "`varlabels' "`thisvarlabel'" " " " " "
		loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countp'"
		loc count = `count' + 3
		loc countse = `count' + 1
		
	}
	
	else glo error "$error ; Cannot calculate bounds for `yvar'"	

}

loc footnote "\emph{Notes:} Columns 1 - 2 report the interval estimates for the effect of insurance. Columns 3 - 4 report the interval estimates for the effect of the cash transfer. Columns 5 - 6 report the interval estimates for the differential effect of insurance over the cash transfer. Standard errors are in parentheses. Column 7 reports the mean and SD of the control group."

/* Add scalars */

esttab col* using "$output_dir/Tables/reg/$regpath.tex", booktabs cells(none) nonum title($regtitle) mgroups("Insurance" "UCT" "Difference" "Sample", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("\specialcell{Upper\\Bound}" "\specialcell{Lower\\Bound}" "\specialcell{Upper\\Bound}" "\specialcell{Lower\\Bound}" "\specialcell{Upper\\Bound}" "\specialcell{Lower\\Bound}" "\specialcell{Control\\Mean}") stats(`statnames', labels(`varlabels')) note("`footnote'") postfoot("\hline \multicolumn{@span}{p{\linewidth}}{\footnotesize @note}\\ \end{tabular}\\ \end{table}") compress replace

eststo clear

