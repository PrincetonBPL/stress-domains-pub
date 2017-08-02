******************************************************************************
/*
* Guide to comparing entries using cfout.
	By Ryan Knight
	v0.1 on December 16, 2010
	
	To be used in conjunction with the "Guide to Comparing Entries"
	
	The data is fake, generated using Excel.
*/

* Load the first and second entries
clear

insheet using "my raw first entry.csv"

save "first entry.dta", replace



insheet using "my raw second entry.csv" , clear

save "second entry.dta" , replace

* compare the files

cfout region-no_good_at_all using "first entry.dta" , id(uniqueid)



