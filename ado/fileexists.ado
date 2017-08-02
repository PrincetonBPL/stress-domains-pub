* Syntax: fileexists filename
* Returns in r(exist) 1 if "filename" exists and 0 otherwise.
program fileexists
	version 11
	args file
	tokencond `0', min(1) max(1)
	
	quietly mata: st_numscalar("r(exist)", fileexists("`file'"))
end
