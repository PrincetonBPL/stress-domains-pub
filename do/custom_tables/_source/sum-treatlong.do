** Title: sum-treatlong.do
** Author: Justin Abraham
** Desc: Outputs baseline summary statistics conditional on treatment in long portrait format
** Input: UMIP Master.dta
** Output: sum-treatlong.do

/* Create empty table */

clear all
eststo clear
estimates drop _all

loc columns = 6 //Change number of columns

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

use "$data_dir/Final/UMIP_FinalData_$S_DATE", clear 

foreach yvar in $sumvars {

	/* Column 1: Control Mean */

	sum `yvar'_0 if control
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)' `r(sestar)'": col1
	estadd loc thisstat`countse' = `N': col1

	/* Column 2: Insurance Mean */

	sum `yvar'_0 if insured
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)' `r(sestar)'": col2
	estadd loc thisstat`countse' = `N': col2

	/* Column 3: UCT Mean */

	sum `yvar'_0 if uct
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)' `r(sestar)'": col3
	estadd loc thisstat`countse' = `N': col3

	/* Column 4: Ins - Control */
	
	ttest `yvar'_0 if ~uct, by(insured)

	pstar, p(`r(p)') pstar pnopar prec(2)
	estadd loc thisstat`count' = "`r(pstar)'": col4

	/* Column 5: UCT - Control */
	
	ttest `yvar'_0 if ~insured, by(uct)

	pstar, p(`r(p)') pstar pnopar prec(2)
	estadd loc thisstat`count' = "`r(pstar)'": col5

	/* Column 6: Ins - UCT */
	
	ttest `yvar'_0 if treat, by(insured)

	pstar, p(`r(p)') pstar pnopar prec(2)
	estadd loc thisstat`count' = "`r(pstar)'": col6

	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar'_0 // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse'"
	loc count = `count' + 2
	loc countse = `count' + 1

}

/* Footnotes */

loc footnote "\emph{Notes:} The first three columns report means of each row variable for each treatment group. SD are in parentheses and N is displayed on the second line. The last three columns report the \emph{p}-value for a difference of means \emph{t}-test between each group. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct. level."

esttab col* using "$output_dir/Tables/$sumpath.tex", wrap booktabs cells(none) nonum title($sumtitle) mgroups("Mean (SD, N)" "Difference \emph{p}-value", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Control" "Insurance" "UCT" "\specialcell{Ins. -\\Control}" "\specialcell{UCT -\\Control}" "\specialcell{Ins. -\\UCT}") stats(`statnames', labels(`varlabels')) note("`footnote'") postfoot("\hline \multicolumn{@span}{p{\linewidth}}{\footnotesize @note}\\ \end{tabular}\\ \end{table}") compress replace

eststo clear

