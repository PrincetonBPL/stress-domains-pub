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

forval colnum = 1/7 {
	eststo col`colnum': reg x y
}

/* Custom fill cells */

use "$data_dir/Final/UMIP_FinalData_$S_DATE", clear 

loc yvar $regvar

psmatch2 got_$treat if $treat | control, pscore(pscore_$treat) outcome(`yvar'_1) neighbor(1) ate
	loc att = r(att)
	loc seatt = r(seatt)
	loc atu = r(atu)
	loc seatu = r(seatu)
	loc ate = r(ate)
	loc seate = r(seate)



	count if _support
	estadd loc support `r(N)': col1

	pstar, b(`att') se(`seatt') prec(2)
	estadd loc thisstat1 = "`r(bstar)'": col1
	estadd loc thisstat2 = "`r(sestar)'": col1

	pstar, b(`atu') se(`seatu') prec(2)
	estadd loc thisstat4 = "`r(bstar)'": col1
	estadd loc thisstat5 = "`r(sestar)'": col1

	pstar, b(`ate') se(`seate') prec(2)
	estadd loc thisstat7 = "`r(bstar)'": col1
	estadd loc thisstat8 = "`r(sestar)'": col1

psmatch2 got_$treat if $treat | control, pscore(pscore_$treat) outcome(`yvar'_1) neighbor(5) ate
	loc att = r(att)
	loc seatt = r(seatt)
	loc atu = r(atu)
	loc seatu = r(seatu)
	loc ate = r(ate)
	loc seate = r(seate)



	count if _support
	estadd loc support `r(N)': col2

	pstar, b(`att') se(`seatt') prec(2)
	estadd loc thisstat1 = "`r(bstar)'": col2
	estadd loc thisstat2 = "`r(sestar)'": col2

	pstar, b(`atu') se(`seatu') prec(2)
	estadd loc thisstat4 = "`r(bstar)'": col2
	estadd loc thisstat5 = "`r(sestar)'": col2

	pstar, b(`ate') se(`seate') prec(2)
	estadd loc thisstat7 = "`r(bstar)'": col2
	estadd loc thisstat8 = "`r(sestar)'": col2

psmatch2 got_$treat if $treat | control, pscore(pscore_$treat) outcome(`yvar'_1) radius caliper(0.1) ate
	loc att = r(att)
	loc seatt = r(seatt)
	loc atu = r(atu)
	loc seatu = r(seatu)
	loc ate = r(ate)
	loc seate = r(seate)



	count if _support
	estadd loc support `r(N)': col3

	pstar, b(`att') se(`seatt') prec(2)
	estadd loc thisstat1 = "`r(bstar)'": col3
	estadd loc thisstat2 = "`r(sestar)'": col3

	pstar, b(`atu') se(`seatu') prec(2)
	estadd loc thisstat4 = "`r(bstar)'": col3
	estadd loc thisstat5 = "`r(sestar)'": col3

	pstar, b(`ate') se(`seate') prec(2)
	estadd loc thisstat7 = "`r(bstar)'": col3
	estadd loc thisstat8 = "`r(sestar)'": col3
	
psmatch2 got_$treat if $treat | control, pscore(pscore_$treat) outcome(`yvar'_1) radius caliper(0.05) ate
	loc att = r(att)
	loc seatt = r(seatt)
	loc atu = r(atu)
	loc seatu = r(seatu)
	loc ate = r(ate)
	loc seate = r(seate)



	count if _support
	estadd loc support `r(N)': col4

	pstar, b(`att') se(`seatt') prec(2)
	estadd loc thisstat1 = "`r(bstar)'": col4
	estadd loc thisstat2 = "`r(sestar)'": col4

	pstar, b(`atu') se(`seatu') prec(2)
	estadd loc thisstat4 = "`r(bstar)'": col4
	estadd loc thisstat5 = "`r(sestar)'": col4

	pstar, b(`ate') se(`seate') prec(2)
	estadd loc thisstat7 = "`r(bstar)'": col4
	estadd loc thisstat8 = "`r(sestar)'": col4
	
psmatch2 got_$treat if $treat | control, pscore(pscore_$treat) outcome(`yvar'_1) radius caliper(0.01) ate
	loc att = r(att)
	loc seatt = r(seatt)
	loc atu = r(atu)
	loc seatu = r(seatu)
	loc ate = r(ate)
	loc seate = r(seate)



	count if _support
	estadd loc support `r(N)': col5

	
	pstar, b(`att') se(`seatt') prec(2)
	estadd loc thisstat1 = "`r(bstar)'": col5
	estadd loc thisstat2 = "`r(sestar)'": col5

	pstar, b(`atu') se(`seatu') prec(2)
	estadd loc thisstat4 = "`r(bstar)'": col5
	estadd loc thisstat5 = "`r(sestar)'": col5

	pstar, b(`ate') se(`seate') prec(2)
	estadd loc thisstat7 = "`r(bstar)'": col5
	estadd loc thisstat8 = "`r(sestar)'": col5
	

psmatch2 got_$treat if $treat | control, pscore(pscore_$treat) outcome(`yvar'_1) kernel kerneltype(epan) ate
	loc att = r(att)
	loc seatt = r(seatt)
	loc atu = r(atu)
	loc seatu = r(seatu)
	loc ate = r(ate)
	loc seate = r(seate)



	count if _support
	estadd loc support `r(N)': col6

	
	pstar, b(`att') se(`seatt') prec(2)
	estadd loc thisstat1 = "`r(bstar)'": col6
	estadd loc thisstat2 = "`r(sestar)'": col6

	pstar, b(`atu') se(`seatu') prec(2)
	estadd loc thisstat4 = "`r(bstar)'": col6
	estadd loc thisstat5 = "`r(sestar)'": col6

	pstar, b(`ate') se(`seate') prec(2)
	estadd loc thisstat7 = "`r(bstar)'": col6
	estadd loc thisstat8 = "`r(sestar)'": col6
	

psmatch2 got_$treat if $treat | control, pscore(pscore_$treat) outcome(`yvar'_1) kernel kerneltype(normal) ate
	loc att = r(att)
	loc seatt = r(seatt)
	loc atu = r(atu)
	loc seatu = r(seatu)
	loc ate = r(ate)
	loc seate = r(seate)



	count if _support
	estadd loc support `r(N)': col7

	
	pstar, b(`att') se(`seatt') prec(2)
	estadd loc thisstat1 = "`r(bstar)'": col7
	estadd loc thisstat2 = "`r(sestar)'": col7

	pstar, b(`atu') se(`seatu') prec(2)
	estadd loc thisstat4 = "`r(bstar)'": col7
	estadd loc thisstat5 = "`r(sestar)'": col7

	pstar, b(`ate') se(`seate') prec(2)
	estadd loc thisstat7 = "`r(bstar)'": col7
	estadd loc thisstat8 = "`r(sestar)'": col7
	

	/* Row Labels */
	

loc varlabels " "ATT" " " "ATU" " " "ATE" " " "
loc statnames "thisstat1 thisstat2 thisstat4 thisstat5 thisstat7 thisstat8"

loc statnames "`statnames' support" 
loc varlabels "`varlabels' "\midrule No. in support" "


esttab col* using "$output_dir/Tables/reg/$regpath.tex", booktabs cells(none) mtitles("NN-1" "NN - 5" "Radius-0.1" "Radius-0.05" "Radius-0.01" "Epanechnikov" "Normal") title($regtitle) stats(`statnames', labels(`varlabels')) compress replace

eststo clear

