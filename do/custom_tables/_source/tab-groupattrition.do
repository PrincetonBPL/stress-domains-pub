** Title: tab-groupattrition.do
** Author: Justin Abraham
** Desc: Outputs tabulation of project participation by treatment group
** Input: UMIP Master.dta
** Output: tab-groupattrition.do

/* Create empty table */

clear all
eststo clear
estimates drop _all

loc columns = 4 // Change number of columns

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

use "$data_dir/Final/UMIP_FinalData_$S_DATE", clear

forval i = 1/3 {

	/* Column 1: Baseline */

	count if treatmentgroup == `i'
	estadd loc thisstat`count' = `r(N)': col1

	/* Column 2: Self-attrition */

	count if treatmentgroup == `i' & participation == 2
	estadd loc thisstat`count' = `r(N)': col2

	/* Column 3: Forced attrition */

	count if treatmentgroup == `i' & participation == 3
	estadd loc thisstat`count' = `r(N)': col3

	/* Column 4: Endline */
	
	count if treatmentgroup == `i' & participation == 1
	estadd loc thisstat`count' = `r(N)': col4

	/* Row Labels */
	
	loc statnames "`statnames' thisstat`count' thisstat`countse'"
	loc count = `count' + 2

}

/* Add scalars */

count
estadd local totN = `r(N)': col1
count if participation == 2
estadd local totN = `r(N)': col2
count if participation == 3
estadd local totN = `r(N)': col3
count if participation == 1
estadd local totN = `r(N)': col4

loc statnames "`statnames' totN" 

// add column totals

loc varlabels "Control " " Insurance " " UCT " " "\midrule Total""

esttab col* using "$output_dir/Tables/tab-groupattrition.tex", booktabs cells(none) nonum title(Treatment group by survey participation) mgroups("Participation", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Baseline" "\specialcell{Self-\\attrition}" "\specialcell{Forced\\attrition}" "Endline") stats(`statnames', labels(`varlabels')) compress replace

eststo clear

