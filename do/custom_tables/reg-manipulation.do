** Title: reg-manipulation
** Author: Justin Abraham
** Desc: Outputs treatment effects regression for affective state across experiments
** Input: Appended dataset
** Output: reg-manipulation

use "$data_dir/FinalWide/$Stress_FinalWide_top", clear

eststo, prefix(check): reg mid_NAStot_z i.treatment##i.experiment pre_NAStot_z_full pre_NAStot_z_miss $yfillmiss, r cl(sessionnum)

	cap noisily: test 1.treatment + 1.treatment#1.experiment = 0
	if _rc estadd loc pval1 ""
	else {
		if _b[1.experiment] == 0 estadd loc pval1 ""
		else estadd loc pval1 = string(`r(p)', "%9.2f")
	}

	cap noisily: test 1.treatment + 1.treatment#3.experiment = 0
	if _rc estadd loc pval2 ""
	else {
		if _b[3.experiment] == 0 estadd loc pval2 ""
		else estadd loc pval2 = string(`r(p)', "%9.2f")
	}

	cap noisily: test 1.treatment#1.experiment = 1.treatment#3.experiment
	if _rc estadd loc pval3 ""
	else {
		if _b[1.experiment] == 0 | _b[3.experiment] == 0 estadd loc pval3 ""
		else estadd loc pval3 = string(`r(p)', "%9.2f")
	}

	estadd loc phase "Midline"
	estadd loc unit "Individual"
	estadd loc ar2 = string(`e(r2_a)', "%9.2f")

eststo, prefix(check): reg post_NAStot_z i.treatment##i.experiment pre_NAStot_z_full pre_NAStot_z_miss $yfillmiss, r cl(sessionnum)

	cap noisily: test 1.treatment + 1.treatment#1.experiment = 0
	if _rc estadd loc pval1 ""
	else {
		if _b[1.experiment] == 0 estadd loc pval1 ""
		else estadd loc pval1 = string(`r(p)', "%9.2f")
	}

	cap noisily: test 1.treatment + 1.treatment#3.experiment = 0
	if _rc estadd loc pval2 ""
	else {
		if _b[3.experiment] == 0 estadd loc pval2 ""
		else estadd loc pval2 = string(`r(p)', "%9.2f")
	}

	cap noisily: test 1.treatment#1.experiment = 1.treatment#3.experiment
	if _rc estadd loc pval3 ""
	else {
		if _b[1.experiment] == 0 | _b[3.experiment] == 0 estadd loc pval3 ""
		else estadd loc pval3 = string(`r(p)', "%9.2f")
	}

	estadd loc phase "Endline"
	estadd loc unit "Individual"
	estadd loc ar2 = string(`e(r2_a)', "%9.2f")

eststo, prefix(check): reg mid_stress_z i.treatment##i.experiment pre_stress_z_full pre_stress_z_miss $yfillmiss, r cl(sessionnum)

	cap noisily: test 1.treatment + 1.treatment#1.experiment = 0
	if _rc estadd loc pval1 ""
	else {
		if _b[1.experiment] == 0 estadd loc pval1 ""
		else estadd loc pval1 = string(`r(p)', "%9.2f")
	}

	cap noisily: test 1.treatment + 1.treatment#3.experiment = 0
	if _rc estadd loc pval2 ""
	else {
		if _b[3.experiment] == 0 estadd loc pval2 ""
		else estadd loc pval2 = string(`r(p)', "%9.2f")
	}

	cap noisily: test 1.treatment#1.experiment = 1.treatment#3.experiment
	if _rc estadd loc pval3 ""
	else {
		if _b[1.experiment] == 0 | _b[3.experiment] == 0 estadd loc pval3 ""
		else estadd loc pval3 = string(`r(p)', "%9.2f")
	}

	estadd loc phase "Midline"
	estadd loc unit "Individual"
	estadd loc ar2 = string(`e(r2_a)', "%9.2f")

eststo, prefix(check): reg post_stress_z i.treatment##i.experiment pre_stress_z_full pre_stress_z_miss $yfillmiss, r cl(sessionnum)

	cap noisily: test 1.treatment + 1.treatment#1.experiment = 0
	if _rc estadd loc pval1 ""
	else {
		if _b[1.experiment] == 0 estadd loc pval1 ""
		else estadd loc pval1 = string(`r(p)', "%9.2f")
	}

	cap noisily: test 1.treatment + 1.treatment#3.experiment = 0
	if _rc estadd loc pval2 ""
	else {
		if _b[3.experiment] == 0 estadd loc pval2 ""
		else estadd loc pval2 = string(`r(p)', "%9.2f")
	}

	cap noisily: test 1.treatment#1.experiment = 1.treatment#3.experiment
	if _rc estadd loc pval3 ""
	else {
		if _b[1.experiment] == 0 | _b[3.experiment] == 0 estadd loc pval3 ""
		else estadd loc pval3 = string(`r(p)', "%9.2f")
	}

	estadd loc phase "Endline"
	estadd loc unit "Individual"
	estadd loc ar2 = string(`e(r2_a)', "%9.2f")

use "$data_dir/FinalNAS/$Stress_FinalNAS_top", clear

eststo, prefix(check): reg mid_NAS_z i.treatment##i.experiment i.item pre_NAS_z_full pre_NAS_z_miss $yfillmiss, r cl(sessionnum)

	cap noisily: test 1.treatment + 1.treatment#1.experiment = 0
	if _rc estadd loc pval1 ""
	else {
		if _b[1.experiment] == 0 estadd loc pval1 ""
		else estadd loc pval1 = string(`r(p)', "%9.2f")
	}

	cap noisily: test 1.treatment + 1.treatment#3.experiment = 0
	if _rc estadd loc pval2 ""
	else {
		if _b[3.experiment] == 0 estadd loc pval2 ""
		else estadd loc pval2 = string(`r(p)', "%9.2f")
	}

	cap noisily: test 1.treatment#1.experiment = 1.treatment#3.experiment
	if _rc estadd loc pval3 ""
	else {
		if _b[1.experiment] == 0 | _b[3.experiment] == 0 estadd loc pval3 ""
		else estadd loc pval3 = string(`r(p)', "%9.2f")
	}

	estadd loc phase "Midline"
	estadd loc unit "Item"
	estadd loc ar2 = string(`e(r2_a)', "%9.2f")

eststo, prefix(check): reg post_NAS_z i.treatment##i.experiment i.item pre_NAS_z_full pre_NAS_z_miss $yfillmiss, r cl(sessionnum)

	cap noisily: test 1.treatment + 1.treatment#1.experiment = 0
	if _rc estadd loc pval1 ""
	else {
		if _b[1.experiment] == 0 estadd loc pval1 ""
		else estadd loc pval1 = string(`r(p)', "%9.2f")
	}

	cap noisily: test 1.treatment + 1.treatment#3.experiment = 0
	if _rc estadd loc pval2 ""
	else {
		if _b[3.experiment] == 0 estadd loc pval2 ""
		else estadd loc pval2 = string(`r(p)', "%9.2f")
	}

	cap noisily: test 1.treatment#1.experiment = 1.treatment#3.experiment
	if _rc estadd loc pval3 ""
	else {
		if _b[1.experiment] == 0 | _b[3.experiment] == 0 estadd loc pval3 ""
		else estadd loc pval3 = string(`r(p)', "%9.2f")
	}

	estadd loc phase "Endline"
	estadd loc unit "Item"
	estadd loc ar2 = string(`e(r2_a)', "%9.2f")

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{Treatment effects -- Affective state} \label{tab:REG-manipulation} \maxsizebox*{\textwidth}{\textheight}{ \begin{threeparttable} \begin{tabular}{l*{6}{c}} \toprule"

loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"

loc footnote "This table reports the coefficient estimates of the interaction between the treatment and experiment group. Standard errors are in parentheses. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct. level. We report the CPT and CENT \(p\)-values from an \(F\)-test of the treatment effect restricted to each experiment. We also report the \(p\)-value of an \(F\)-test comparing the treatment effect in CPT against the effect in CENT."

esttab check* using "$tab_dir/REG-manipulation.tex", booktabs mti("Affect" "Affect" "Stress" "Stress" "Affect" "Affect") b(%9.3f) se(%9.3f) wrap star(* 0.10 ** 0.05 *** 0.01) la keep(1.treatment 1.experiment 3.experiment 1.treatment#1.experiment 1.treatment#3.experiment) nodepvars scalars("unit Unit" "phase Phase" "ar2 Adjusted \(R^2\)" "pval1 CPT \(p\)-value" "pval2 CENT \(p\)-value" "pval3 CPT v. CENT \(p\)-value" "N N") sfmt(%9.0f %9.0f %9.2f %9.2f %9.2f %9.2f %9.0f) note("`footnote'") prehead("`prehead'") postfoot("`postfoot'") replace
esttab check* using "$tab_dir/REG-manipulation-frag.tex", booktabs mti("Affect" "Affect" "Stress" "Stress" "Affect" "Affect") b(%9.3f) se(%9.3f) wrap star(* 0.10 ** 0.05 *** 0.01) la keep(1.treatment 1.experiment 3.experiment 1.treatment#1.experiment 1.treatment#3.experiment) nodepvars scalars("unit Unit" "phase Phase" "ar2 Adjusted \(R^2\)" "pval1 CPT \(p\)-value" "pval2 CENT \(p\)-value" "pval3 CPT v. CENT \(p\)-value" "N N") sfmt(%9.0f %9.0f %9.2f %9.2f %9.2f %9.2f %9.0f) nonotes replace

eststo clear
