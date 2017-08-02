** Title: reg-time
** Author: Justin Abraham
** Desc: Outputs treatment effects regression for temporal discounting across experiments
** Input: Appended dataset
** Output: reg-time, reg-timeall

use "$data_dir/FinalTime/$Stress_FinalTime_top", clear

eststo, prefix(time): reg time_patient i.treatment##i.experiment i.time_horizon $yfillmiss if (time_horizon == 3 | time_horizon == 4 | time_horizon == 6 | time_horizon == 9), r cl(sessionnum)

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

	estadd loc unit "Item"
	estadd loc ar2 = string(`e(r2_a)', "%9.2f")
	estadd loc obs = `e(N)'

eststo, prefix(time): reg time_indiff i.treatment##i.experiment i.time_horizon $yfillmiss if (time_horizon == 3 | time_horizon == 4 | time_horizon == 6 | time_horizon == 9), r cl(sessionnum)

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

	estadd loc unit "Delay"
	estadd loc ar2 = string(`e(r2_a)', "%9.2f")
	estadd loc obs = `e(N)'

eststo, prefix(time): reg time_exponential i.treatment##i.experiment i.time_horizon $yfillmiss if (time_horizon == 3 | time_horizon == 4 | time_horizon == 6 | time_horizon == 9), r cl(sessionnum)

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

	estadd loc unit "Delay"
	estadd loc ar2 = string(`e(r2_a)', "%9.2f")
	estadd loc obs = `e(N)'

eststo, prefix(time): reg time_geometric i.treatment##i.experiment i.time_horizon $yfillmiss if (time_horizon == 3 | time_horizon == 4 | time_horizon == 6 | time_horizon == 9), r cl(sessionnum)

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

	estadd loc unit "Delay"
	estadd loc ar2 = string(`e(r2_a)', "%9.2f")
	estadd loc obs = `e(N)'

use "$data_dir/FinalWide/$Stress_FinalWide_top", clear

eststo, prefix(time): reg time_auc i.treatment##i.experiment $yfillmiss, r cl(sessionnum)

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

	estadd loc unit "Individual"
	estadd loc ar2 = string(`e(r2_a)', "%9.2f")
	estadd loc obs = `e(N)'

eststo, prefix(time): reg time_decrimp i.treatment##i.experiment $yfillmiss, r cl(sessionnum)

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

	estadd loc unit "Individual"
	estadd loc ar2 = string(`e(r2_a)', "%9.2f")
	estadd loc obs = `e(N)'

eststo, prefix(time): reg time_stationarity i.treatment##i.experiment $yfillmiss, r cl(sessionnum)

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

	estadd loc unit "Individual"
	estadd loc ar2 = string(`e(r2_a)', "%9.2f")
	estadd loc obs = `e(N)'

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{Treatment effects -- Temporal discounting} \label{tab:REG-time} \maxsizebox*{\textwidth}{\textheight}{ \begin{threeparttable} \begin{tabular}{l*{7}{c}} \toprule"

loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"

loc footnote "This table reports the coefficient estimates of the interaction between the treatment and experiment group. Standard errors are in parentheses. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct. level. We report the CPT and CENT \(p\)-values from an \(F\)-test of the treatment effect exclusive to each experiment. We also report the \(p\)-value of an \(F\)-test comparing the treatment effect in CPT against the effect in CENT."

esttab time1 time2 time3 time5 time6 time7 using "$tab_dir/REG-time.tex", booktabs mti("\specialcell{Patient\\choice}" "\specialcell{Indifference\\point}" "\specialcell{Exponential\\decay}" "AUC" "\specialcell{Dept. from\\stationarity}" "\specialcell{Decr.\\impatience}") b(%9.3f) se(%9.3f) wrap star(* 0.10 ** 0.05 *** 0.01) la keep(1.treatment 1.experiment 3.experiment 1.treatment#1.experiment 1.treatment#3.experiment) nodepvars stats(unit ar2 pval1 pval2 pval3 obs, fmt(%9.0f %9.0f %9.2f %9.2f %9.2f %9.0f) labels("Unit" "Adjusted \(R^2\)" "CPT \(p\)-value" "CENT \(p\)-value" "CPT vs. CENT \(p\)-value" "\(N\)")) note("`footnote'") prehead("`prehead'") postfoot("`postfoot'") replace
esttab time* using "$tab_dir/REG-timeall.tex", booktabs mti("\specialcell{Patient\\choice}" "\specialcell{Indifference\\point}" "\specialcell{Exponential\\decay}" "\specialcell{Geometric\\disc.}" "AUC" "\specialcell{Dept. from\\stationarity}" "\specialcell{Decr.\\impatience}") b(%9.3f) se(%9.3f) wrap star(* 0.10 ** 0.05 *** 0.01) la keep(1.treatment 1.experiment 3.experiment 1.treatment#1.experiment 1.treatment#3.experiment) nodepvars stats(unit ar2 pval1 pval2 pval3 obs, fmt(%9.0f %9.0f %9.2f %9.2f %9.2f %9.0f) labels("Unit" "Adjusted \(R^2\)" "CPT \(p\)-value" "CENT \(p\)-value" "CPT vs. CENT \(p\)-value" "\(N\)")) note("`footnote'") prehead("`prehead'") postfoot("`postfoot'") replace

esttab time1 time2 time3 time5 time6 time7 using "$tab_dir/REG-time-frag.tex", booktabs mti("\specialcell{Patient\\choice}" "\specialcell{Indifference\\point}" "\specialcell{Exponential\\decay}" "AUC" "\specialcell{Dept. from\\stationarity}" "\specialcell{Decr.\\impatience}") b(%9.3f) se(%9.3f) wrap star(* 0.10 ** 0.05 *** 0.01) la keep(1.treatment 1.experiment 3.experiment 1.treatment#1.experiment 1.treatment#3.experiment) nodepvars stats(unit ar2 pval1 pval2 pval3 obs, fmt(%9.0f %9.0f %9.2f %9.2f %9.2f %9.0f) labels("Unit" "Adjusted \(R^2\)" "CPT \(p\)-value" "CENT \(p\)-value" "CPT vs. CENT \(p\)-value" "\(N\)")) nonotes replace
esttab time* using "$tab_dir/REG-timeall-frag.tex", booktabs mti("\specialcell{Patient\\choice}" "\specialcell{Indifference\\point}" "\specialcell{Exponential\\decay}" "\specialcell{Geometric\\disc.}" "AUC" "\specialcell{Dept. from\\stationarity}" "\specialcell{Decr.\\impatience}") b(%9.3f) se(%9.3f) wrap star(* 0.10 ** 0.05 *** 0.01) la keep(1.treatment 1.experiment 3.experiment 1.treatment#1.experiment 1.treatment#3.experiment) nodepvars stats(unit ar2 pval1 pval2 pval3 obs, fmt(%9.0f %9.0f %9.2f %9.2f %9.2f %9.0f) labels("Unit" "Adjusted \(R^2\)" "CPT \(p\)-value" "CENT \(p\)-value" "CPT vs. CENT \(p\)-value" "\(N\)")) nonotes replace

eststo clear
