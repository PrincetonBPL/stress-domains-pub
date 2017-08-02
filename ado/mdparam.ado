* See managedata.ado for a list of data management parameters managed through mdparam.
* 
* Options:
* --------
* mdparam list, [default]
* Lists data management parameters, from the default list if option default is specified.
*
* mdparam set code scalar, [default]
* Sets parameter "code" to "scalar", in the default list if option default is specified, creating the parameter if it does not exist already.
*
* mdparam get code [name], [default]
* Displays parameter "code", from the default list if option default is specified. Sets scalar "name" to paramter "code" if "name" is specified.
*
* mdparam remove code, [default]
* Removes parameter "code", from the default list if option default is specified.
*
* mdparam restore default
* Sets parameters back to those in the default list.
*
* mdparam save as default
* Saves current parameters as the default list.
program mdparam
	version 11
	syntax anything(name=0) [, default]
	local params `0'
	gettoken command params : params
	gettoken paramcode params : params
	gettoken passparam params : params
	inmat "`command'" ("list", "set", "get", "remove", "restore", "save"), newmat
	if !r(in) error 198
	local default = "`default'" != ""
	if ("`command'" == "restore" | "`command'" == "save") & `default' error 198
	
	local file = c(sysdir_personal)
	if `default' local file = "`file'managedata_default.dat"
	else local file = "`file'managedata.dat"
	
	if "`command'" == "list" {
		tokencond `0', max(1)
		if "`2'" != "" & !`default' error 198
		mata: mdparamlist("`file'")
	}
	else if "`command'" == "get" {
		tokencond `0', min(2) max(3)
		mata: mdparamget("`file'", "`paramcode'", "`passparam'")
	}
	else if "`command'" == "set" {
		tokencond `0', min(3) max(3)		
		quietly mata: mdparamset("`file'", "`paramcode'", `"`passparam'"')
		mdparam list
	}
	else if "`command'" == "remove" {
		tokencond `0', min(2) max(2)
		quietly mata: mdparamremove("`file'", "`paramcode'")
	}
	else if "`command'" == "restore" {
		tokencond `0', min(2) max(2)
		if "`2'" != "default" error 198
		local curdir = c(pwd)
		quietly cd "`c(sysdir_personal)'"
		copy "managedata_default.dat" "managedata.dat", replace
		quietly cd "`curdir'"
	}
	else if "`command'" == "save" {
		tokencond `0', max(3)
		if "`2'" != "as" | "`3'" != "default" error 198
		local curdir = c(pwd)
		quietly cd "`c(sysdir_personal)'"
		copy "managedata.dat" "managedata_default.dat", replace
		quietly cd "`curdir'"
	}
end
quietly mata:
	void function mdparamlist(string scalar file) {
		fh = fopen(file, "r")
		while((line=fget(fh)) != J(0, 0, "")) {
			code = substr(line, 1, strpos(line, ":") - 1)
			param = strltrim(subinstr(line, code + ":", "", 1))
			printf("{txt}%s: {res}%s\n", code, param)
		}
		fclose(fh)
	}
	
	// Returns nothing if name = "".
	void function mdparamget(string scalar file, string scalar paramcode, string scalar name) {
		foundparam = 0
		fh = fopen(file, "r")
		while(!foundparam & (line=fget(fh)) != J(0, 0, "")) {
			code = substr(line, 1, strpos(line, ":") - 1)
			if(code == paramcode) {
				param = strltrim(subinstr(line, code + ":", "", 1))
				foundparam = 1
			}
		}
		fclose(fh)
		if(!foundparam) _error("invalid parameter code")
		printf("{txt}%s: {res}%s\n", paramcode, param)
		if(name != "") {
			if(strofreal(strtoreal(param)) == param) st_numscalar(name, strtoreal(param))
			else st_strscalar(name, param)
		}
	}

	void function mdparamset(string scalar file, string scalar paramcode, scalar param) {
		if(isreal(param)) param = strofreal(param)
		fhin = fopen(file, "r")
		fhout = fopen("managedata_temp.dat", "rw")
		while((line=fget(fhin)) != J(0, 0, "")) {
			code = substr(line, 1, strpos(line, ":") - 1)
			if(code != paramcode) fput(fhout, line)
		}
		fput(fhout, paramcode + ": " + param)
		fclose(fhin)
		fclose(fhout)
		cmd = `"copy "managedata_temp.dat" ""' + file + `"", replace"'
		stata(cmd)
		stata(`"erase "managedata_temp.dat""')
	}
	
	void function mdparamremove(string scalar file, string scalar paramcode) {
		foundparam = 0
		fhin = fopen(file, "r")
		fhout = fopen("managedata_temp.dat", "rw")		
		while((line=fget(fhin)) != J(0, 0, "")) {
			code = substr(line, 1, strpos(line, ":") - 1)
			if(code == paramcode) foundparam = 1
			else fput(fhout, line)
		}
		fclose(fhin)
		fclose(fhout)		
		if(!foundparam) _error("invalid parameter code")
		else {
			st_local("file", file)
			cmd = `"copy "managedata_temp.dat" ""' + file + `"", replace"'
			stata(cmd)
		}
		stata(`"erase "managedata_temp.dat""')
	}
end
