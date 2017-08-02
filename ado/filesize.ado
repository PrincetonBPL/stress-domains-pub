* Syntax: filesize filename
* Returns the size of "filename" in r(size).
program filesize
	tokencond `0', min(1) max(1)
	args file
	confirm file "`file'"
	
	quietly mata: filesize("`file'")
end
quietly mata:
	void function filesize(string scalar file) {
		fh = fopen(file, "r")
		fseek(fh, 0, 1)
		st_numscalar("r(size)", ftell(fh))
		fclose(fh)
	}
end
