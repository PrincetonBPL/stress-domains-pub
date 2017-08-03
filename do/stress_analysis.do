** Title: Stress_Analysis
** Author: Justin Abraham
** Desc: Computes regressions
** Input: Stress_Final.dta
** Output: Regular regression tables and summary regression tables

////////////////////////
// Manipulation check //
////////////////////////

if $nasflag {

	use "$data_dir/Stress_FinalWide.dta", clear

	glo yfillmiss ""

	/* Treatment effect */

	glo regvars "mid_stress_r"
	glo regtitle "Treatment effects across experiments -- Stress"
	glo regpath "REG-manipulation"
	do "$do_dir/custom_tables/reg-comparetreat.do"

	/* Control variables */

	glo yfillmiss ""

	foreach v in $ycontrol pre_stress_r {

		glo yfillmiss "$yfillmiss `v'_full `v'_miss"

	}

	/* Treatment effect with controls */

	glo regvars "mid_stress_r"
	glo regtitle "Treatment effects with covariate adjustment -- Stress"
	glo regpath "REG-manipulationcontrols"
	do "$do_dir/custom_tables/reg-comparetreat.do"

	/* Randomization inference */

	glo regvars "mid_stress_r"
	glo regtitle "Treatment effects with randomization inference -- Stress"
	glo regpath "REG-manipulationrand"
	/* do "$do_dir/custom_tables/reg-randtreat.do" */

}

//////////////////////
// Time preferences //
//////////////////////

if $timeflag {

	use "$data_dir/Stress_FinalWide.dta", clear

	glo yfillmiss ""

	/* Treatment effect */

	glo regvars "$ytime"
	glo regtitle "Treatment effects across experiments -- Temporal discounting"
	glo regpath "REG-time"
	do "$do_dir/custom_tables/reg-comparetreat.do"

	/* Control variables */

	glo yfillmiss ""

	foreach v in $ycontrol {

		glo yfillmiss "$yfillmiss `v'_full `v'_miss"

	}

	/* Treatment effect */

	glo regvars "$ytime"
	glo regtitle "Treatment effects with covariate adjustment -- Temporal discounting"
	glo regpath "REG-timecontrols"
	do "$do_dir/custom_tables/reg-comparetreat.do"

	/* Randomization inference */

	glo regvars "$ytime"
	glo regtitle "Treatment effects with randomization inference -- Temporal discounting"
	glo regpath "REG-timerand"
	/* do "$do_dir/custom_tables/reg-randtreat.do" */

	/* By time horizon */

	use "$data_dir/Stress_FinalTime.dta", clear
	keep if (time_horizon == 3 | time_horizon == 4 | time_horizon == 6 | time_horizon == 9)

	do "$do_dir/custom_tables/reg-timehorizon.do"

}

//////////////////////
// Risk preferences //
//////////////////////

if $riskflag {

	use "$data_dir/Stress_FinalWide.dta", clear

	glo yfillmiss ""

	/* Treatment effect */

	glo regvars "$yrisk"
	glo regtitle "Treatment effects across experiments -- Risk aversion"
	glo regpath "REG-risk"
	do "$do_dir/custom_tables/reg-comparetreat.do"

	/* Control variables */

	glo yfillmiss ""

	foreach v in $ycontrol {

		glo yfillmiss "$yfillmiss `v'_full `v'_miss"

	}

	/* Treatment effect with controls */

	glo regvars "$yrisk"
	glo regtitle "Treatment effects with covariate adjustment -- Risk aversion"
	glo regpath "REG-riskcontrols"
	do "$do_dir/custom_tables/reg-comparetreat.do"

}
