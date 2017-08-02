** Title: reg-hetero.do
** Author: Justin Abraham
** Desc: Outputs table of coefficients summarizing heterogeneous effects on all outcomes
** Output: het-yvar.tex each for both uct and insurance
** Arguments: regvars, intvars (must be binary), treatvar (main effect of interest)


/* Create empty table */

clear all
eststo clear
estimates drop _all

set obs 10
gen x = 1
gen y = 1

loc colnum = 1

foreach yvar in $regvars {
	eststo col`colnum': reg x y
	loc ++colnum
}

loc count = 1				// Cell first line
loc countse = `count' + 1	// Cell second line

loc statnames "" 			// Added scalars to be filled
loc varlabels "" 			// Labels for row vars to be filled
loc varindex = 1

loc surlist1 ""				// List of stored estimates for standard SUR
loc surlist2 ""				// List of stored estimates for Heckman SUR

/* Custom fill cells */

use "$data_dir/Final/UMIP_FinalData_$S_DATE", clear 

gen intuct = .
gen intinsured = .

foreach xvar in $intvars {

	loc colnum = 1
	replace intuct = uct * `xvar'_0
	replace intinsured = insured * `xvar'_0

	foreach yvar in $regvars {

		reg `yvar'_1 insured uct `xvar'_0 intinsured intuct inc_highgroup_0 inc_midgroup_0 `yvar'_0, vce(robust)
		
		pstar int$treatvar, prec(2)
		estadd loc thisstat`count' = "`r(bstar)'": col`colnum'
		loc ++colnum

	}
	
	/* Row Labels */
	
	loc thisvarlabel: variable label `xvar'_0 // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse'"
	loc count = `count' + 2 // How many lines to afford each row variable
	loc countse = `count' + 1
	loc ++varindex

}

drop intuct intinsured

/* Footnotes */

loc i = 1
loc footnote "\emph{Notes:} This table reports the coefficient estimates of the interaction between the treatment and each row variable. Each column corresponds to a unique dependent variable:"

foreach yvar in $regvars {

	loc varlabel: variable label `yvar'_1
	loc footnote "`footnote' (`i') `varlabel'"
	loc ++i

}

esttab col* using "$output_dir/Tables/reg/$regpath.tex", booktabs cells(none) nomtitles title($regtitle) stats(`statnames', labels(`varlabels')) note("`footnote'") postfoot("\hline \multicolumn{@span}{p{\linewidth}}{\footnotesize @note}\\ \end{tabular}\\ \end{table}") compress replace

eststo clear

