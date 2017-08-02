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
loc varindex = 1 // Index for p-value vector

/* FWER adjusted p-values */

use "$data_dir/FinalTime/$Stress_FinalTime_top", clear

gen treat = treatment

drop treat

/* Custom fill cells */

foreach yvar in time_patient time_indiff time_exponential time_geometric time_auc time_decrimp time_stationarity {

	loc column = 1

	foreach exp in exp_tsst exp_cpt exp_cpr {

		cap noi: reg `yvar' treatment $yfillmiss if `exp' & (time_horizon == 3 | time_horizon == 4 | time_horizon == 6 | time_horizon == 9), r cl(sessionnum)	

		if _rc == 0 {

			loc N = `e(N)'
			loc numplus = `column' + 1

			if strpos("`yvar'", "time_indiff") loc N = round(`N' / 5, 1)
			if strpos("`yvar'", "time_exponential") loc N = round(`N' / 5, 1)
			if strpos("`yvar'", "time_geometric") loc N = round(`N' / 5, 1)
			if strpos("`yvar'", "time_auc") loc N = round(`N' / 20, 1)
			if strpos("`yvar'", "time_decrimp") loc N = round(`N' / 20, 1)
			if strpos("`yvar'", "time_stationarity") loc N = round(`N' / 20, 1)

			estadd loc thisstat`count' = `N': col`numplus'

			pstar treatment, prec(2)
			estadd loc thisstat`count' = "`r(bstar)'": col`column'
			estadd loc thisstat`countse' = "`r(sestar)'": col`column'

			/* SUR */

			qui reg `yvar' treatment $yfillmiss if `exp' & (time_horizon == 3 | time_horizon == 4 | time_horizon == 6 | time_horizon == 9)
			loc yvarshort = substr("`yvar'", 10, .)
			est store `exp'_`yvarshort'

			/* Sample adjusted p-values */

			tempfile main
			save `main', replace

			use "$data_dir/Resampled/Stress_Resampled_$stamp.dta", clear

			qui reg `yvar' treatment $yfillmiss if `exp' & (time_horizon == 3 | time_horizon == 4 | time_horizon == 6 | time_horizon == 9), r cl(sessionnum)
			pstar treatment, prec(2) sestar sebrackets
			estadd local thisstat`countN' = "`r(sestar)'": col`column'

			use `main', clear

		}

		loc column = `column' + 2

	}

	loc thisvarlabel: variable label `yvar' // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countN' thisstat`space'"
	loc count = `count' + 4
	loc countse = `count' + 1
	loc countN = `countse' + 1
	loc ++varindex

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

loc statnames "`statnames' sur_p" 
loc varlabels "`varlabels' "\midrule Joint \(p\)-value" "

/* Table settings */

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{Domain-specific treatment effects -- Temporal discounting} \label{tab:REG-adjustedtime} \resizebox{\linewidth}{!}{ \begin{threeparttable} \begin{tabular}{l*{`columns'}{c}} \toprule"

loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"

loc footnote "This table summarizes the treatment effect of stressors on temporal discounting by experiment. Each cell reports the estimate and standard error from a regression of the row variable on the treatment. The second subcolumns report number of observations of each regression. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct."

esttab col* using "$tab_dir/REG-adjustedtime.tex", booktabs cells(none) nonum mgroups("TSST-G" "CPT" "CENT", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Effect" "N" "Effect" "N" "Effect" "N") stats(`statnames', labels(`varlabels')) note("`footnote'") prehead("`prehead'") postfoot("`postfoot'") compress wrap replace

eststo clear

