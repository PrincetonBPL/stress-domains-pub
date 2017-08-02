** Title: sum-participation.do
** Author: Justin Abraham
** Desc: Outputs summary statistics by participation
** Input: UMIP Master.dta
** Output: sum-participation.tex

/* Create empty table */

clear all
eststo clear
estimates drop _all

loc columns = 3 //Change number of columns

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

use "$data_dir/FinalCleaned_$stamp.dta", clear

foreach yvar in $sumvars {

	/* Column 1: Completed Mean */

	sum `yvar'_0 if ~attrit
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)'": col1
	estadd loc thisstat`countse' = "`r(sestar)'": col1
	estadd loc thisstat`countN' = `N' : col1

	/* Column 2: Attrition Mean */

	sum `yvar'_0 if attrit
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)'": col2
	estadd loc thisstat`countse' = "`r(sestar)'": col2
	estadd loc thisstat`countN' = `N' : col2

	/* Column 3: Complete - Attrition */
	
	ttest `yvar'_0, by(endline)
	pstar, p(`r(p)') pstar pnopar prec(2)
	estadd loc thisstat`count' = "`r(pstar)'": col3

	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar'_0 // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countN'"
	loc count = `count' + 3
	loc countse = `count' + 1
	loc countN = `countse' +1

}

/* Footnotes */

loc footnote "\emph{Notes:} The first two columns report means of each row variable by observation status at endline. SD are in parentheses and N is displayed on the third line. The last column report the \emph{p}-value for a difference of means \emph{t}-test between each group. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct. level."

esttab col* using "$tab_dir/$sumpath.tex", booktabs cells(none) nonum title($sumtitle) mgroups("Mean (SD)" "\specialcell{Difference \\ \emph{p}-value}", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Complete" "Attrition" "\specialcell{Complete -\\Attrition}") stats(`statnames', labels(`varlabels')) note("`footnote'") postfoot("\hline \multicolumn{@span}{p{\linewidth}}{\footnotesize @note}\\ \end{tabular}\\ \end{table}") compress replace

eststo clear

