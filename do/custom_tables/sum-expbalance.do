** Title: sum-treat.do
** Author: Justin Abraham
** Desc: Outputs baseline summary statistics conditional on treatment group
** Input: UMIP Master.dta
** Output: sum-treat.do

/* Create empty table */

clear
eststo clear
estimates drop _all

loc columns = 8 //Change number of columns

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

use "$data_dir/FinalWide/$Stress_FinalWide_top", clear 

foreach yvar in $sumvars {

	/* Column 1: Control Mean */

	qui sum `yvar' if control & exp_tsst
	loc N = `r(N)'

	if `N' > 0 {

		pstar, b(`r(mean)') se(`r(sd)') prec(2) pstar
		estadd loc thisstat`count' = "`r(bstar)'": col1
		estadd loc thisstat`countse' = "`r(sestar)'": col1

	}
	
	/* Column 2: Difference */

	cap noi: ttest `yvar' if exp_tsst, by(treatment)

	if _rc di "No obs. for `yvar'"

	else {

		loc testse = `r(se)'

		qui sum `yvar' if treatment & exp_tsst
		loc tmean = `r(mean)'

		qui sum `yvar' if control & exp_tsst
		loc cmean = `r(mean)'

		loc diff = `tmean' - `cmean'

		qui sum `yvar' if exp_tsst
		loc N = `r(N)'

		pstar, b(`diff') se(`testse') prec(2)
		estadd loc thisstat`count' = "`r(bstar)'": col2
		estadd loc thisstat`countse' = "`N'": col2
	}	

	/* Column 3: Control Mean */

	qui sum `yvar' if control & exp_cpt
	loc N = `r(N)'

	if `N' > 0 {

		pstar, b(`r(mean)') se(`r(sd)') prec(2) pstar

		estadd loc thisstat`count' = "`r(bstar)'": col3
		estadd loc thisstat`countse' = "`r(sestar)'": col3

	}

	/* Column 4: Difference */

	cap noi: ttest `yvar' if exp_cpt, by(treatment)

	if _rc di "No obs. for `yvar'"

	else {

		loc testse = `r(se)'

		qui sum `yvar' if treatment & exp_cpt
		loc tmean = `r(mean)'

		qui sum `yvar' if control & exp_cpt
		loc cmean = `r(mean)'

		loc diff = `tmean' - `cmean'

		qui sum `yvar' if exp_cpt
		loc N = `r(N)'

		pstar, b(`diff') se(`testse') prec(2)
		estadd loc thisstat`count' = "`r(bstar)'": col4
		estadd loc thisstat`countse' = "`N'": col4
	}	
	
	/* Column 5: Control Mean */

	qui sum `yvar' if control & exp_cpr
	loc N = `r(N)'

	if `N' > 0 {

		pstar, b(`r(mean)') se(`r(sd)') prec(2) pstar

		estadd loc thisstat`count' = "`r(bstar)'": col5
		estadd loc thisstat`countse' = "`r(sestar)'": col5

	}

	/* Column 6: Difference */

	cap noi: ttest `yvar' if exp_cpr, by(treatment)

	if _rc di "No obs. for `yvar'"

	else {

		loc testse = `r(se)'

		qui sum `yvar' if treatment & exp_cpr
		loc tmean = `r(mean)'

		qui sum `yvar' if control & exp_cpr
		loc cmean = `r(mean)'

		loc diff = `tmean' - `cmean'

		qui sum `yvar' if exp_cpr
		loc N = `r(N)'

		pstar, b(`diff') se(`testse') prec(2)
		estadd loc thisstat`count' = "`r(bstar)'": col6
		estadd loc thisstat`countse' = "`N'": col6
	}	
	
	/* Column 7: Control Mean */

	qui sum `yvar' if control
	loc N = `r(N)'

	if `N' > 0 {

		pstar, b(`r(mean)') se(`r(sd)') prec(2) pstar

		estadd loc thisstat`count' = "`r(bstar)'": col7
		estadd loc thisstat`countse' = "`r(sestar)'": col7

	}

	/* Column 8: Difference */

	cap noi: ttest `yvar', by(treatment)

	if _rc di "No obs. for `yvar'"

	else {

		loc testse = `r(se)'

		qui sum `yvar' if treatment
		loc tmean = `r(mean)'

		qui sum `yvar' if control
		loc cmean = `r(mean)'

		loc diff = `tmean' - `cmean'

		qui sum `yvar'
		loc N = `r(N)'

		pstar, b(`diff') se(`testse') prec(2)
		estadd loc thisstat`count' = "`r(bstar)'": col8
		estadd loc thisstat`countse' = "`N'": col8
	}	

	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar' // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countN'"
	loc count = `count' + 3
	loc countse = `count' + 1
	loc countN = `countse' + 1

}

/* Table settings */

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{$sumtitle} \label{tab:$sumpath} \maxsizebox*{\textwidth}{\textheight}{ \begin{threeparttable} \begin{tabular}{l*{`columns'}{c}} \toprule"

loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"

loc footnote "This table presents control group means by experiment with SD in parentheses. The second subcolumns report the difference of means between the treatment and control with \(N\) on the second line. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct. for a difference of means \(t\)-test."

esttab col* using "$tab_dir/$sumpath.tex", booktabs cells(none) nonum mgroups("TSST-G" "CPT" "CENT" "Overall", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("\specialcell{Mean\\SD}" "\specialcell{Diff.\\N}" "\specialcell{Mean\\SD}" "\specialcell{Diff.\\N}" "\specialcell{Mean\\SD}" "\specialcell{Diff.\\N}" "\specialcell{Mean\\SD}" "\specialcell{Diff.\\N}") stats(`statnames', labels(`varlabels')) prehead("`prehead'") postfoot("`postfoot'") note("`footnote'") compress wrap replace
esttab col* using "$tab_dir/${sumpath}-frag.tex", booktabs cells(none) nonum mgroups("TSST-G" "CPT" "CENT" "Overall", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("\specialcell{Mean\\SD}" "\specialcell{Diff.\\N}" "\specialcell{Mean\\SD}" "\specialcell{Diff.\\N}" "\specialcell{Mean\\SD}" "\specialcell{Diff.\\N}" "\specialcell{Mean\\SD}" "\specialcell{Diff.\\N}") stats(`statnames', labels(`varlabels')) compress wrap replace

eststo clear

