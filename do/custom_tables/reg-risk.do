** Title: reg-risk
** Author: Justin Abraham
** Desc: Outputs treatment effects regression for risk aversion across experiments
** Input: Appended dataset
** Output: reg-risk

use "$data_dir/FinalWide/$Stress_FinalWide_top", clear

eststo, prefix(risk): reg risk_crra i.treatment##i.experiment $yfillmiss, r cl(sessionnum)

	cap noisily: test 1.treatment + 1.treatment#3.experiment = 0
	if _rc estadd loc pval2 ""
	else {
		if _b[3.experiment] == 0 estadd loc pval2 ""
		else estadd loc pval2 = round(`r(p)', 0.01)
	}
	
	estadd loc unit "Individual"
	estadd loc ar2 = round(`e(r2_a)', 0.01)

eststo, prefix(risk): reg risk_avgratio i.treatment##i.experiment $yfillmiss, r cl(sessionnum)
	
	estadd loc unit "Individual"
	estadd loc ar2 = round(`e(r2_a)', 0.01)

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{Treatment effects -- Risk aversion} \label{tab:REG-risk} \maxsizebox*{\textwidth}{\textheight}{ \begin{threeparttable} \begin{tabular}{l*{2}{c}} \toprule"

loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"

loc footnote "This table reports the coefficient estimates of the interaction between the treatment and experiment group. Standard errors are in parentheses. * denotes significance at 10 pct., ** at 5 pct., and *** at 1 pct. level. We report the CPT and CENT \(p\)-values from an \(F\)-test of the treatment effect exclusive to each experiment. We also report the \(p\)-value of an \(F\)-test comparing the treatment effect in CPT against the effect in CENT."

esttab risk* using "$tab_dir/REG-risk.tex", booktabs mti("CRRA" "Risk Ratio") b(%9.3f) se(%9.3f) wrap star(* 0.10 ** 0.05 *** 0.01) la keep(1.treatment 3.experiment 1.treatment#3.experiment) nodepvars stats(unit ar2 pval2 N, fmt(%9.0f %9.2f %9.2f %9.0f) labels("Unit" "Adjusted \(R^2\)" "CENT \(p\)-value" "\(N\)")) note("`footnote'") prehead("`prehead'") postfoot("`postfoot'") replace
esttab risk* using "$tab_dir/REG-risk-frag.tex", booktabs mti("CRRA" "Risk Ratio") b(%9.3f) se(%9.3f) wrap star(* 0.10 ** 0.05 *** 0.01) la keep(1.treatment 3.experiment 1.treatment#3.experiment) nodepvars stats(unit ar2 pval2 N, fmt(%9.0f %9.2f %9.2f %9.0f) labels("Unit" "Adjusted \(R^2\)" "CENT \(p\)-value" "\(N\)")) nonotes replace

eststo clear