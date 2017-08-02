* Syntax: delall directory
* Deletes all files in directory "directory".
program delall
	version 11
	args deldir
	tokencond `0', max(1)
	
	local files : dir "`deldir'" files "*"
	if "`deldir'" != "" local deldir = "`deldir'/"
	foreach file of local files {
		erase "`deldir'`file'"
	}
end
