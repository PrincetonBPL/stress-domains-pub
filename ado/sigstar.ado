program define sigstar, rclass
syntax [anything], [p(real 0)] [se(real 0)] [b(real 0)] [n(real 1000000)] [prec(real 0)] [bstar] [sestar] [pstar] [nopar] [pbrackets]

quietly {

	if "`anything'" != "" {

		loc b = _b[`anything']
		loc se = _se[`anything']

		test _b[`anything'] = 0
		loc p = r(p)

	}

	if "`p'" == "." | "`p'" == "" {

		return loc bstar = " "
		return loc sestar = " "
		return loc pstar = " "

	}

	else {

		if `p' < 0.01 loc star = "\sym{***}"
		else if `p' < 0.05 loc star = "\sym{**}"
		else if `p' < 0.10 loc star = "\sym{*}"

		if "`prec'" == "" loc prec = 3

		return loc bstar = string(`b', "%9.`prec'f") + "`star'"
		return loc sestar = "(" + string(`se', "%9.`prec'f") + ")"

		loc pstar = string(`p', "%9.`prec'f")
		if "`pstar'" != "" loc pstar = "`pstar'" + "`star'"
		if "`pbrackets'" != "" loc pstar = "[" + "`pstar'" + "]"
		return loc pstar = "`pstar'"

	}

}

end
