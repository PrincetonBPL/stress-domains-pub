** Title: Stress_Figures
** Author: Justin Abraham
** Desc: Create figures for publication

// Manipulation //

use "$data_dir/Stress_FinalWide.dta", clear
keep if exp_cpr == 1
keep sid experiment sessionnum treatment *_stress *_frust *_NAStot

reshape long @_stress @_frust @_NAStot, i(sid) j(prefix) s
ren _* *

encode prefix, gen(period)
replace period = 0 if period == 3

collapse (mean) stress frust NAStot (sem) stress_sem = stress frust_sem = frust NAStot_sem = NAStot, by(treatment period)
sort period treatment

la var period "Period"
la def la_period 0 "Baseline" 1 "Midline" 2 "Endline"
la val period la_period

la var stress "Self-reported stress"
la var frust "Frustration"
la var NAStot "Negative affect"

foreach var in stress frust NAStot {

    gen `var'_ub = `var' + `var'_sem
    gen `var'_lb = `var' - `var'_sem

    tw (connected `var' period if treatment == 1, msymbol(o) color(black)) (connected `var' period if treatment == 0, msymbol(oh) color(black) lpattern(dash)) (rcap `var'_ub `var'_lb period, color(black)), ytitle(`:var la `var'') xtitle("") xlabel(0(1)2, valuelabel) legend(order(1 "Treatment" 2 "Control")) graphregion(color(white))
    gr export "$fig_dir/line-`var'.eps", replace
    cap noi: !epstopdf "line_`var'.eps"

}

// Temporal Discounting //

use "$data_dir/Stress_FinalWide.dta", clear

foreach var of varlist $ytime {

    graph bar `var' if exp_cpr == 1, over(treatment) ytitle(`:var la `var'') bar(1, lcolor(black) fcolor(gs8)) bar(2, lcolor(black) fcolor(gs8)) graphregion(color(white))
    graph export "$fig_dir/bar-`var'.eps", replace
    cap noi: !epstopdf "bar-`var'.eps"

}

use "$data_dir/Stress_FinalTime.dta", clear
keep if exp_cpr == 1
keep sid experiment sessionnum treatment time_horizon time_delaymo time_immediate time_patient time_indiff time_exponential

collapse (mean) time_patient time_indiff time_exponential (sem) time_patient_sem = time_patient time_indiff_sem = time_indiff time_exponential_sem = time_exponential, by(treatment time_delaymo time_immediate)

la var time_patient "Patient choice"
la var time_indiff "Indifference point"
la var time_exponential "Exp. discount factor"

foreach var in time_patient time_indiff time_exponential {

    gen `var'_ub = `var' + `var'_sem
    gen `var'_lb = `var' - `var'_sem

    tw (connected `var' time_delaymo if time_immediate == 1 & treatment == 1, msymbol(o) color(black)) (connected `var' time_delaymo if time_immediate == 1 & treatment == 0, msymbol(oh) color(black) lpattern(dash)) (scatter `var' time_delaymo if time_immediate == 0 & treatment == 1, msymbol(o) color(black)) (scatter `var' time_delaymo if time_immediate == 0 & treatment == 0, msymbol(oh) color(black)) (rcap `var'_ub `var'_lb time_delaymo, color(black)), ytitle(`:var la `var'') xtitle("Months") xlabel(0(3)12, valuelabel) legend(order(1 "Treatment" 2 "Control")) graphregion(color(white))
    gr export "$fig_dir/line-`var'.eps", replace
    cap noi: !epstopdf "line_`var'.eps"

}

// Risk Aversion //

use "$data_dir/Stress_FinalWide.dta", clear

graph bar risk_crra if exp_cpr == 1, over(treatment) ytitle("Coefficient of relative risk aversion") bar(1, lcolor(black) fcolor(gs8)) bar(2, lcolor(black) fcolor(gs8)) graphregion(color(white))
graph export "$fig_dir/bar-risk_crra.eps", replace
cap noi: !epstopdf "bar-risk_crra.eps"
