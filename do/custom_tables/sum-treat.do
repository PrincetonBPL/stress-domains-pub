** Title: sum-treat.do
** Author: Justin Abraham
** Desc: Outputs baseline summary statistics conditional on treatment group
** Input: UMIP Master.dta
** Output: sum-treat.do

/* Create empty table */

clear
eststo clear
estimates drop _all

loc columns = 4 //Change number of columns

set obs 10
gen x = 1
gen y = 1

forval i = 1/`columns' {
	eststo col`i': reg x y
}

loc count = 1
loc countse = `count' + 1
loc countN = `countse' + 1

loc statnames "" // Added scalars to be filled
loc varlabels "" // Labels for row vars to be filled

/* Custom fill cells */

use "$data_dir/$Stress_Final_topdata", clear 

foreach yvar in $sumvars {

	/* Column 1: Control Mean */

	qui sum `yvar' if control
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)'": col1
	estadd loc thisstat`countse' = "`r(sestar)'": col1
	estadd loc thisstat`countN' = `N': col1

	/* Column 2: Treatment Mean */

	qui sum `yvar' if treatment
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)'": col2
	estadd loc thisstat`countse' = "`r(sestar)'": col2
	estadd loc thisstat`countN' = `N': col2

	/* Column 3: Overall mean */

	qui sum `yvar'
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)'": col3
	estadd loc thisstat`countse' = "`r(sestar)'": col3
	estadd loc thisstat`countN' = `N': col3

	/* Column 4: Difference */
	
	ttest `yvar', by(treatment)
	pstar, p(`r(p)') pstar pnopar prec(2)
	estadd loc thisstat`count' = "`r(pstar)'": col4

	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar' // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countN'"
	loc count = `count' + 3
	loc countse = `count' + 1
	loc countN = `countse' + 1

}

/* Footnotes */

loc footnote "\emph{Notes:} The first two columns report means of each row variable for each treatment group. SD are in parentheses and N is displayed on the third line. The last column reports the \emph{p}-value for a difference of means \emph{t}-test between each group. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct. level."

esttab col* using "$tab_dir/$sumpath.tex", booktabs cells(none) nonum title($sumtitle) mgroups("Mean (SD, N)" "Difference \emph{p}-value", pattern(1 0 0 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Control" "Stress" "Overall" "Stress - Control") stats(`statnames', labels(`varlabels')) note("`footnote'") postfoot("\hline \multicolumn{@span}{p{\linewidth}}{\footnotesize @note}\\ \end{tabular}\\ \end{table}") compress wrap replace

eststo clear

