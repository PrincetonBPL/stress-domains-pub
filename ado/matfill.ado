program matfill 
* NJC 1.0.0 26 March 2003 daffodils out in Durham
* fill in matrix missings from transpose 
	version 8 
	args m garbage 
	confirm matrix `m' 
	if "`garbage'" != "" error 198 

	if !matmissing(`m') { 
		di as err "no missings in `m'" 
		exit 498 
	} 

	if `= colsof(`m')' != `= rowsof(`m')' { 
		di as err "`m' not square"
		exit 498 
	}
	else local n = colsof(`m') 	

	forval i = 1/`n' {
		forval j = 1/`n' {
	 		if `m'[`i',`j'] == . {
				if `i' == `j' { 
					di as txt "can't replace on diagonal"
				}	
				else matrix `m'[`i',`j']  = `m'[`j',`i']
			}
		}	
 	}
end 
