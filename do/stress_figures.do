** Title: Stress_Figures
** Author: Justin Abraham
** Desc: Create figures for publication

// Manipulation //

use "$data_dir/Stress_FinalWide.dta", clear

keep sid experiment sessionnum treatment pre_* mid_* post_*

/* reshape long @_stress, i(sid) j(time) */

// Temporal Discounting //

// Risk Aversion //

use "$data_dir/Stress_FinalWide.dta", clear

graph bar risk_crra if exp_cpr == 1, over(treatment) ytitle("Coefficient of relative risk aversion") ylabel(,glwidth(vvthin) glcolor(black)) bar(1, lcolor(black) fcolor(gs8)) bar(2, lcolor(black) fcolor(gs8)) graphregion(color(white))
graph export "$fig_dir/bar-crra.eps", replace
cap noi: !epstopdf "bar-crra.eps"
