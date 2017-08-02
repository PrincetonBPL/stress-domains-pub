** Title: reg-compare.do
** Author: Justin Abraham
** Desc: Estimates treatment effects and compares across experiments
** Input: Stress_FinalWide.dta
** Output: reg-compare.do

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
	loc surlist`i' ""

}

loc count = 1				// Cell first line
loc countse = `count' + 1	// Cell second line
loc countp = `countse' + 1  // Cell third line

loc statnames "" 			// Added scalars to be filled
loc varlabels "" 			// Labels for row vars to be filled

loc surlist ""				// List of eq. for joint estimation

/* SUR */

restore

foreach yvar in $sumvars {

	qui reg `yvar' i.treatment##i.experiment `yvar'_full `yvar'_miss $yfillmiss, r cl(sessionnum)
	est sto e_`yvar'
	loc surlist "`surlist' e_`yvar'"

}

qui suest `surlist', vce(cl sessionnum)
est sto sur

/* Hypothesis tests */

foreach yvar in $regvars {

	loc H1 "[e_`yvar'_mean]1.treatment"
	loc H2 "[e_`yvar'_mean]1.treatment + [e_`yvar'_mean]1.treatment#1.experiment"
	loc H3 "[e_`yvar'_mean]1.treatment + [e_`yvar'_mean]1.treatment#3.experiment"
	loc H4 "[e_`yvar'_mean]1.treatment#1.experiment"
	loc H5 "[e_`yvar'_mean]1.treatment#3.experiment"
	loc H6 "[e_`yvar'_mean]1.treatment#3.experiment - [e_`yvar'_mean]1.treatment#1.experiment"

	forval i = 1/6 {

		qui lincom `H`i''
		qui test `H`i'' = 0

	}

}




/* Custom fill cells */

foreach yvar in $sumvars {

	/* Column 1-2: TSST */

	cap noi {
		qui su `yvar' if exp_tsst == 1 & control == 1
		if r(N) > 0 {
			estadd loc thisstat`count' = string(r(mean), "%9.2f"): col1
			estadd loc thisstat`countse' = "(" + string(r(sd), "%9.2f") + ")": col1
		}

		est res sur1

		qui test [tsst_`yvar'_mean]treatment = 0
		loc p = `r(p)'
		loc b = _b[tsst_`yvar'_mean:treatment]
		loc se = _se[tsst_`yvar'_mean:treatment]

		pstar, b(`b') se(`se') p(`p') prec(2)
		estadd loc thisstat`count' = "`r(bstar)'": col2
		estadd loc thisstat`countse' = "`r(sestar)'": col2
	}

	/* Column 3-4: CPT */

	cap noi {
		qui su `yvar' if exp_cpt == 1 & control == 1
		if r(N) > 0 {
			estadd loc thisstat`count' = string(r(mean), "%9.2f"): col3
			estadd loc thisstat`countse' = "(" + string(r(sd), "%9.2f") + ")": col3
		}

		est res sur2

		qui test [cpt_`yvar'_mean]treatment = 0
		loc p = `r(p)'
		loc b = _b[cpt_`yvar'_mean:treatment]
		loc se = _se[cpt_`yvar'_mean:treatment]

		pstar, b(`b') se(`se') p(`p') prec(2)
		estadd loc thisstat`count' = "`r(bstar)'": col4
		estadd loc thisstat`countse' = "`r(sestar)'": col4
	}

	/* Column 5-6: CENT */

	cap noi {
		qui su `yvar' if exp_cpr == 1 & control == 1
		if r(N) > 0 {
			estadd loc thisstat`count' = string(r(mean), "%9.2f"): col5
			estadd loc thisstat`countse' = "(" + string(r(sd), "%9.2f") + ")": col5
		}

		est res sur3

		qui test [cpr_`yvar'_mean]treatment = 0
		loc p = `r(p)'
		loc b = _b[cpr_`yvar'_mean:treatment]
		loc se = _se[cpr_`yvar'_mean:treatment]

		pstar, b(`b') se(`se') p(`p') prec(2)
		estadd loc thisstat`count' = "`r(bstar)'": col6
		estadd loc thisstat`countse' = "`r(sestar)'": col6
	}

	/* Row Labels */

	loc thisvarlabel: variable label `yvar' // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countN'"
	loc count = `count' + 3
	loc countse = `count' + 1
	loc countN = `countse' + 1

}

/* Joint test */

est restore sur1

	testparm treatment
	pstar, p(`r(p)') pstar pnopar prec(2)
	estadd local sur_p "`r(pstar)'": col2

est restore sur2

	testparm treatment
	pstar, p(`r(p)') pstar pnopar prec(2)
	estadd local sur_p "`r(pstar)'": col4

est restore sur3

	testparm treatment
	pstar, p(`r(p)') pstar pnopar prec(2)
	estadd local sur_p "`r(pstar)'": col6

loc statnames "`statnames' sur_p"
loc varlabels "`varlabels' "\midrule Joint \emph{p}-value" "

/* Table settings */

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{$sumtitle} \label{tab:$sumpath} \maxsizebox*{\textwidth}{\textheight}{ \begin{threeparttable} \begin{tabular}{l*{`columns'}{c}} \toprule"
loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"
loc footnote "This table compares treatment and control means of each row variable. Columns 1, 3, and 5 report control group means for each experiment with SD in parentheses. Columns 2, 4, and 6 report difference of means with the treatment group with standard errors in parentheses. The bottom row reports \(p\)-values of a joint test across row variables.  * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct."

esttab col* using "$tab_dir/$sumpath.tex", booktabs cells(none) nonum mgroups("TSST-G" "CPT" "CENT", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("\specialcell{Control mean\\(SD)}" "\specialcell{Difference}" "\specialcell{Control mean\\(SD)}" "\specialcell{Difference}" "\specialcell{Control mean\\(SD)}" "\specialcell{Difference}") stats(`statnames', labels(`varlabels')) prehead("`prehead'") postfoot("`postfoot'") note("`footnote'") compress wrap replace
esttab col* using "$tab_dir/${sumpath}-frag.tex", booktabs cells(none) nonum mgroups("TSST-G" "CPT" "CENT", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("\specialcell{Control mean\\(SD)}" "\specialcell{Difference}" "\specialcell{Control mean\\(SD)}" "\specialcell{Difference}" "\specialcell{Control mean\\(SD)}" "\specialcell{Difference}") stats(`statnames', labels(`varlabels')) compress wrap replace

eststo clear
