** Title: Stress_summary
** Author: Justin Abraham
** Desc: Produces summary statistics and other descriptives
** Input: Stress_Final.dta
** Output: Tables

********************
** Balance checks **
********************

use "$data_dir/Stress_FinalWide.dta", clear

glo sumvars "$ydemo pre_stress pre_NAStot_z"
glo sumpath "SUM-balance"
glo sumtitle "Balance check -- Baseline demographics and affective state"

do "$do_dir/custom_tables/sum-balance.do"

glo sumvars "$yquest"
glo sumpath "SUM-questionnaire"
glo sumtitle "Balance check -- Endline demographics questionnaire"

do "$do_dir/custom_tables/sum-balance.do"

**************************************
** Summary statistics for lab tasks **
**************************************

/* CENT game summary statistics */

glo sumvars "cpr_avgtime cpr_avgpay cpr_randpay_?"
glo sumpath "SUM-centipede"
glo sumtitle "Summary statistics -- Centipede game results by treatment assignment"
do "$do_dir/custom_tables/sum-centfourway.do"

/* Patient choice by treatment and domain */

use "$data_dir/Stress_FinalTime.dta", clear

cap drop x y
gen x = 1
gen y = 1

eststo col1: qui reg y x
eststo col2: qui reg y x

loc count = 1
loc statnames "" // Added scalars to be filled
loc varlabels "" // Labels for row vars to be filled

sum time_patient if treatment & exp_tsst
estadd loc thisstat1 = string(`r(mean)', "%9.2f"):col1

sum time_patient if control & exp_tsst
estadd loc thisstat2 = string(`r(mean)', "%9.2f"):col2

sum time_patient if treatment & exp_cpt
estadd loc thisstat3 = string(`r(mean)', "%9.2f"):col1

sum time_patient if treatment
estadd loc thisstat4 = string(`r(mean)', "%9.2f"):col1

sum time_patient if control & exp_cpt
estadd loc thisstat1 = string(`r(mean)', "%9.2f"):col2

sum time_patient if treatment & exp_cpr
estadd loc thisstat2 = string(`r(mean)', "%9.2f"):col1

sum time_patient if control & exp_cpr
estadd loc thisstat3 = string(`r(mean)', "%9.2f"):col2

sum time_patient if control
estadd loc thisstat4 = string(`r(mean)', "%9.2f"):col2

loc prehead "\begin{table}[htbp]\centering \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \caption{Proportion of patient choices in temporal discounting task} \label{tab:SUM-patient} \maxsizebox*{\textwidth}{\textheight}{ \begin{threeparttable} \begin{tabular}{l*{2}{c}} \toprule"
loc postfoot "\bottomrule \end{tabular} \begin{tablenotes}[flushleft] \footnotesize \item \emph{Notes:} @note \end{tablenotes} \end{threeparttable} } \end{table}"
loc footnote "This table reports the proportion of choices made to accept the larger, later payments in the titration task."

esttab col* using "$tab_dir/SUM-patient.tex", booktabs cells(none) nonum mgroups("Assignment", pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Treatment" "Control") stats(thisstat1 thisstat2 thisstat3 thisstat4, labels("TSST-G" "CPT" "CENT" "\midrule Overall")) prehead("`prehead'") postfoot("`postfoot'") note("`footnote'") compress wrap replace
esttab col* using "$tab_dir/SUM-patient-frag.tex", booktabs cells(none) nonum mgroups("Assignment", pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("Treatment" "Control") stats(thisstat1 thisstat2 thisstat3 thisstat4, labels("TSST-G" "CPT" "CENT" "\midrule Overall")) compress wrap replace

drop x y
