** Title: reg-mills.do
** Author: Justin Abraham
** Desc: Outputs first stage Heckman estimation of the inverse Mills' ratio
** Output: reg-mills.tex


/* Create empty table */

clear all
eststo clear
estimates drop _all

set obs 10
gen x = 1
gen y = 1

loc columns = 1

foreach v in $heckvars {
	eststo col`columns': reg x y
	loc ++columns
}

eststo col`columns': reg x y

loc count = 1				// Cell first line
loc countse = `count' + 1	// Cell second line

loc statnames "" 			// Added scalars to be filled
loc varlabels "" 			// Labels for row vars to be filled

/* Custom fill cells */

use "$data_dir/Final/UMIP_FinalData_$S_DATE", clear

foreach yvar in $regvars {

	* Models to be displayed:

	gen svar = 0 if `yvar'_1 == .
	replace svar = 1 if svar == . 

	probit svar $heckvars

	drop svar

	loc i = 1

	foreach v in $heckvars {

		pstar `v', prec(2)
		estadd loc thisstat`count' = "`r(bstar)'": col`i'
		estadd loc thisstat`countse' = "`r(sestar)'": col`i'
		loc ++i

	}

	/* Column: Attrition rate */
	
	sum `yvar'_0
	loc N0 = r(N)	

	sum `yvar'_1
	loc N1 = r(N)

	estadd loc thisstat`count' = round((`N0'-`N1')/`N0',0.01): col`i'
	
	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar'_1 // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countp'"
	loc count = `count' + 3
	loc countse = `count' + 1

}


loc footnote "\emph{Notes:} Columns 1 - 5 report coefficients estimate from the first stage probit regression of the Heckman two-step procedure. Standard errors are in parentheses. Column 6 displays the attrition rates observed for each outcome variable."

esttab col* using "$output_dir/Tables/reg/$regpath.tex", booktabs cells(none) title($regtitle) mtitle("National ID" "Insured" "UCT" "\specialcell{High\\income group}" "\specialcell{Middle\\income group}" "\specialcell{Percent\\attrited}") stats(`statnames', labels(`varlabels')) note("`footnote'") postfoot("\hline \multicolumn{@span}{p{\linewidth}}{\footnotesize @note}\\ \end{tabular}\\ \end{table}") compress replace

eststo clear

