** Title: Stress_Figures
** Author: Justin Abraham
** Desc: Create figures for publication

// Manipulation impulse response //

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

    #delimit ;

        tw
        (connected `var' period if treatment == 1, msymbol(o) color(black))
        (connected `var' period if treatment == 0, msymbol(oh) color(black) lpattern(dash))
        (rcap `var'_ub `var'_lb period, color(black)),
        ytitle(`:var la `var'') xtitle("")
        xlabel(0(1)2, valuelabel)
        legend(order(1 "Treatment" 2 "Control"))
        graphregion(color(white));
        gr export "$fig_dir/line-`var'.eps", replace;

    #delimit cr

}

// Temporal discounting treatment effect //

use "$data_dir/Stress_FinalWide.dta", clear
keep if exp_cpr == 1

foreach var of varlist $ytime {

    qui reg `var' treatment, vce(cl sessionnum)
    est sto `var'_est

    loc la_`var' "`: var la `var''"

}

collapse (mean) $ytime, by(treatment)
la val treatment la_treat

foreach var of varlist $ytime {

    est res `var'_est
    gen `var'_ub = `var' + _se[treatment] if treatment == 1
    gen `var'_lb = `var' - _se[treatment] if treatment == 1

    qui test treatment = 0
    loc startext ""
    if r(p) <= 0.10 loc startext "*"
    if r(p) <= 0.05 loc startext "**"
    if r(p) <= 0.01 loc startext "***"

    if (_b[_cons] + _b[treatment] < 0) {
        loc starpos = _b[_cons] + _b[treatment] - _se[treatment]
        loc starplace "s"
    }
    else {
        loc starpos = _b[_cons] + _b[treatment] + _se[treatment]
        loc starplace "n"
    }

    #delimit ;

        tw
        (bar `var' treatment if treatment == 0, lcolor(gs0) fcolor(gs8) barwidth(0.6))
        (bar `var' treatment if treatment == 1, lcolor(gs0) fcolor(gs8) barwidth(0.6))
        (rcap `var'_ub `var'_lb treatment, lcolor(gs0)),
        text(`starpos' 1 `"`startext'"', size(huge) place(`starplace'))
        ytitle(`la_`var'') xtitle("")
        ylabel(#6) xlabel(0(1)1, valuelabel)
        yscale(range(0))
        legend(off)
        graphregion(color(white));
        graph export "$fig_dir/bar-`var'.eps", replace;

    #delimit cr

}

// Plot discounting function //

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

    #delimit ;

        tw
        (connected `var' time_delaymo if time_immediate == 1 & treatment == 1, msymbol(o) color(black))
        (connected `var' time_delaymo if time_immediate == 1 & treatment == 0, msymbol(oh) color(black) lpattern(dash)) (scatter `var' time_delaymo if time_immediate == 0 & treatment == 1, msymbol(o) color(black))
        (scatter `var' time_delaymo if time_immediate == 0 & treatment == 0, msymbol(oh) color(black))
        (rcap `var'_ub `var'_lb time_delaymo, color(black)),
        ytitle(`:var la `var'') xtitle("Months")
        xlabel(0(3)12, valuelabel)
        legend(order(1 "Treatment" 2 "Control"))
        graphregion(color(white));
        gr export "$fig_dir/line-`var'.eps", replace;

    #delimit cr

}

// Risk aversion treatment effect //

use "$data_dir/Stress_FinalWide.dta", clear
keep if exp_cpr == 1

qui reg risk_crra treatment, vce(cl sessionnum)
est sto regest

collapse (mean) risk_crra, by(treatment)

la var risk_crra "Coefficient of relative risk aversion"
la val treatment la_treat

est res regest
gen risk_crra_ub = risk_crra + _se[treatment] if treatment == 1
gen risk_crra_lb = risk_crra - _se[treatment] if treatment == 1

qui test treatment = 0
loc startext ""
if r(p) <= 0.10 loc startext "*"
if r(p) <= 0.05 loc startext "**"
if r(p) <= 0.01 loc startext "***"

if (_b[_cons] + _b[treatment] < 0) {
    loc starpos = _b[_cons] + _b[treatment] - _se[treatment]
    loc starplace "s"
}
else {
    loc starpos = _b[_cons] + _b[treatment] + _se[treatment]
    loc starplace "n"
}

#delimit ;

    tw
    (bar risk_crra treatment if treatment == 0, lcolor(gs0) fcolor(gs8) barwidth(0.6))
    (bar risk_crra treatment if treatment == 1, lcolor(gs0) fcolor(gs8) barwidth(0.6))
    (rcap risk_crra_ub risk_crra_lb treatment, lcolor(gs0)),
    text(`starpos' 1 `"`startext'"', size(huge) place(`starplace'))
    ytitle("Coefficient of relative risk aversion") xtitle("")
    ylabel(#6) xlabel(0(1)1, valuelabel)
    yscale(range(0))
    legend(off)
    graphregion(color(white));
    graph export "$fig_dir/bar-risk_crra.eps", replace;

#delimit cr
