** Title: sum-unconditional.do
** Author: Justin Abraham
** Desc: Outputs baseline summary statistics (Mean SD Med Min Max N)
** Input: UMIP Master.dta
** Output: sum-unconditional.do

/* Create empty table */

clear all
eststo clear
estimates drop _all

loc columns = 6 //Change number of columns

set obs 10
gen x = 1
gen y = 1

forval i = 1/`columns' {
	eststo col`i': reg x y
}

loc count = 1

loc statnames "" // Added scalars to be filled
loc varlabels "" // Labels for row vars to be filled

/* Custom fill cells */

use "$data_dir/FinalCleaned_$stamp.dta", clear

foreach yvar in $sumvars {

	sum `yvar', d
	loc mean = `r(mean)'
	loc sd = `r(sd)'
	loc med = `r(p50)'
	loc min = `r(min)'
	loc max = `r(max)'
	loc N = `r(N)'

	/* Column 1: Mean */

	estadd loc thisstat`count' = round(`mean', 0.01): col1

	/* Column 2: SD */

	estadd loc thisstat`count' = round(`sd', 0.01): col2

	/* Column 3: Median */

	estadd loc thisstat`count' = round(`med', 0.01): col3

	/* Column 4: Min */
	
	estadd loc thisstat`count' = round(`min', 0.01): col4

	/* Column 5: Max */
	
	estadd loc thisstat`count' = round(`max', 0.01): col5

	/* Column 6: N */
	
	estadd loc thisstat`count' = `N': col6

	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar' // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse'"
	loc count = `count' + 2
	loc countse = `count' + 1

}

esttab col* using "$tab_dir/$sumpath.tex", booktabs cells(none) nonum title($sumtitle) mtitle("Mean" "SD" "Median" "Min" "Max" "N") stats(`statnames', labels(`varlabels')) compress wrap replace

eststo clear

