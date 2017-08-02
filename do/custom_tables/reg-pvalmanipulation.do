** Title: reg-pvalmanipulation
** Author: Justin Abraham
** Desc: Outputs p-values comparing effects for affective state across experiments
** Input: Appended dataset
** Output: reg-pvalmanipulation

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

/* Custom fill cells */

use "$data_dir/FinalTime/$Stress_FinalTime_top", clear

foreach yvar in mid_stress_z {

	qui reg `yvar' i.treatment##i.experiment pre_stress_z_full pre_stress_z_miss $yfillmiss, r cl(sessionnum)

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

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{Comparing treatment effects -- Self-reported stress} \label{tab:REG-pvalmanipulation} \maxsizebox*{\textwidth}{\textheight}{ \begin{threeparttable} \begin{tabular}{l*{6}{c}} \toprule"

loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"

loc footnote ""

esttab col* using "$tab_dir/reg-pvalmanipulation.tex", booktabs cells(none) nonum mtitle("\specialcell{TSST-G\\v. CPT}" "\specialcell{TSST-G\\v. CENT}" "\specialcell{CPT\\v.CENT}") stats(`statnames', labels(`varlabels')) note("`footnote'") prehead("`prehead'") postfoot("`postfoot'") compress wrap replace
esttab col* using "$tab_dir/reg-pvalmanipulation-frag.tex", booktabs cells(none) nonum mtitle("\specialcell{TSST-G\\v. CPT}" "\specialcell{TSST-G\\v. CENT}" "\specialcell{CPT\\v.CENT}") stats(`statnames', labels(`varlabels')) compress wrap replace

eststo clear