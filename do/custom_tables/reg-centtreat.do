** Title: reg-centtreat.do
** Author: Justin Abraham
** Desc: Estimates treatment effects for centipede game
** Input: Stress_FinalWide.dta
** Output: reg-centtreat.do

/* Create empty table */

preserve

clear
eststo clear
estimates drop _all

loc columns = 3

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

/* Regression */

restore

loc regvars "$regvars"
loc length: list sizeof regvars

forval i = 1/3 {

	mat def P`i' = J(`length', 1, .)
	mat def B`i' = J(`length', 1, .)
	mat def SE`i' = J(`length', 1, .)

}

loc j = 1

foreach yvar in $regvars {

	qui reg `yvar' i.treatment##i.experiment $yfillmiss

	cap lincom 1.treatment
	mat def B1[`j', 1] = r(estimate)
	mat def SE1[`j', 1] = r(se)

	cap test 1.treatment = 0
	mat def P1[`j', 1] = r(p)

	qui reg `yvar' i.treatment##i.sessiontype $yfillmiss if experiment == 3, vce(cl sessionnum)

	cap lincom 1.treatment
	mat def B2[`j', 1] = r(estimate)
	mat def SE2[`j', 1] = r(se)

	cap test 1.treatment = 0
	mat def P2[`j', 1] = r(p)

	cap lincom 1.treatment + 1.treatment#1.sessiontype
	mat def B3[`j', 1] = r(estimate)
	mat def SE3[`j', 1] = r(se)

	cap test 1.treatment + 1.treatment#1.sessiontype = 0
	mat def P3[`j', 1] = r(p)

	loc ++j

}

minq P1, q(Q1)
minq P2, q(Q2)
minq P3, q(Q3)

/* Fill table cells */

loc j = 1

foreach yvar in $regvars {

	forval i = 1/3 {

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

/* Table settings */

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{$regtitle} \label{tab:$regpath} \maxsizebox*{\textwidth}{\textheight}{ \begin{threeparttable} \begin{tabular}{l*{`columns'}{c}} \toprule"
loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"
loc footnote "Column 1 reports the treatment effect on the pooled Centipede Game. Column 2 reports treatment effect estimates on each row variable for the regular Centipede Game. Column 3 reports treatment effects for the reversed Centipede Game. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct."

esttab col* using "$tab_dir/$regpath.tex", booktabs cells(none) mtitle("Pooled CENT" "Regular CENT" "Reversed CENT") stats(`statnames', labels(`varlabels')) prehead("`prehead'") postfoot("`postfoot'") note("`footnote'") compress wrap replace
esttab col* using "$tab_dir/${regpath}-frag.tex", booktabs cells(none) mtitle("Pooled CENT" "Regular CENT" "Reversed CENT") stats(`statnames', labels(`varlabels')) compress wrap replace

eststo clear
