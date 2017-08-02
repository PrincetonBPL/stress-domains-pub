* Syntax: managedata, [OLDtonew] [PREPOnly] [Prepmanipula] [AUXdo(filename)] [Raw] [Survey] [BCComplete] [Audit] [Backcheck] [DIRdate(integer)]
*	[pause] [MAXDate(integer)] [lag(integer)] [IGnoresiddups] [REView] [SHOWknown]
* Manages the data.
* - Specify option oldtonew to manage the conversion from old Blaise data models to new ones.
*	- To prepare the conversion and then stop, specify option preponly.
* - Specify option prepmanipula to prepare the Manipula progams used to convert Blaise databases of recent program versions to Stata.
*	- Option maxdate. A "date directory" is a directory named after a particular date, e.g., "03.15.2011" for Mar 15, 2011. The FOs' archived data
*	  is stored in date directories, where the date corresponds to the date that USB to Dropbox was run for the data. Specify option maxdate to use
*	  Blaise databases from the FOs' most recent "date directories" no later than "maxdate". E.g., if there are date directories for Mar 15 and Mar 
*	  17 and "maxdate" is set to Mar 16, data from the date directory Mar 15 is used. Caution must be used when using maxdate, because the program
*	  versions in past date directories may be outdated, which would cause option raw to fail unless the Manipula programs are replaced.
* - Specify option raw to run the Manipula programs and convert the Blaise data to Stata.
*	- To pause after Manipula programs (for both old-to-new and Blaise-to-Stata), specify option pause.
* - To run an additional do-file before running the Manipula programs, specify the do-file in option auxdo. If no directory is provided for the
*	do-file, the data directory is assumed (execute "mdparam get datadir" to see what this is).
* - Specify option survey to manage the survey data.
*	- To generate the output for the BC/complete list for the day, specify option bccomplete. Not that you cannot produce more than BC/complete list
*	  on the same day unless you first delete the output in the date directory (see below), "back_checks_c.csv". managedata cannot delete this file
*	  for you. Deletion of back_checks_c.csv should be rare, and it is highly recommended that "managedata, survey" be executed and all issues
*	  resolved before "managedata, survey bccomplete" is executed.
*   - To ignore survey ID duplicates in the survey data, skipping checks that require a non-duplicated survey ID, specify option ignoresiddups. This
*	  is a good choice if someone unfamiliar with the programs is running them, e.g., to produce the checks while the PA is on leave.
*	- To quit after certain data issues are discovered (e.g., interviews missing key values), specify option review.
* - Specify option audit to manage the audit data.
* - Specify option backcheck to manage the back check data.
*	- These options are specifiable with options survey, audit, and backcheck:
*	  - Set "lag" to the number of days that have passed since the ado should have been run but wasn't (including weekends and other non-working
*		days). Checks will be done for these days, and in survey.ado, output for the consent/salivette checks will include these days.
*	  - Specify maxdate to exclude interviews after "maxdate". When interviews after a certain date are excluded, it is recommended that maxdate be
*		used only with options survey, audit, or backcheck, and not with prepmanipula. This is sufficient to exclude these interviews, and there is
*		no risk that option raw will fail. maxdate should be combined with prepmanipula only when the data management from a previous day needs to
*		be completely reconstructed.
*	  - To show resolved data issues (e.g., dropped interviews missing a duration), specify option showknown.
* - Option dirdate. The survey data produced on a given day is stored in that day's date directory in the "Archived" folder in the data directory.
*	Also stored in the date directory are that day's output for the BC/complete list, and all programs used, including Manipula ones. The data
*	stored is the most recently produced, so e.g., if "managedata, survey" is executed twice on the same day, the data in the date directory will be
*	that produced by the second and last completion of the survey data management. Similarly, the versions of the programs stored are those most
*	recently used, so again, if "managedata, survey" is executed twice on the same day, the version of survey.ado in the date directory will be the
*	one used in the second and last execution. The exception to this is that the version of managedata.ado and survey.ado used to produce the output
*	for the BC/complete list are saved separately as managedata_bc.ado and survey_bc.ado. These will not be overwritten even if option bccomplete is
*	specified, unless the output for the BC/complete list is first deleted in the date directory. The log produced when the output for the
*	BC/complete list is created is also stored in the date directory. By default, the date directory used is the directory associated with the
*	system date. However, it is possible to specify a different date in "dirdate"; this is essentially an alternative to changing the system date.
*	Note that managedata will not use past date directories, which are "locked": if there is a date directory with a date after "dirdate",
*	managedata will error.
*
* managedata.ado goes hand-in-hand with mdparam.ado. Parameters that are expected to change only rarely are managed through mdparam (short for
* "managedata parameters"). These parameters are:
* - datadir. The location of the data directory. This directory must include folders "Archived", "Include", and "By person".
* - logdir. The location of the directory in which logs are stored. One log is stored for each date that managedata is executed. The log is the most
*	recent log produced on that date. 
* - survey. The most recent version of the survey program.
* - voucher. The most recent version of the voucher program.
* - sample. The most recent version of the sample program.
* - checkday. Additional data checks are done every week on the "check day." Which day this is is specified by checkday, where 1 is Sunday, 2 is
*	Monday, etc.
*	- Changing the check day. It is not a problem if the check day is moved forward in the week, e.g., from Tuesday to Monday. However, if the check
*	  day is moved to later in the week, e.g., from Tuesday to Wednesday, the check day checks should first be done on the usual Tuesday and THEN
*	  done again on the Wednesday of the same week. The parameter checkday should be changed to Wednesday only after the checks are completed on
*	  Tuesday.
*	- Making up for a missed check day. Suppose you have missed one or more check days, and you want to make up for them today. There are two
*	  possibilities: today is a check day, or today is not a check day. If today is a check day, set "lag" to the number of days since the first
*	  missed check day. E.g., if the first missed check day was last week, set "lag" to 7. If today is not a check day, note the current value of
*	  checkday, set checkday to today's day, set "maxdate" to the most recent check day, run managedata, and finally restore the previous value of
*	  checkday. E.g., if the check day is Tuesday, and today is Wednesday, change checkday from 3 to 4, set maxdate to the date of Tuesday, run
*	  managedata, and then change checkday back to 3. This is sufficient if Tuesday was the only check day missed, but if multiple check days have
*	  been missed, lag must also be used. Note the current value of checkday, set checkday to today's day, set "maxdate" to the date of Tuesday, set
*	  "lag" to the number of days between Tuesday and the first missed check day, run managedata, and finally restore the previous day of checkday.
*	  For example, if the first missed check day was last Tuesday, and today is Wednesday, change checkday from 3 to 4, set "maxdate" to the date of
*	  this week's Tuesday, set "lag" to 7, run managedata, and then change checkday back to 3.
* - checkdkrfweek. DK/RF responses are checked every four weeks. Set `checkdkrfweek' to which week of the four-week cycle you want to check DK/RF,
*	where 1 is the first week, 2 the second, etc.
*	- Changing the check week. It is not a problem if the check day is moved forward in the week, e.g., from Tuesday to Monday. However, if the check
*	  day is moved to later in the week, e.g., from Tuesday to Wednesday, the check day checks should first be done on the usual Tuesday and THEN
*	  done again on the Wednesday of the same week. The parameter checkday should be changed to Wednesday only after the checks are completed on
*	  Tuesday.
*	- Making up for a missed check DK/RF day. On a check day on a check DK/RF week, managedata will check DK/RF for the past (28 + "lag") days.
*	  There are two possibilities: today is a check day, or today is not a check day. If today is a check day, set checkdkrfweek to the current
*	  week, and set "lag" to the number of days since the missed check DK/RF day. There is no need to change checkdkrfweek back to its previous
*	  value; the next DK/RF day will occur in four weeks after the make-up check DK/RF day. If today is not a check day, note the current value of
*	  checkday, set checkday to today's day, set checkdkrfweek to the current week, set "maxdate" to the most recent date, set "lag" to the number
*	  of days between the missed check DK/RF day and the most recent check day, run managedata, and finally restore the previous value of checkday.
*	  In this case, you must change the value of checkdkrfweek to the week of the most recent check day. E.g., if today is Monday, and the last
*	  check day was last Tuesday, checkdkrfweek must be changed from the current week to the past one.
* - maxsalivaid. The maximum allowed saliva ID.
* - dupdates. The survey data management checks for duplicates by several variables. If you want to ignore duplicates by a certain variable for
*	respondents on or before an interview date, specify the variable and date (MDY) in the Mata string matrix dupdates. Each row of the matrix must
*	contain first the variable name and then the date. The date provided must be the string of an actual date, e.g., "1/1/2011", not a date value,
*	e.g., 18628. Variables must be separated by rows. As an example, dupdates could be:
*	("nationalid", "4/1/2011" \ "salivettenumber1", "4/1/2011")
*	If you do not wish to use dupdates, set it to the void Mata matrix J(0, 2, ""). (Remember double quotes!) To display all duplicates,
*	you can also specify option showknown.
* - oldtonew. A list of the Manipula programs to be executed when option oldtonew is specified.
* - pacomments. PA comments that should appear after the checks (e.g., a reminder that a survey ID without a blood ID is already known). Note that
*	pacomments is a Mata string matrix, which means that multiple lines are allowed, e.g., ("Line 1" \ "Line 2"). If there are no comments, set
*	pacomments to the void Mata matrix J(0, 1, "") by executing the following (note the need for double quotes):
*	mdparam set pacomments `"J(0, 1, "")"'
* See mdparam.ado for the syntax of the command.
program managedata
	version 11
	syntax [, OLDtonew PREPOnly Prepmanipula AUXdo(string) Raw Checkraw Survey BCComplete Audit Backcheck DIRdate(integer -1) pause MAXDate(passthru) /*
		*/ lag(passthru) IGnoresiddups REView SHOWknown]
	if "`oldtonew'`prepmanipula'`auxdo'`raw'`checkraw'`survey'`audit'`backcheck'" == "" error 198
	
	if "`oldtonew'" == "" & "`preponly'" != "" {
		disp as err "preponly specified without oldtonew"
		exit 10
	}
	if "`oldtonew'" != "" & "`preponly'" != "" & "`prepmanipula'" != "" {
		disp as err "prepmanipula specified with preponly"
		exit 10
	}
	if "`oldtonew'" != "" & "`prepmanipula'" == "" & "`survey'`audit'`backcheck'" != "" {
		disp as err "oldtonew and survey/audit/backcheck specified without prepmanipula"
		exit 10
	}
	if "`raw'" != "" & "`prepmanipula'" == "" & "`survey'`audit'`backcheck'" != "" {
		disp as err "raw and survey/audit/backcheck specified without prepmanipula"
		exit 10
	}
	tempname checkdayparam
	quietly mdparam get checkday `checkdayparam'
	confirm integer number `=`checkdayparam''
	if `checkdayparam' < 1 | `checkdayparam' > 7 {
		disp as err "invalid parameter checkday"
		exit 10
	}
	tempname checkdkrfweekparam
	quietly mdparam get checkdkrfweek `checkdkrfweekparam'
	confirm integer number `=`checkdkrfweekparam''
	if `checkdkrfweekparam' < 1 | `checkdkrfweekparam' > 4 {
		disp as err "invalid parameter checkdkrfday"
		exit 10
	}
	
	* Initialize.
	* I add \ to the end of the directory in case the current directory is C:. Stata will not execute cd "c:", but it will execute cd "c:\".
	local checkday = cond(mod(date(c(current_date), "DMY"), 7) == mod(`checkdayparam' + 1, 7), "checkday", "")
	local curdir = c(pwd) + "\"
	clear
	clear mata
	clear programs
	set more off
	forvalues num = 1/50 {
		disp
	}
	disp "{txt}Listing parameters..."
	disp
	mdparam list
	disp
	tempname datadir
	quietly mdparam get datadir `datadir'
	quietly cd "`=`datadir''"
	cap log close
	cap log using "merge", replace
	if _rc {
		disp as err "cannot start log"
		disp
	}
	quietly mata: mdallchecks = J(0, 1, "")
	
	* Create new date directory.
	cap maxdatedir "Archived", mask("MDY")
	if _rc {
		disp as err "no date directory found"
		cleanup "`curdir'"
		exit 10
	}
	else local maxdirdate = r(date)
	local systemdate = date(c(current_date), "DMY")
	local date = cond(`dirdate' == -1, `systemdate', `dirdate')
	if `date' < `maxdirdate' {
		disp as err string(`date', "%tdNN.DD.CCYY") " is a locked date directory"
		cleanup "`curdir'"
		exit 10
	}
	local datedir = string(`date', "%tdNN.DD.CCYY")
	cap mkdir "Archived/`datedir'"
	if !_rc {
		disp "{txt}New date directory {res:`datedir'} created."
		disp
	}
	
	local manipula `""Blaise to Stata step 1 (audit)" "Blaise to Stata step 1 (insufficient)" "Blaise to Stata step 1 (survey)" "Blaise to Stata step 1 (voucher)" "Blaise to Stata step 1a (backcheck)" "Blaise to Stata step 1b (backcheck)" "Blaise to Stata step 2a (barcode)" "Blaise to Stata step 2b (barcode)" "Blaise to Stata step 3 (audit)" "Blaise to Stata step 3 (backcheck)" "Blaise to Stata step 3 (barcode)" "Blaise to Stata step 3 (insufficient)" "Blaise to Stata step 3 (survey)" "Blaise to Stata step 3 (voucher)""'
	
	* Save ado-files.
	foreach ado in "addcheck" "addchecks" "maxdatedir" "mdcheck" "addchange" {
		quietly copy "`ado'.ado" "Archived/`datedir'/`ado'.ado", replace
	}
	foreach ado in "managedata" "mdparam" "tokencond" "inmat" "delall" "copyall" "fileexists" "filesize" {
		quietly copy "`c(sysdir_personal)'`ado'.ado" "Archived/`datedir'/`ado'.ado", replace
	}
	
	if "`oldtonew'" != "" {
		tempname programs surveyparam sample voucher
		quietly mdparam get oldtonew `programs'
		quietly mdparam get survey `surveyparam'
		quietly mdparam get sample `sample'
		quietly mdparam get voucher `voucher'
		oldtonew `=`programs'', survey(`=`surveyparam'') sample(`=`sample'') voucher(`=`voucher'') `preponly' `pause'
		if _rc {
			cleanup "`curdir'"
			exit 10
		}
		quietly copy "oldtonew.ado" "Archived/`datedir'/oldtonew.ado", replace
		quietly cd ..
		foreach msu in `manipula' {
			quietly copy "Data models/Old to new/`msu'.msu" "Archived/`datedir'/`msu'.msu", replace
		}
		quietly cd "Data"
	}
	
	if "`prepmanipula'" != "" {
		tempname surveyparam sample voucher
		quietly mdparam get survey `surveyparam'
		quietly mdparam get sample `sample'
		quietly mdparam get voucher `voucher'
		cap noisily prepmanipula, survey(`=`surveyparam'') sample(`=`sample'') voucher(`=`voucher'') `maxdate'
		if _rc {
			cleanup "`curdir'"
			exit 10
		}
		quietly copy "prepmanipula.ado" "Archived/`datedir'/prepmanipula.ado", replace
	}
	
	if "`auxdo'" != "" {
		if substr("`auxdo'", -3, 3) != ".do" local auxdo = "`auxdo'.do"
		disp "{txt}Starting {res:`auxdo'}..."
		disp
		cap do "`auxdo'"
		if _rc {
			cleanup "`curdir'"
			exit 10
		}
		quietly copy "`auxdo'" "Archived/`datedir'/`auxdo'", replace
	}
	
	if "`raw'" != "" {
		run "make_raw" `pause'
		if _rc {
			cleanup "`curdir'"
			exit 10
		}
		cd ..
		foreach msu in `manipula' {
			quietly copy "Data models/Old to new/`msu'.msu" "Data/Archived/`datedir'/`msu'.msu", replace
		}
		cd "Data"
		if "`checkday'" != "" {
			quietly copy "make_raw.do" "Archived/`datedir'/make_raw.do", replace
			quietly copy "convert_umip.do" "Archived/`datedir'/convert_umip.do", replace
		}
	}
	
	if "`checkraw'" != "" {
		run "make_rawupdate.do" `pause'
		if _rc {
			cleanup "`curdid'"
			exit 10
		}
		forvalues step = 1/3 {
		quietly copy "..\Blaise to Stata step `step'.msu" "Archived/`datedir'/Blaise to Stata step `step'.msu", replace
		quietly copy "..\Include\Blaise to Stata step `step'.man" "Archived/`datedir'/Blaise to Stata step `step'.man", replace
		}
		if "`checkday'" != "" {
			quietly copy "make_rawupdate.do" "Archived/`datedir'/make_rawupdate.do", replace
			quietly copy "convert_umip.do" "Archived/`datedir'/convert_umip.do", replace
		}
	}
	
	if "`survey'" != "" {
		local checkdkrfday = cond(mod(date(c(current_date), "DMY"), 28) == mod(`checkdayparam' + 1 + (`checkdkrfweekparam' - 1) * 7, 28), "checkdkrfday", "")
		tempname dupdates bidskips maxsalivaid
		quietly mdparam get maxsalivaid `maxsalivaid'
		quietly mdparam get dupdates `dupdates'
		quietly mata: mdupdates = `=`dupdates''
		if "`bccomplete'" != "" {
			fileexists "Archived/`datedir'/back_checks_c.csv"
			if r(exist) {
				local bccomplete
				addcheck "No BC/complete list was produced."
				disp "{txt}A BC/complete list has already been produced for this date."
				disp
			}
		}
		cap noisily survey, `bccomplete' `checkday' `checkdkrfday' `lag' `ignoresiddups' `review' `maxdate' `showknown' maxsalivaid(`=`maxsalivaid'') 
		if _rc {
			cleanup "`curdir'"
			exit 10
		}
		quietly save "UMIP", replace
		quietly save "Archived/`datedir'/UMIP", replace
		quietly copy "survey.ado" "Archived/`datedir'/survey.ado", replace
		if "`bccomplete'" != "" {
			quietly copy "survey.ado" "Archived/`datedir'/survey_bc.ado", replace
			copy "back_checks_c.csv" "Archived/`datedir'/back_checks_c.csv"
			disp "{txt}The BC/complete list has been produced."
		}
	}
	
	if "`audit'" != "" {
		cap noisily audit, `checkday' `lag' `maxdate' `showknown'
		if _rc {
			cleanup "`curdir'"
			exit 10
		}
		quietly save "Audit", replace
		quietly copy "audit.ado" "Archived/`datedir'/audit.ado", replace
	}
	
	if "`backcheck'" != "" {
		cap noisily backcheck, `checkday' `lag' `maxdate' `review' `showknown'
		if _rc {
			cleanup "`curdir'"
			exit 10
		}
		quietly save "Back check", replace
		quietly copy "backcheck.ado" "Archived/`datedir'/backcheck.ado", replace
	}
	
	* Display checks.
	disp
	disp
	disp
	tempname pacomments
	quietly mdparam get pacomments `pacomments'
	quietly mata: mdpacomments = `=`pacomments''
	quietly mata: mdallchecks = (mdallchecks \ (mdallchecks == J(0, 1, "") ? "" : "{res}----------------------" \ "") \ mdpacomments)
	mata: for(row = 1; row <= rows(mdallchecks); row++) printf("%s\n", mdallchecks[row, 1])
	
	* Clean up.
	if "`survey'" != "" use "UMIP", clear
	cap log close
	if "`bccomplete'" != "" quietly {
		copy "`c(sysdir_personal)'managedata.ado" "Archived/`datedir'/managedata_bc.ado", replace
		copy "merge.smcl" "Archived/`datedir'/merge_bc.smcl", replace
	}
	tempname logdir
	quietly mdparam get logdir `logdir'
	quietly copy "merge.smcl" "`=`logdir''\merge `datedir'.smcl", replace
	quietly cd "`curdir'"
	clear mata
end

program cleanup
	syntax anything(name=curdir)
	
	cap log close
	quietly cd `curdir'
	clear mata
end
