* *******************************************************************
* PROGRAM: spatial_se.ado
* PROGRAMMER: Simone Schaner
* PURPOSE: Program to run OLS and 2SLS with Conley (1999) spatially
* 		clustered standard errors
* DATE CREATED: 11/21/2011
* ******************************************************************

******************************** 	INSTRUCTIONS	***********************************
* This code generates Conley (1999) spatial standard
* errors for both OLS and 2SLS. The main synax mirrors
* the synax for Stata regress and ivregess. 
* For OLS: spatial_se depar indvarlist, coord(varlist) cut(numlist)
* For IV: spatial_se depvar exog_x (endog_x= instruments), coord(varlist) cut(varlist)
* where coord(varlist) contains the list of coordinate variables that determine each 
* observation's relationship to one another and cut(varlist) specifies the distance
* for each coordinate beyond which covariances are forced to be zero. Note that the 
* number of coordinates and number of cut point vars *must* be equal, otherwise you will
* get an error.
****************************************************************************************

cap prog drop spatial_se
prog define spatial_se, eclass

syntax anything [if], [iv] COORD(varlist) CUT(varlist)
local coct: word count `coord'
local cuct: word count `cut'
	if `coct'!=`cuct' {
		di in red "Number of co-ordinates must equal number of cut points"
		exit 198
		}	 
* qui {
	mata: mata clear			

	preserve
	tokenize `coord'
	local j=1
	while "``j''"!="" {
		keep if ``j''!=.
		local ++j
		}
	
* STEP 1: RUN THE REGRESSION
	if "`iv'"=="" { 
		regress `anything' `if' 
			local xvar: colfullnames e(b)
			local zvar: colfullnames e(b)
			}
	else { 
		ivregress2 2sls `anything' `if' 
		local xvar: colfullnames e(b)
		local zvar "$xvq"
		}

	keep if e(sample)
	marksample touse
	keep if `touse'
	local depend= e(depvar)
	local r2= e(r2)
	local r2_a= e(r2_a)
	
	* RESIDUALS
	tempvar res
		predict `res', resid
	tempvar ones
		g `ones'=1

	local xvar2 ""
	local zvar2 ""
	
	* Simone's code
	/*foreach stem in zvar xvar {
		tokenize ``stem''
		local q=1
		while "``q''"!="" {
			if substr("``q''",1,2)!="o." & "``q''"!="_cons" {
				if "`stem'2'"=="" local `stem'2 "``q''"
				else  local `stem'2 "``stem'2' ``q''"
				}
			local ++q
			}
		}*/

	* Johannes's code
	foreach stem in zvar xvar {
		tokenize ``stem''
		local q=1
		local usefulcounter = 1
		while "``q''"!="" {
			if substr("``q''",1,2)!="o." & "``q''"!="_cons" {
				if "`stem'2'"=="" local `stem'2 "``q''"
				else  local `stem'2 "``stem'2' ``q''"
				local ++usefulcounter 
				}
			local ++q
			}
		}
	
* GET COEFF VECTOR
	mat beta=J(1,`usefulcounter',.) // was "`q'"; changed to "`usefulcounter'" by Johannes

	tokenize "`xvar2'"
	local q=1
	while "``q''"!="" {
		mat beta[1,`q']= _b[``q'']
		local ++q
		}	
	mat beta[1,`q']= _b[_cons]
	mat colnames beta=`xvar2' _cons
		
* GET EVERYTHING INTO MATA
	mata:	X= st_data(.,"`xvar2' `ones'")
	mata:	Z= st_data(.,"`zvar2' `ones'")
	mata:	e= st_data(.,"`res'")

	tokenize `coord'
	local j=1
	while "``j''"!="" {
		mata:	co`j'= st_data(.,"``j''")
		local ++j
		}

	tokenize `cut'
	local k=1
	while `k'<`j' {
		mata:	c`k'= st_data(.,"``k''")
		* MAKE WEIGHT MATRICES		
		mata: weight`k'= abs((J(length(co`k'),length(co`k'),1):*(co`k')-J(length(co`k'),length(co`k'),1):*(co`k'')))
		mata: weight`k'= (c`k':-weight`k'):/c`k'
		mata: weight`k'= weight`k':*(weight`k':>0)	
		local ++k	
		}		

	mata: weight= weight1
	local k=2
	while `k'<`j' {
		mata: weight= weight:*weight`k'
		local ++k
		}
	
	* CALCULATE VAR-COVAR MATRIX
	mata: omega_w= (e*e'):*weight	
	mata: ZZ_inv= invsym(Z'*Z)
	mata: X_hat= (Z*ZZ_inv*Z'*X)
	mata: i_hat= invsym(X_hat'*X_hat)
	mata: V= i_hat*X_hat'*omega_w*X_hat*i_hat
	mata: st_matrix("V",V)	

	mat colnames V= `xvar2' _cons
	mat rownames V= `xvar2' _cons	
* } // quietly 

* POST RESULTS TO STATA
local obs= _N
#delimit ;
di _n in gr "OLS Regression with Conley standard errors " 
	_col(55) "Number of obs	=" in yel %8.0f `obs' _n
	_col(55) in gr "R-squared     =" in yel %8.4f `r2' _n
	_col(55) in gr "Adj R-squared =" in yel %8.4f `r2_a' _n;
#delimit cr

ereturn post beta V, esample(`touse') depname(`depend') obs(`obs')
ereturn display

end







