** Title: reg-pairwise.do
** Author: Justin Abraham
** Desc: Outputs simple table of coefficients for pairwise regressions
** Output: reg-pairwise.tex
** Arguments: regvars, xvars


/* Create empty table */

clear all
eststo clear
estimates drop _all

set obs 10
gen x = 1
gen y = 1

loc colnum = 1

foreach yvar in $xvars {
	eststo col`colnum': reg x y
	loc ++colnum
}

loc count = 1				// Cell first line
loc countse = `count' + 1	// Cell second line
loc countp = `countse' + 1  // Cell third line

loc statnames "" 			// Added scalars to be filled
loc varlabels "" 			// Labels for row vars to be filled
loc varindex = 1

/* Custom fill cells */

use "$data_dir/Final/UMIP_FinalData_$S_DATE", clear 

foreach yvar in $regvars {

	loc colnum = 1

	foreach xvar in $xvars {

		reg `yvar'_1 `xvar'_0 inc_highgroup_0 inc_midgroup_0 `yvar'_0, vce(robust)
		
		pstar `xvar'_0, prec(2)
		estadd loc thisstat`count' = "`r(bstar)'": col`colnum'
		estadd loc thisstat`countse' = "`r(sestar)'": col`colnum'

		loc ++colnum

	}
	
	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar'_1 // Extracts label from row var
	loc varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`p'"
	loc count = `count' + 2 // How many lines to afford each row variable
	loc countse = `count' + 1
	loc countp = `countse' + 1
	loc ++varindex

}

esttab col* using "$output_dir/Tables/reg/$regpath.tex", booktabs cells(none) nonum mtitle("Index" "Stress" "Optimism" "Self-esteem" "Depression" "LOC" "Happiness" "Satisfaction") title($regtitle) stats(`statnames', labels(`varlabels')) compress replace

eststo clear

