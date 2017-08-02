** Title: reg-nn.do
** Author: Justin Abraham
** Desc: Outputs regression table comparing nearest neighbor matching algorithms
** Output: reg-nn.tex


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
loc varindex = 1

/* Custom fill cells */

use "$data_dir/Final/UMIP_FinalData_$S_DATE", clear

foreach yvar in $regvars {

	/* Column 1: Insurance */
	
	psmatch2 got_insured if ~uct, pscore(pscore_insured) outcome(`yvar'_1) kernel kerneltype(epan)
	loc att = r(att)
	loc seatt = r(seatt)
	pstar, b(`att') se(`seatt') prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col1
	estadd loc thisstat`countse' = "`r(sestar)'": col1

	/* Column 2: UCT */

	psmatch2 got_uct if ~insured, pscore(pscore_uct) outcome(`yvar'_1) kernel kerneltype(epan)
	loc att = r(att)
	loc seatt = r(seatt)
	pstar, b(`att') se(`seatt') prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col2
	estadd loc thisstat`countse' = "`r(sestar)'": col2

	/* Column 3: UCT vs Ins */

	psmatch2 got_insured if ~control, pscore(pscore_diff) outcome(`yvar'_1) kernel kerneltype(epan)
	loc att = r(att)
	loc seatt = r(seatt)
	pstar, b(`att') se(`seatt') prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col3
	estadd loc thisstat`countse' = "`r(sestar)'": col3

	/* Column 4: Insurance */

	psmatch2 got_insured if ~uct, pscore(pscore_insured) outcome(`yvar'_1) kernel kerneltype(normal)
	loc att = r(att)
	loc seatt = r(seatt)
	pstar, b(`att') se(`seatt') prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col4
	estadd loc thisstat`countse' = "`r(sestar)'": col4

	/* Column 5: UCT */

	psmatch2 got_uct if ~insured, pscore(pscore_uct) outcome(`yvar'_1) kernel kerneltype(normal)
	loc att = r(att)
	loc seatt = r(seatt)
	pstar, b(`att') se(`seatt') prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col5
	estadd loc thisstat`countse' = "`r(sestar)'": col5

	/* Column 6: UCT vs Ins */

	psmatch2 got_insured if ~control, pscore(pscore_diff) outcome(`yvar'_1) kernel kerneltype(normal)
	loc att = r(att)
	loc seatt = r(seatt)
	pstar, b(`att') se(`seatt') prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col6
	estadd loc thisstat`countse' = "`r(sestar)'": col6

	/* Column 7: Control Mean */

	sum `yvar'_1 if control
	loc N = r(N) 
	estadd loc thisstat`count' = round(`r(mean)', 0.01): col7
	pstar, se(`r(sd)') prec(2)
	estadd loc thisstat`countse' = "`r(sestar)'": col7
	
	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar'_1 // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countp'"
	loc count = `count' + 3
	loc countse = `count' + 1
	loc ++varindex

}

loc footnote "\emph{Notes:} This table reports average treatment effects on the treated using kernel matching with a bandwidth of 0.6. Columns 1 - 3 matches using the Epanechnikov kernel. Columns 4 - 6 matches using Gaussian kernel. Standard errors are in parentheses."

esttab col* using "$output_dir/Tables/reg/$regpath.tex", booktabs cells(none) title($regtitle) mgroups("Epanechnikov" "Gaussian" "Sample", pattern(1 0 0 1 0 0 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Insurance" "UCT" "Difference" "Insurance" "UCT" "Difference" "\specialcell{Control Mean\\(SD)}") stats(`statnames', labels(`varlabels')) note("`footnote'") postfoot("\hline \multicolumn{@span}{p{\linewidth}}{\footnotesize @note}\\ \end{tabular}\\ \end{table}") compress replace

eststo clear

