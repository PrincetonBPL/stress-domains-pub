** Title: sum-centfourway.do
** Author: Justin Abraham
** Desc: Outputs baseline summary statistics conditional on treatment group and centipede game type
** Input: UMIP Master.dta
** Output: sum-centfourway.tex

/* Create empty table */

preserve

clear
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

restore

foreach yvar of varlist $sumvars {

	/* Column 1: Control Mean */

	qui sum `yvar' if control & ~sessiontype
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)'": col1
	estadd loc thisstat`countse' = "`r(sestar)'": col1
	estadd loc thisstat`countN' = `N': col1

	/* Column 2: Treatment Mean */

	qui sum `yvar' if treatment & ~sessiontype
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)'": col2
	estadd loc thisstat`countse' = "`r(sestar)'": col2
	estadd loc thisstat`countN' = `N': col2

	/* Column 3: Overall mean */

	qui sum `yvar' if ~sessiontype
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)'": col3
	estadd loc thisstat`countse' = "`r(sestar)'": col3
	estadd loc thisstat`countN' = `N': col3

	/* Column 4: Control Mean */

	qui sum `yvar' if control & sessiontype
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)'": col4
	estadd loc thisstat`countse' = "`r(sestar)'": col4
	estadd loc thisstat`countN' = `N': col4

	/* Column 5: Treatment Mean */

	qui sum `yvar' if treatment & sessiontype
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)'": col5
	estadd loc thisstat`countse' = "`r(sestar)'": col5
	estadd loc thisstat`countN' = `N': col5

	/* Column 6: Overall mean */

	qui sum `yvar' if sessiontype
	loc N = `r(N)'
	pstar, b(`r(mean)') se(`r(sd)') pstar prec(2)

	estadd loc thisstat`count' = "`r(bstar)'": col6
	estadd loc thisstat`countse' = "`r(sestar)'": col6
	estadd loc thisstat`countN' = `N': col6

	/* Row Labels */

	loc thisvarlabel: variable label `yvar' // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countN'"
	loc count = `count' + 3
	loc countse = `count' + 1
	loc countN = `countse' + 1

}

/* Footnotes */

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{$sumtitle} \label{tab:$sumpath} \maxsizebox*{\textwidth}{\textheight}{ \begin{threeparttable} \begin{tabular}{l*{`columns'}{c}} \toprule"

loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"

loc footnote "This table presents means of variables in the CENT experiment across treatment assignment and game type (regular vs. reversed). SD are in parentheses and sample sizs are on the third line."

esttab col* using "$tab_dir/$sumpath.tex", booktabs cells(none) nonum mgroups("Regular" "Reversed", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Control" "Treatment" "Overall" "Control" "Treatment" "Overall") stats(`statnames', labels(`varlabels')) prehead("`prehead'") postfoot("`postfoot'") note("`footnote'") compress wrap replace
esttab col* using "$tab_dir/${sumpath}-frag.tex", booktabs cells(none) nonum mgroups("Regular" "Reversed", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Control" "Treatment" "Overall" "Control" "Treatment" "Overall") stats(`statnames', labels(`varlabels')) compress wrap replace

eststo clear
