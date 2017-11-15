** Title: Productivity_Clean
** Author: Justin Abraham
** Desc: Combines and cleans Z-Tree data from productivity experiment. Sourced from older script.
** Input: Bunch of excel files
** Output: Productivity_Cleaned_$stamp.dta

*****************************
** Clean demographics data **
*****************************

*Load Dataset to pull dates and participant numbers per session (only need to run this once)
/*use "Data12062013.dta", clear

sort session ztree
collapse (max) ztree, by(session)
export excel using demomatching, firstrow(var) replace
*/

* Clean Dataset
use "$data_dir/Prod_raw/demographics/_B05productivityDemoData3.dta", clear

* Drop obs from June 6th (Bad Data)
drop if session == 16

* Drop obs from June 7th (Bad Data)
drop if session == 17

replace sessionnumber = 1 if sessionnumber == .

* Split May 30 into 2 sessions
replace sessionnumber = 2 if session == 5 & identifystart <= clock("13:00:00", "hms")

* Split May 31 into 2 sessions
replace sessionnumber = 2 if session == 7 & identifystart <= clock("13:00:00", "hms")

* Fix July 26
replace session = 55 if session == 54

egen session2 = group(session sessionnumber)
order session2, after(session)

drop session
rename session2 sessionnum

* Fix June 19 Busara Number
replace busaranumber = 3 if personid == 161550
* Recreate ztree numbers
bysort sessionnum (busaranumber): gen ztree_subject = _n

*egen maxnum = max(ztree_subject), by(session)
*order maxnum

order ztree_subject
drop ztreeclientnumber

tempfile _B05productivityDemoDataFINAL
save `_B05productivityDemoDataFINAL', replace

**************************************************
*** Final data cleaning for Productivity Study ***
**************************************************

use "$data_dir/Prod_raw/raw_merged/Data12062013.dta", clear

*****************************
* Merge in Demographic Data *
*****************************
egen sessionnum = group(session)
merge 1:1 sessionnum ztree_subject using `_B05productivityDemoDataFINAL'
drop _merge

*************************************************************************************
*********************************** Data Cleaning ***********************************
*************************************************************************************
{
* Drop unecessary vars
drop pana*_rt*

* Recode difficulty
label define TaskDifficulty 0 "Easy" 1 "Difficult", modify
recode task_diff (1=0) (2=1)
la val task_diff TaskDifficulty
la var task_diff "Task Difficulty"

* Recode Questionnaire
recode quest_re7 quest_re8 quest_re9 quest_re10 quest_re11 (2=0)

* Generate accuracy scores
gen accuracy_1 = nctm1/effortpiecerate_counter
gen accuracy_2 = nctm2/efforttournament_counter
gen accuracy_3 = nctm3/efforttask3_counter

gen totaleffort = effortpiecerate_counter + efforttournament_counter + efforttask3_counter
gen totalaccuracy = nctm_total/totaleffort

* Generate WM score
egen totalwm = rowtotal(wm_correct*)

* Rename PANAS variables back to original (Linda had changed this in her last file)

rename distressed1 panas1_re1
rename upset1 panas1_re2
rename guilty1 panas1_re3
rename ashamed1 panas1_re4
rename hostile1 panas1_re5
rename irritable1 panas1_re6
rename nervous1 panas1_re7
rename jittery1 panas1_re8
rename scared1 panas1_re9
rename afraid1 panas1_re10
rename pain1 panas1_re11
rename stressed1 panas1_re12

rename pain2 panas2_re1
rename stressed2 panas2_re2

rename distressed3 panas3_re1
rename upset3 panas3_re2
rename guilty3 panas3_re3
rename ashamed3 panas3_re4
rename hostile3 panas3_re5
rename irritable3 panas3_re6
rename nervous3 panas3_re7
rename jittery3 panas3_re8
rename scared3 panas3_re9
rename afraid3 panas3_re10
rename pain3 panas3_re11
rename stressed3 panas3_re12

* Create aggreagated PANAS indicies
egen panas1_agg = rowtotal(panas1_re*)
egen panas3_agg = rowtotal(panas3_re*)
gen panas1_small = panas1_re11 + panas1_re12
gen panas2_small = panas2_re1 + panas2_re2
gen panas3_small = panas3_re11 + panas3_re12
gen diff1_VAS11 = panas3_re11 - panas1_re11
gen diff1_VAS12 = panas3_re12 - panas1_re12
gen diff2_VAS11 = panas2_re1 - panas1_re11
gen diff2_VAS12 = panas2_re2 - panas1_re12
gen diff3_VAS11 = panas3_re11 - panas2_re1
gen diff3_VAS12 = panas3_re12 - panas2_re2
gen panasdiff_agg = panas3_agg - panas1_agg
gen panasdiff21 = panas2_small - panas1_small
gen panasdiff32 = panas3_small - panas2_small
gen panasdiff31 = panas3_small - panas1_small

* Create "Normal" PANAS indicies
gen panas1 = panas1_agg - panas1_re11 - panas1_re12
gen panas3 = panas3_agg - panas3_re11 - panas3_re12
gen panasdiff = panas3 - panas1

rename stress_d stress

* Code Questionnaires *
/*
1= Height
2= Weight
3= Siblings
4= Income
5= Spending
6= Dependents
7= Supported
8= Employment
9= Debt
10= Smoke
11= Drink
12= Wake

In the pre-analysis, we specified Education, BMI, Age, Children (dependents), Income, Disposable, Debt.
*/
* Update Weights for mistyped entries
replace quest_re2 = 66 if quest_re2 == 667
replace quest_re2 = 75 if quest_re2 == 775

* Update Dependents for mistyped entries
replace quest_re6 = 8 if quest_re6 == 88
replace quest_re6 = 6 if quest_re6 == 556

* Add Age & BMI
gen age = 2013 - birthyear
gen BMI = quest_re2/[(quest_re1/100)^2]

*** Labeling Variables ***
la var nctm1 "NC, Piece Rate"
la var nctm2 "NC, Tournament"
la var nctm3 "NC, Choice"
la var nctm_total "NC, Total"

la var effortpiecerate_counter "Effort, Piece Rate"
la var efforttournament_counter "Effort, Tournament"
la var efforttask3_counter "Effort, Choice"
la var totaleffort "Effort, Total"

la var accuracy_1 "Accuracy, Piece Rate"
la var accuracy_2 "Accuracy, Tournament"
la var accuracy_3 "Accuracy, Choice"
la var totalaccuracy "Accuracy, Total"

la var Order "Treatment Order"
la var task_diff "Task Difficulty"
la var task3_d "Choice"
la var grp_size "Group Size"

la var riskpreference_amountinvested "Risk Amt"
la var totalwm "Working Memory"
la var Belief_pr "Belief, PR"
la var Belief_tn "Belief, TN"
la var Winner_tn "TN Winner"

la var quest_re1 "Height"
la var quest_re2 "Weight"
la var quest_re3 "Siblings"
la var quest_re4 "Income"
la var quest_re5 "Spending"
la var quest_re6 "Dependents"
la var quest_re7 "Supported"
la var quest_re8 "Employment"
la var quest_re9 "Debt"
la var quest_re10 "Smoke"
la var quest_re11 "Drink"
la var quest_re12 "Wake"

la var Treat "Treatment Type"
la def treat 1 "Treatment" 0 "Control"
la val Treat treat

order sessionnum sid group_id Order nctm*
rename session sessionname
rename effortpiecerate_counter effort1
rename efforttournament_counter effort2
rename efforttask3_counter effort3
rename Belief_pr belief1
rename Belief_tn belief2
gen belief3 =.
rename rank_pr rank1
rename rank_tn rank2
gen rank3 =.
rename inc_guess_pr inc_guess1
rename inc_guess_tn inc_guess2
gen inc_guess3 = .

gen rankerror1 = (rank1-belief1)/grp_size
gen rankerror2 = (rank2-belief2)/grp_size
gen rankerror3 = .

gen overconf1 = 0
replace overconf1 = 1 if rankerror1>0
gen overconf2 = 0
replace overconf2 = 1 if rankerror2>0
gen overconf3 = .

drop if sid == .

**************************
** Harmonize for append **
**************************

forval i = 1/12 {
	ren panas1_re`i' pre_VAS`i'
	ren panas3_re`i' post_VAS`i'
}

ren panas2_re1 mid_VAS11
ren panas2_re2 mid_VAS12

saveold "$data_dir/Productivity_Cleaned.dta", replace
}

***********
* Reshape *
***********

*** Keep variables ***
keep sessionnum sessionname stress group_id sid nctm1 nctm2 nctm3 nctm_total accuracy_1 accuracy_2 accuracy_3 totalaccuracy ///
effort1 effort2 effort3 belief* rank* inc_guess* rankerror* overconf* totaleffort ///
riskpreference_amountinvested totalwm task3_d ///
Order task_diff grp_size panas1_agg panas3_agg panas1_small panas2_small panas3_small ///
panasdiff panasdiff21 panasdiff32 panasdiff31 Treat quest_re*  ///
BMI age identifydate-beforeattend

reshape long nctm effort belief accuracy_ rank rankerror overconf inc_guess, i(sid) j(type)

rename accuracy_ accuracy
la def type 1 "PieceRate" 2 "Tourney" 3 "Choice"
la val type type
rename group_id session

tab task_diff, gen(task)
rename task1 task_easy
rename task2 task_difficult
la var task_easy "Easy"
la var task_difficult "Difficult"

*Gen dummies for treatxeasy and treatxdifficult
gen treatxeasy = Treat*task_easy
gen treatxdifficult = Treat*task_difficult
la var treatxeasy "TreatmentXEasy"
la var treatxdifficult "TreatmentXDifficult"

gen tourney = 1 if type==2
recode tourney (.=0)
la var tourney "Tournament"

gen treatnumber = 0
replace treatnumber = type if Order ==1
replace treatnumber = type if type == 3
replace treatnumber = 1 if type == 2 & Order == 2
replace treatnumber = 2 if type == 1 & Order == 2
order treatnumber, after(Order)

order identifydate-beforeattend, after(tourney)

saveold "$data_dir/Productivity_CleanedPanel.dta", replace
