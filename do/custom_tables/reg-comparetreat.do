** Title: reg-comparetreat.do
** Author: Justin Abraham
** Desc: Estimates treatment effects and compares across experiments
** Input: Stress_FinalWide.dta
** Output: reg-comparetreat.do

/* Create empty table */

preserve

clear
eststo clear
estimates drop _all

loc columns = 6

set obs 10
gen x = 1
gen y = 1

forval i = 1/`columns' {

	qui eststo col`i': reg x y

}

loc count = 1				// Cell first line
loc countse = `count' + 1	// Cell second line
loc countp = `countse' + 1  // Cell third line

loc statnames "" 			// Added scalars to be filled
loc varlabels "" 			// Labels for row vars to be filled

loc surlist ""				// List of eq. for joint estimation

/* SUR */

restore

loc regvars "$regvars"
loc length: list sizeof regvars

fvset base 3 experiment

foreach yvar in $regvars {

	qui reg `yvar' i.treatment##i.experiment $yfillmiss
	est sto e_`yvar'
	loc surlist "`surlist' e_`yvar'"

}

suest `surlist', vce(cl sessionnum) allbaselevels
est sto sur

/* Hypothesis tests */

forval i = 1/6 {

	loc surtest`i' ""

	mat def P`i' = J(`length', 1, .)
	mat def B`i' = J(`length', 1, .)
	mat def SE`i' = J(`length', 1, .)

	loc j = 1

	foreach yvar in $regvars {

		loc H1 "[e_`yvar'_mean]1.treatment + [e_`yvar'_mean]1.treatment#0.experiment"
		loc H2 "[e_`yvar'_mean]1.treatment + [e_`yvar'_mean]1.treatment#1.experiment"
		loc H3 "[e_`yvar'_mean]1.treatment"
		loc H4 "[e_`yvar'_mean]1.treatment#1.experiment - [e_`yvar'_mean]1.treatment#0.experiment"
		loc H5 "-[e_`yvar'_mean]1.treatment#0.experiment"
		loc H6 "[e_`yvar'_mean]1.treatment#3.experiment - [e_`yvar'_mean]1.treatment#1.experiment"

		/* Test hypothesis */

		cap noi {

			qui lincom `H`i''
			mat def B`i'[`j', 1] = r(estimate)
			mat def SE`i'[`j', 1] = r(se)

			qui test `H`i'' = 0
			mat def P`i'[`j', 1] = r(p)

			loc surtest`i' "`surtest`i'' (`H`i'' = 0)"

		}

		if _rc & `length' < 2 {

			loc H1 "1.treatment + 1.treatment#0.experiment"
			loc H2 "1.treatment + 1.treatment#1.experiment"
			loc H3 "1.treatment"
			loc H4 "1.treatment#1.experiment - 1.treatment#0.experiment"
			loc H5 "-1.treatment#0.experiment"
			loc H6 "1.treatment#3.experiment - 1.treatment#1.experiment"

			qui lincom `H`i''
			mat def B`i'[`j', 1] = r(estimate)
			mat def SE`i'[`j', 1] = r(se)

			qui test `H`i'' = 0
			mat def P`i'[`j', 1] = r(p)

		}

		loc ++j

	}

	minq P`i', q(Q`i')

}

/* Fill table cells */

loc j = 1

foreach yvar in $regvars {

	forval i = 1/6 {

		loc b = B`i'[`j', 1]
		loc se = SE`i'[`j', 1]
		loc p = P`i'[`j', 1]
		loc q = Q`i'[`j', 1]

		sigstar, b(`b') se(`se') p(`p') prec(2)
		estadd loc thisstat`count' =  r(bstar): col`i'
		estadd loc thisstat`countse' =  r(sestar): col`i'

		if `length' > 1 {

			sigstar, p(`q') prec(2) pstar pbrackets
			estadd loc thisstat`countp' = r(pstar): col`i'

		}

	}

	/* Row Labels */

	loc thisvarlabel: variable label `yvar'
	local varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countp'"
	loc count = `count' + 3
	loc countse = `count' + 1
	loc countp = `countse' + 1
	loc ++j

}

/* Joint test */

est res sur

if `length' > 1 {

	forval i = 1/6 {

		qui test `surtest`i''
		sigstar, p(`r(p)') prec(2) pstar
		estadd loc sur_p = r(pstar): col`i'

	}

	loc statnames "`statnames' sur_p"
	loc varlabels "`varlabels' "\midrule Joint test \emph{p}-value" "
	
}

/* Table settings */

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{$regtitle} \label{tab:$regpath} \maxsizebox*{\textwidth}{\textheight}{ \begin{threeparttable} \begin{tabular}{l*{`columns'}{c}} \toprule"
loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"
loc footnote "Columns 1-3 report treatment effect estimates on each row variable for TSST-G, CPT, and CENT, respectively. Columns 4-6 report differences in the treatment effect across experiments. Standard errors are in parentheses and FDR-adjusted minimum \(q\)-values are in brackets. Stars on the coefficient estimates indicate significance with naive \(p\)-values. The bottom row reports \(p\)-values of a joint test across row variables. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct."

esttab col* using "$tab_dir/$regpath.tex", booktabs cells(none) mgroups("Within experiments" "Across experiments", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("TSST-G" "CPT" "CENT" "\specialcell{CPT vs.\\TSST-G}" "\specialcell{CENT vs.\\TSST-G}" "\specialcell{CENT\\vs. CPT}") stats(`statnames', labels(`varlabels')) prehead("`prehead'") postfoot("`postfoot'") note("`footnote'") compress wrap replace
esttab col* using "$tab_dir/${regpath}-frag.tex", booktabs cells(none) mgroups("Within experiments" "Across experiments", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("TSST-G" "CPT" "CENT" "\specialcell{CPT vs.\\TSST-G}" "\specialcell{CENT vs.\\TSST-G}" "\specialcell{CENT\\vs. CPT}") stats(`statnames', labels(`varlabels')) compress wrap replace

eststo clear
