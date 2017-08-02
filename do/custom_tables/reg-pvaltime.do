** Title: reg-compare
** Author: Justin Abraham
** Desc: Outputs treatment effects regression by experiment
** Input: Appended dataset
** Output: reg-compare

/* Create empty table */

clear
eststo clear
estimates drop _all

loc columns = 3 // Change number of columns

set obs 10
gen x = 1
gen y = 1

forval i = 1/`columns' {
	eststo col`i': reg x y
}

loc count = 1
loc countse = `count' + 1

loc statnames "" // Added scalars to be filled
loc varlabels "" // Labels for row vars to be filled
loc varindex = 1 // Index for p-value vector

/* Custom fill cells */

use "$data_dir/FinalTime/$Stress_FinalTime_top", clear

foreach yvar in time_patient time_indiff time_exponential time_auc time_stationarity time_decrimp {

	qui reg `yvar' i.treatment##i.experiment i.time_horizon $yfillmiss if (time_horizon == 3 | time_horizon == 4 | time_horizon == 6 | time_horizon == 9), r cl(sessionnum)

	pstar 1.treatment#1.experiment, pstar prec(2) pnopar // TSST v. CPT
	estadd loc thisstat`count' = "`r(pstar)'": col1

	pstar 1.treatment#3.experiment, pstar prec(2) pnopar // TSST v. CPR
	estadd loc thisstat`count' = "`r(pstar)'": col2

	test 1.treatment#1.experiment = 1.treatment#3.experiment // CPT v. CPR
	pstar, p(`r(p)') pstar prec(2) pnopar
	estadd loc thisstat`count' = "`r(pstar)'": col3

	loc thisvarlabel: var la `yvar'
	local varlabels "`varlabels' "`thisvarlabel'" " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse'"
	loc count = `count' + 2
	loc countse = `count' + 1

}

/* Table settings */

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{Comparing treatment effects -- Temporal discounting} \label{tab:REG-pvaltime} \maxsizebox*{\textwidth}{\textheight}{ \begin{threeparttable} \begin{tabular}{l*{`columns'}{c}} \toprule"

loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"

loc footnote ""

esttab col* using "$tab_dir/REG-pvaltime.tex", booktabs cells(none) nonum mtitle("\specialcell{TSST-G\\v. CPT}" "\specialcell{TSST-G\\v. CENT}" "\specialcell{CPT\\v.CENT}") stats(`statnames', labels(`varlabels')) note("`footnote'") prehead("`prehead'") postfoot("`postfoot'") compress wrap replace
esttab col* using "$tab_dir/REG-pvaltime-frag.tex", booktabs cells(none) nonum mtitle("\specialcell{TSST-G\\v. CPT}" "\specialcell{TSST-G\\v. CENT}" "\specialcell{CPT\\v.CENT}") stats(`statnames', labels(`varlabels')) compress wrap replace

eststo clear

