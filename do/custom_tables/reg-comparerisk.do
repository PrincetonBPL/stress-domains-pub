** Title: reg-compare
** Author: Justin Abraham
** Desc: Outputs treatment effects regression by experiment
** Input: Appended dataset
** Output: reg-compare

/* Create empty table */

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

/* Custom fill cells - wide data */

use "$data_dir/FinalWide/$Stress_FinalWide_top", clear

foreach yvar in risk_index risk_crra risk_avgratio {

	loc column = 1

	foreach exp in exp_tsst exp_cpt exp_cpr {

		cap noi: reg `yvar' treatment $yfillmiss if `exp', r cl(sessionnum)	

		if _rc == 0 {

			loc numplus = `column' + 1
			estadd loc thisstat`count' = `e(N)': col`numplus'

			pstar treatment, prec(2)
			estadd loc thisstat`count' = "`r(bstar)'": col`column'
			estadd loc thisstat`countse' = "`r(sestar)'": col`column'

			qui: reg `yvar' treatment $yfillmiss if `exp'
			est store `exp'_`yvar'

		}

		loc column = `column' + 2

	}

	loc thisvarlabel: variable label `yvar' // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countN'"
	loc count = `count' + 3
	loc countse = `count' + 1
	loc countN = `countse' + 1

}

/* SUR */

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

/* Custom fill cells - long risk data */

use "$data_dir/FinalRisk/$Stress_FinalRisk_top", clear

foreach yvar in risk_ratio_z {

	loc column = 1

	foreach exp in exp_tsst exp_cpt exp_cpr {

		cap noi: reg `yvar' treatment $yfillmiss if `exp', r cl(sessionnum)	

		if _rc == 0 {

			loc numplus = `column' + 1
			estadd loc thisstat`count' = `e(N)': col`numplus'

			pstar treatment, prec(2)
			estadd loc thisstat`count' = "`r(bstar)'": col`column'
			estadd loc thisstat`countse' = "`r(sestar)'": col`column'

		}

		loc column = `column' + 2

	}

	loc thisvarlabel: variable label `yvar' // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countN'"
	loc count = `count' + 3
	loc countse = `count' + 1
	loc countN = `countse' + 1

}

loc statnames "`statnames' sur_p" 
loc varlabels "`varlabels' "\midrule Joint \(p\)-value" "

/* Footnotes */

loc footnote "\emph{Notes:} This table summarizes the treatment effect of stressors on risk aversion by experiment. Each cell reports the estimate and standard error from a regression of the row variable on the treatment. The second subcolumns report number of observations of each regression. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct."

esttab col* using "$tab_dir/REG-comparerisk.tex", booktabs cells(none) nonum title("Domain-specific treatment effects -- Risk preferences") mgroups("TSST-G" "CPT" "CENT" "Overall", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Effect" "N" "Effect" "N" "Effect" "N" "Effect" "N") stats(`statnames', labels(`varlabels')) note("`footnote'") postfoot("\hline \multicolumn{@span}{p{\linewidth}}{\footnotesize @note}\\ \end{tabular}\\ \end{table}") compress wrap replace

eststo clear

