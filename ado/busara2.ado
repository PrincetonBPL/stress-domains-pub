/* Busara data flow
	1. Generate Invitee.csv for a session. Put into Frontline SMS format and save to session folder.
	2. Insheet responses, clean and count how many attending
	3. Generate final respondent data.csv for the session. Run manipula converting it to .bdb format and save to Include file. 
	4. Write a batch file saving the include contents to the Identify netbook
*/

program busara2
	version 11
	syntax [, Clean Invite replies Respondentdata reminder Tribe Ztreedata Payment Sunny STudydata Session(passthru) Time(passthru) Attendees(passthru) Project(passthru) Sent(passthru) Identifystart(passthru) Identifyend(passthru)]

		cd "C:\Users\mcollins\Dropbox\Busara_Revision\data and program\data"
		capture truecrypt "encrypted", drive("M")
		
	* Create new date directory.
	cap maxdatedir "Archived", mask("MDY")
	if _rc {
		disp as err "no date directory found"
		cleanup "`curdir'"
		exit 10
	}
	else local maxdirdate = r(date)
	local systemdate = date(c(current_date), "DMY")
	local date = `systemdate'
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

* Save busara.ado
quietly copy "C:\ado\personal\busara2.ado" "Archived/`datedir'/busara2.ado", replace

if "`clean'" != "" {
	
	cap noisily clean
	if _rc {
		cleanup "`curdir'"
		exit 10
	}
	quietly copy "clean.ado" "Archived/`datedir'/clean.ado", replace
}
	
if "`invite'" != "" {
	
	cap noisily invite, `session' `time' `attendees'
	if _rc {
		cleanup "`curdir'"
		exit 10
	}
	quietly copy "invite.ado" "Archived/`datedir'/invite.ado", replace
}

if "`replies'" != "" {
	/*local sessiondate = date("`session'", "MDY")
	local datedir = string(`sessiondate', "%tdNN.DD.CCYY")+"."+"`time'"
	quietly insheet using "By Session/`datedir'/replies.csv", comma */
	cap noisily replies, `session' `time' `sent'
	if _rc {
		cleanup "`curdir'"
		exit 10
	}
	quietly copy "replies.ado" "Archived/`datedir'/replies.ado", replace
}

if "`respondentdata'" != "" {
	
	cap noisily respondentdata, `session' `time'
	if _rc {
		cleanup "`curdir'"
		exit 10
	}
	quietly copy "respondentdata.ado" "Archived/`datedir'/respondentdata.ado", replace
}

if "`reminder'" != "" {
	
	cap noisily reminder, `session'
	if _rc {
		cleanup "`curdir'"
		exit 10
	}
	quietly copy "reminder.ado" "Archived/`datedir'/reminder.ado", replace
}

if "`tribe'" != "" {
	
	cap noisily tribe, `session' `time'
	if _rc {
		cleanup "`curdir'"
		exit 10
	}
	quietly copy "tribe.ado" "Archived/`datedir'/tribe.ado", replace
}

if "`ztreedata'" != "" {
	
	cap noisily ztreedata, `session' `time' `identifystart' `identifyend'
	if _rc {
		cleanup "`curdir'"
		exit 10
	}
	quietly copy "ztreedata.ado" "Archived/`datedir'/ztreedata.ado", replace
}

if "`payment'" != "" {
	
	cap noisily payment, `session' `time'
	if _rc {
		cleanup "`curdir'"
		exit 10
	}
	quietly copy "payment.ado" "Archived/`datedir'/payment.ado", replace
}

if "`sunny'" != "" {
	
	cap noisily sunny, `session' `time'
	if _rc {
		cleanup "`curdir'"
		exit 10
	}
	quietly copy "sunny.ado" "Archived/`datedir'/sunny.ado", replace
}
if "`studydata'" != "" {
	
	cap noisily studydata, `project'
	if _rc {
		cleanup "`curdir'"
		exit 10
	}
	quietly copy "studydata.ado" "Archived/`datedir'/studydata.ado", replace
}

*truecrypt, dismount drive("M")
end

program cleanup
	syntax anything(name=curdir)
	
	cap log close
	quietly cd `curdir'
	clear mata
end
