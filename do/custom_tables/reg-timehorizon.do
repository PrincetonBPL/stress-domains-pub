** Title: reg-timehorizon
** Author: Justin Abraham
** Desc: Outputs treatment effects by time horizon
** Input: Appended dataset
** Output: reg-timehorizon

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
	qui eststo col`i': reg x y
}

loc count = 1
loc countse = `count' + 1
loc countN = `countse' + 1

loc statnames "" // Added scalars to be filled
loc varlabels "" // Labels for row vars to be filled

/* Custom fill cells */

restore

foreach exp in exp_tsst exp_cpt exp_cpr {

	loc groupla : var la `exp'
	loc thisvarlabel "\textit{`groupla'}"

	local varlabels "`varlabels' "`thisvarlabel'" " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse'"
	loc count = `count' + 2
	loc countse = `count' + 1
	loc countN = `countse' + 1

	foreach yvar in time_patient time_indiff time_exponential time_auc time_stationarity time_decrimp {

		loc column = 1

		foreach time in 3 4 6 9 {

			qui reg `yvar' treatment $yfillmiss if time_horizon == `time' & `exp', r cl(sessionnum)
			loc N = `e(N)'

			if strpos("`yvar'", "time_patient") == 1 loc N = `e(N)'
			else {

				if strpos("`yvar'", "time_indiff") | strpos("`yvar'", "time_exponential") | strpos("`yvar'", "time_geometric") loc N = round(`e(N)' / 5, 1)
				else loc N = round(`e(N)' / 5, 1)

			}

			pstar treatment, prec(2)
			estadd loc thisstat`count' = "`r(bstar)'": col`column'
			estadd loc thisstat`countse' = "`r(sestar)'": col`column'

			qui reg `yvar' treatment $yfillmiss if time_horizon == `time' & `exp'
			est store `exp'_`yvar'`column'

			loc ++column

		}

		/* Sample Size */

		estadd loc thisstat`count' = "`N'": col5

		/* SUR */

		suest `exp'_`yvar'*, r cl(sessionnum)

		qui test treatment
		pstar, p(`r(p)') pstar pnopar prec(2)
		estadd local thisstat`count' = "`r(pstar)'": col6

		/* Load names and stats */

		loc thisvarlabel: variable label `yvar' // Extracts label from row var
		local varlabels "`varlabels' "`thisvarlabel'" " " "
		loc statnames "`statnames' thisstat`count' thisstat`countse'"
		loc count = `count' + 2
		loc countse = `count' + 1
		loc countN = `countse' + 1

	}

}

/* Table settings */

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{Treatment effects on temporal discounting by time horizon} \label{tab:REG-timehorizon} \maxsizebox*{\textwidth}{\textheight}{ \begin{threeparttable} \begin{tabular}{l*{`columns'}{c}} \toprule"

loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"

loc footnote "This table summarizes the treatment effect of stressors on temporal discounting by experiment and by time horizon. Each cell reports the estimate and standard error from a regression of the row variable on the treatment conditional on the time horizon indicated by the column. The last two columns report the number of observations of each regression and a joint test across of the treatment effect across time horizons. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct."

esttab col* using "$tab_dir/REG-timehorizon.tex", booktabs cells(none) nonum mtitle("\specialcell{0 mo.\\-- 3 mo.}" "\specialcell{0 mo.\\-- 6 mo.}" "\specialcell{0 mo.\\-- 12 mo.}" "\specialcell{6 mo.\\-- 12 mo.}" "N" "\specialcell{Joint\\\(p\)-value}") stats(`statnames', labels(`varlabels')) note("`footnote'") prehead("`prehead'") postfoot("`postfoot'") compress wrap replace
esttab col* using "$tab_dir/REG-timehorizon-frag.tex", booktabs cells(none) nonum mtitle("\specialcell{0 mo.\\-- 3 mo.}" "\specialcell{0 mo.\\-- 6 mo.}" "\specialcell{0 mo.\\-- 12 mo.}" "\specialcell{6 mo.\\-- 12 mo.}" "N" "\specialcell{Joint\\\(p\)-value}") stats(`statnames', labels(`varlabels')) compress wrap replace

eststo clear
