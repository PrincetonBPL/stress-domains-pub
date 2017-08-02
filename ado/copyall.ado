* Syntax: copyall origin [destination], [replace]
* Copies all files from "origin" to "destination" (the current directory if not specified), replacing files if option replace is specified.
program copyall
	version 11
	syntax anything(name=0) [, replace]
	args origin dest
	tokencond `0', min(1) max(2)
	
	if "`origin'" == "*.*" local origin
	local files : dir "`origin'" files "*"
	if "`origin'" != "" local origin = "`origin'/"
	if "`dest'" != "" local dest = "`dest'/"
	local error 0
	foreach file of local files {
		cap copy "`origin'`file'" "`dest'`file'", `replace'
		local error = `error' | _rc
	}
	if `error' disp "{txt}note: not all files copied."
end
