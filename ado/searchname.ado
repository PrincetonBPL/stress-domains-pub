* Search the prelim data for up to three names. (Needs revision.)
program searchname
	version 11
	syntax , NAME1(string) [name2(string) name3(string)]
	local name1 = lower("`name1'")
	local name2 = lower("`name2'")
	local name3 = lower("`name3'")
	
	preserve
	cap gen name = proper(trim(itrim(name_first + " " + name_other1 + " " + name_other2 + " " + name_last)))
	quietly replace name = lower(name)
	list survey_id old_survey_id name id_national workplace v03 v12 if length(subinstr(name, "`name1'", "", .)) < length(name) & /*
		*/ length(subinstr(name, "`name2'", "", .)) < length(name) & length(subinstr(name, "`name3'", "", .)) < length(name)
	restore
end
