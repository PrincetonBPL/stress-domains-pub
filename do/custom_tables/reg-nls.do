** Title: reg-nls.do
** Author: Justin Abraham
** Desc: Estimates quasi-hyperbolic model with NLS for CENT experiment
** Input: Stress_FinalTime.dta
** Output: reg-nls.do

/* Create empty table */

preserve

clear
eststo clear
estimates drop _all

loc columns = 2

set obs 10
gen x = 1
gen y = 1

forval i = 1/`columns' {

	qui eststo col`i': reg x y

}

restore

/* NLS */

loc beta "(1-treatment)*{beta_control=1} + treatment*{beta_treat=0}"
loc delta "(1-treatment)*{delta_control=1} + treatment*{delta_treat=0}"

nl (time_indiff = time_immediate * (`beta') * (`delta')^time_delayyr + (1-time_immediate) * (`delta')^time_delayyr) if exp_cpr == 1, vce(cl sessionnum)

/* Fill table cells */

loc betaparm = string(_b[beta_treat:_cons], "%9.3f")
estadd loc betaparm = "`betaparm'": col1

loc betaparm = string(_b[beta_control:_cons], "%9.3f")
estadd loc betaparm = "`betaparm'": col2

loc betase = "(" + string(_se[beta_treat:_cons], "%9.3f") + ")"
estadd loc betase = "`betase'": col1

loc betase = "(" + string(_se[beta_control:_cons], "%9.3f") + ")"
estadd loc betase = "`betase'": col2

loc deltaparm = string(_b[delta_treat:_cons], "%9.3f")
estadd loc deltaparm = "`deltaparm'": col1

loc deltaparm = string(_b[delta_control:_cons], "%9.3f")
estadd loc deltaparm = "`deltaparm'": col2

loc deltase = "(" + string(_se[delta_treat:_cons], "%9.3f") + ")"
estadd loc deltase = "`deltase'": col1

loc deltase = "(" + string(_se[delta_control:_cons], "%9.3f") + ")"
estadd loc deltase = "`deltase'": col2

qui test _b[beta_treat:_cons] == 1
estadd loc betap = string(r(p), "%9.3f"): col1

qui test _b[beta_control:_cons] == 1
estadd loc betap = string(r(p), "%9.3f"): col2

qui test _b[delta_treat:_cons] == 1
estadd loc deltap = string(r(p), "%9.3f"): col1

qui test _b[delta_control:_cons] == 1
estadd loc deltap = string(r(p), "%9.3f"): col2

qui test _b[beta_treat:_cons] == _b[beta_control:_cons]
estadd loc betadiff = string(r(p), "%9.3f"): col1

qui test _b[delta_treat:_cons] == _b[delta_control:_cons]
estadd loc deltadiff = string(r(p), "%9.3f"): col1

loc varlabels ""\(\beta\)" " " "\(\delta\)" " " "\midrule \(\mathrm{H}_0: \beta = 1\)" "\(\mathrm{H}_0: \delta = 1\)" "\(\mathrm{H}_0: \beta_T = \beta_C\)" "\(\mathrm{H}_0: \delta_T = \delta_C\)""
loc statnames "betaparm betase deltaparm deltase betap deltap betadiff deltadiff"

/* Table settings */

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{NLS estimates of quasi-hyperbolic discounting for CENT} \label{tab:REG-nls} \maxsizebox*{\textwidth}{\textheight}{ \begin{threeparttable} \begin{tabular}{l*{`columns'}{c}} \toprule"
loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"
loc footnote "This table presents estimates for the \(\beta-\delta\) model for the treatment and control groups of the CENT experiment. Standard errors are clustered at the session level. We report \(p\)-values for each hypothesis test."

esttab col* using "$tab_dir/REG-nls.tex", booktabs cells(none) nonum mtitle("Treatment" "Control") stats(`statnames', labels(`varlabels')) prehead("`prehead'") postfoot("`postfoot'") note("`footnote'") substitute(\_ _) compress wrap replace
esttab col* using "$tab_dir/REG-nls-frag.tex", booktabs cells(none) nonum mtitle("Treatment" "Control") stats(`statnames', labels(`varlabels')) substitute(\_ _) compress wrap replace

eststo clear
