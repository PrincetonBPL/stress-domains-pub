** Title: reg-rdadjusted.do
** Author: Justin Abraham
** Desc: Outputs regression tables with FWER adjusted p-values for restricted sample
** Input: UMIP Master.dta
** Output: reg-rdadjusted.tex

/* Create empty table */

clear all
eststo clear
estimates drop _all

loc columns = 9

set obs 10
gen x = 1
gen y = 1

forval i = 1/`columns' {
	eststo col`i': reg x y
}

loc count = 1				// Cell first line
loc countse = `count' + 1	// Cell second line
loc countp = `countse' + 1  // Cell third line

loc statnames "" 			// Added scalars to be filled
loc varlabels "" 			// Labels for row vars to be filled
loc varindex = 1

loc surlist1 ""				// List of stored estimates for standard SUR
loc surlist2 ""				// List of stored estimates for Heckman SUR

/* Stepdown procedure */

use "$data_dir/Final/UMIP_FinalData_$S_DATE", clear

loc basevars ""
loc endvars ""

foreach v in $regvars {
	loc basevars "`basevars' `v'_0"
	loc endvars "`endvars' `v'_1"
}

stepdown reg (`endvars') uct insured inc_highgroup_0 inc_midgroup_0 `basevars', iter($iterations)	
mat A = r(p)
stepdown reg (`endvars') insured uct inc_highgroup_0 inc_midgroup_0 `basevars', iter($iterations)	
mat B = r(p) 

/* Custom fill cells */

foreach yvar in $regvars {

	* Model to be displayed:
	reg `yvar'_1 uct insured inc_highgroup_0 inc_midgroup_0 `yvar'_0
	est store spec1_`varindex'
	loc surlist1 "`surlist1' spec1_`varindex'"
	loc N = `e(N)'

	/* Column 1: Insurance */


	pstar insured, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col1
	estadd loc thisstat`countse' = "`r(sestar)'": col1
	loc p_adj = B[1, `varindex']
	pstar, p(`p_adj') prec(2) pbracket pstar
	estadd local thisstat`countp' = "`r(pstar)'": col1

	/* Column 2: UCT */

	pstar uct, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col2
	estadd loc thisstat`countse' = "`r(sestar)'": col2
	loc p_adj = A[1, `varindex']
	pstar, p(`p_adj') prec(2) pbracket pstar
	estadd local thisstat`countp' = "`r(pstar)'": col2


	/* Column 3: UCT vs Ins */

	test uct = insured
	pstar, p(`r(p)') prec(2) pbracket pstar pnopar
	estadd loc thisstat`count' = "`r(pstar)'": col3

	* Model to be displayed:
	heckman `yvar'_1 uct insured inc_highgroup_0 inc_midgroup_0 `yvar'_0, select($heckvars) twostep
	est store spec2_`varindex'

	loc surlist2 "`surlist2' spec2_`varindex'"
	loc lambda = e(lambda)
	loc selambda = e(selambda)
	loc plambda = (2 * ttail(e(df_m), abs(`lambda'/`selambda')))

	/* Column 4: Heckman Ins */

	pstar insured, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col4
	estadd loc thisstat`countse' = "`r(sestar)'": col4

	/* Column 5: Heckman UCT */
	
	pstar uct, prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col5
	estadd loc thisstat`countse' = "`r(sestar)'": col5
	
	/* Column 6: Heckman UCT vs Ins */
	
	test uct = insured
	pstar, p(`r(p)') prec(2) pbracket pstar pnopar
	estadd loc thisstat`count' = "`r(pstar)'": col6

	/* Column 7: Heckman Mills coefficient */

	pstar, b(`lambda') se(`selambda') p(`plambda') prec(2)
	estadd loc thisstat`count' = "`r(bstar)'": col7
	estadd loc thisstat`countse' = "`r(sestar)'": col7

	/* Column 8: Control Mean */

	sum `yvar'_1 if control 
	estadd loc thisstat`count' = round(`r(mean)', 0.01): col8
	pstar, se(`r(sd)') prec(2)
	estadd loc thisstat`countse' = "`r(sestar)'": col8

	/* Column 9: N */

	estadd loc thisstat`count' = `N': col9
	
	/* Row Labels */
	
	loc thisvarlabel: variable label `yvar'_1 // Extracts label from row var
	local varlabels "`varlabels' "`thisvarlabel'" " " " " "
	loc statnames "`statnames' thisstat`count' thisstat`countse' thisstat`countp'"
	loc count = `count' + 3
	loc countse = `count' + 1
	loc countp = `countse' + 1
	loc ++varindex

}

	/* SUR Joint Tests */

	suest `surlist1'

	test insured
 	pstar, p(`r(p)') pstar pnopar prec(2)
 	estadd local sur_p "`r(pstar)'": col1
	test uct 
 	pstar, p(`r(p)') pstar pnopar prec(2)
 	estadd local sur_p "`r(pstar)'": col2	
	test uct = insured
 	pstar, p(`r(p)') pstar pnopar prec(2)
 	estadd local sur_p "`r(pstar)'": col3

 	/*
 	suest `surlist2'

	test uct 
 	pstar, p(`r(p)') pstar prec(2)
 	estadd local sur_p "`r(pstar)'": col4
	test insured
 	pstar, p(`r(p)') pstar prec(2)
 	estadd local sur_p "`r(pstar)'": col5	
	test uct = insured
 	pstar, p(`r(p)') pstar prec(2)
 	estadd local sur_p "`r(pstar)'": col6		
	*/
	
	loc statnames "`statnames' sur_p" 
	loc varlabels "`varlabels' "\midrule Joint (\emph{p}-value)" "

	loc footnote "Columns 1 - 2 report results from the regular intent-to-treat analysis without correcting for selection. Columns 4 - 5 report results from the second stage regression in the Heckman two-stage method. Column 7 reports the coefficient for the inverse Mills' ratio in the second stage. Columns 3 and 6 report the \emph{p}-values for Wald tests of the equality of the UCT and insurance effects after estimation. Standard errors are in parentheses and the FWER adjusted \emph{p}-values are in brackets."

/* Add scalars */

esttab col* using "$output_dir/Tables/reg/$regpath.tex", booktabs cells(none) title($regtitle) mgroups("ITT" "ITT + Heckman Two-Stage" "Sample", pattern(1 0 0 1 0 0 0 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Insurance" "UCT" "\specialcell{Difference\\\emph{p}-value}" "Insurance" "UCT" "\specialcell{Difference\\\emph{p}-value}" "\specialcell{Mills'\\Coefficient}" "\specialcell{Control Mean\\(SD)}" "N") stats(`statnames', labels(`varlabels')) note("`footnote'") postfoot("\hline \multicolumn{@span}{p{\linewidth}}{\footnotesize @note}\\ \end{tabular}\\ \end{table}") compress replace

eststo clear

