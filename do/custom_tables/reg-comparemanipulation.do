** Title: reg-compare
** Author: Justin Abraham
** Desc: Outputs treatment effects regression by experiment
** Input: Appended dataset
** Output: reg-compare

/* Create empty table */

preserve

clear
eststo clear
estimates drop _all

loc columns = 6 // Change number of columns

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

/* Using wide data */

* loc column = 1

* foreach exp in exp_tsst exp_cpt exp_cpr {

* 	cap noi: reg post_MSI_r treatment pre_MSI_r_full pre_MSI_r_miss $yfillmiss if `exp', r cl(sessionnum)

* 	if _rc == 0 {

* 		loc numplus = `column' + 1


* 		estadd loc thisstat`count' = `e(N)': col`numplus'

* 		pstar treatment, prec(2)
* 		estadd loc thisstat`count' = "`r(bstar)'": col`column'
* 		estadd loc thisstat`countse' = "`r(sestar)'": col`column'

* 		reg post_MSI_r treatment pre_MSI_r_full pre_MSI_r_miss $yfillmiss if `exp'
* 		est store `exp'_post_MSI

* 	}

* 	loc column = `column' + 2

* }

* loc thisvarlabel: variable label post_MSI_r // Extracts label from row var
* local varlabels "`varlabels' "`thisvarlabel'" " " " " "
* loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countN'"
* loc count = `count' + 3
* loc countse = `count' + 1
* loc countN = `countse' + 1

foreach root in NAStot stress {

	foreach prefix in mid post {

		loc column = 1

		foreach exp in exp_tsst exp_cpt exp_cpr {

			cap noi: reg `prefix'_`root'_r treatment pre_`root'_r_full pre_`root'_r_miss $yfillmiss if `exp', r cl(sessionnum)

			if _rc == 0 {

				loc numplus = `column' + 1

				estadd loc thisstat`count' = `e(N)': col`numplus'

				pstar treatment, prec(2)
				estadd loc thisstat`count' = "`r(bstar)'": col`column'
				estadd loc thisstat`countse' = "`r(sestar)'": col`column'

				reg `prefix'_`root'_r treatment pre_`root'_r_full pre_`root'_r_miss $yfillmiss if `exp'
				est store `exp'_`prefix'_`root'

			}

			loc column = `column' + 2

		}

		loc thisvarlabel: variable label `prefix'_`root'_r // Extracts label from row var
		local varlabels "`varlabels' "`thisvarlabel'" " " " " "
		loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countN'"
		loc count = `count' + 3
		loc countse = `count' + 1
		loc countN = `countse' + 1

	}

}

/* SUR Joint Tests */

suest exp_tsst_*, r cl(sessionnum)

	test treatment
	pstar, p(`r(p)') pstar pnopar prec(2)
	estadd local sur_p "`r(pstar)'": col1

suest exp_cpt_*, r cl(sessionnum)

	test treatment
	pstar, p(`r(p)') pstar pnopar prec(2)
	estadd local sur_p "`r(pstar)'": col3

suest exp_cpr_*, r cl(sessionnum)

	test treatment
	pstar, p(`r(p)') pstar pnopar prec(2)
	estadd local sur_p "`r(pstar)'": col5

/* Use long NAS data */

/* use "$data_dir/FinalNAS/$Stress_FinalNAS_top", clear

foreach yvar in mid_NAS post_NAS {

	loc column = 1

	foreach exp in exp_tsst exp_cpt exp_cpr {

		cap noi: reg `yvar'_r treatment pre_NAS_r_full pre_NAS_r_miss $yfilllmiss if `exp', r cl(sessionnum)

		if _rc == 0 {

			loc numplus = `column' + 1

			estadd loc thisstat`count' = `e(N)': col`numplus'

			pstar treatment, prec(2)
			estadd loc thisstat`count' = "`r(bstar)'": col`column'
			estadd loc thisstat`countse' = "`r(sestar)'": col`column'

		}

		loc column = `column' + 2

	}

	loc thisvarlabel: variable label `yvar'_r // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countN'"
	loc count = `count' + 3
	loc countse = `count' + 1
	loc countN = `countse' + 1

} */

loc statnames "`statnames' sur_p"
loc varlabels "`varlabels' "\midrule Joint \(p\)-value" "

/* Table settings */

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{Domain-specific treatment effects -- Affective state} \label{tab:REG-comparemanipulation} \maxsizebox*{\textwidth}{\textheight}{ \begin{threeparttable} \begin{tabular}{l*{`columns'}{c}} \toprule"

loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"

loc footnote "This table summarizes the treatment effect of stressors on self-reported affective state by experiment. Each cell reports the estimate and standard error from a regression of the row variable on the treatment. The second subcolumns report number of observations of each regression. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct."

esttab col* using "$tab_dir/REG-comparemanipulation.tex", booktabs cells(none) nonum mgroups("TSST-G" "CPT" "CENT", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Effect" "N" "Effect" "N" "Effect" "N") stats(`statnames', labels(`varlabels')) note("`footnote'") prehead("`prehead'") postfoot("`postfoot'") compress wrap replace
esttab col* using "$tab_dir/REG-comparemanipulation-frag.tex", booktabs cells(none) nonum mgroups("TSST-G" "CPT" "CENT", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Effect" "N" "Effect" "N" "Effect" "N") stats(`statnames', labels(`varlabels')) compress wrap replace

eststo clear
