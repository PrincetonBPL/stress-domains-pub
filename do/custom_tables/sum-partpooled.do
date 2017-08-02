** Title: sum-partpooled.do
** Author: Justin Abraham
** Desc: Outputs summary statistics by participation (pooled attrition)
** Input: UMIP Master.dta
** Output: sum-partpooled.tex

/* Create empty table */

clear all
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
loc countN = `count' + 1

loc statnames "" // Added scalars to be filled
loc varlabels "" // Labels for row vars to be filled

/* Custom fill cells */

use "$data_dir/FinalCleaned_$stamp.dta", clear

loc rhs ""

foreach yvar in $sumvars {
	loc rhs "`rhs' `yvar'_0"
}

reg endline `rhs', vce(r)
loc regN = e(N)
loc regR2 = e(r2)

foreach yvar in $sumvars {
	loc `yvar'_b = _b[`yvar'_0]
	loc `yvar'_se = _se[`yvar'_0]
}

foreach yvar in $sumvars {

	/* Column 1: Completed Mean */

	sum `yvar'_0 if ~attr
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)' `r(sestar)'": col1
	estadd loc thisstat`countN' = `N': col1

	/* Column 2: Attrition Mean */

	sum `yvar'_0 if attr
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)' `r(sestar)'": col2
	estadd loc thisstat`countN' = `N': col2

	/* Column 3: Complete - Attrition */
	
	ttest `yvar'_0, by(attr)

	pstar, p(`r(p)') pstar pnopar prec(2)
	estadd loc thisstat`count' = "`r(pstar)'": col3

	/* Column 4: Regression */

	pstar, b(``yvar'_b') se(``yvar'_se') prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col4
	estadd loc thisstat`countN' = "`r(sestar)'": col4

	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar'_0 // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " 
	loc statnames "`statnames' thisstat`count' thisstat`countN'"
	loc count = `count' + 2
	loc countN = `count' + 1

}

/* Footnotes */

loc footnote "\emph{Notes:} Columns 1 - 2 report means of each row variable by attrition status. SD are in parentheses and N is displayed on the third line. Column 3 reports the \emph{p}-value for a difference of means \emph{t}-test between each group. Column 4 reports the results of a LPM (N = `regN', R^2 = `regR2') of selection at endline on all of the row variables. SE are in parentheses. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct. level."

esttab col* using "$tab_dir/$sumpath.tex", wrap booktabs cells(none) nonum title($sumtitle) mgroups("Mean (SD)" "Difference \emph{p}-value", pattern(1 0 1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("\specialcell{Completed\\endline}" "Attrition" "\specialcell{Complete -\\Attrition}" "\specialcell{Selection\\Model}") stats(`statnames', labels(`varlabels')) note("`footnote'") postfoot("\hline \multicolumn{@span}{p{\linewidth}}{\footnotesize @note}\\ \end{tabular}\\ \end{table}") compress replace
eststo clear

