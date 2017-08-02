program matfilljh
* NJC 1.0.0 26 March 2003 daffodils out in Durham
* fill in matrix missings from transpose 
	version 8 
	args m garbage 
	confirm matrix `m' 
	if "`garbage'" != "" error 198 

	if `= colsof(`m')' != `= rowsof(`m')' { 
		di as err "`m' not square"
		exit 498 
	}
	else local n = colsof(`m') 	

	forval i = 1/`n' {
		forval j = 1/`n' {
	 		if `i' < `j' {
				matrix `m'[`j',`i']  = `m'[`i',`j']
			}
		}	
 	}
end 
