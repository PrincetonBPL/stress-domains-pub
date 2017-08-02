* Syntax: inmat scalar matrix, [newmat]
* Returns in r(in) 1 if "scalar" is an element in "matrix" and 0 otherwise. If option newmat is specified, "matrix" can be an entered matrix, real or
* string.
program inmat
	version 11
	syntax anything(name=0) [, newmat]
	gettoken x 0 : 0
	local mat `0'
	
	if "`newmat'" == "" local mat st_matrix("`mat'")
	cap confirm number `x'
	if !_rc quietly mata: inmat(`mat', `x')
	if _rc quietly mata: inmat(`mat', `"`x'"')
end
quietly mata:
	void function inmat(matrix mat, scalar x) {
		in = 0
		for(row = 1; row <= rows(mat); row++) {
			for(col = 1; col <= cols(mat); col++) {
				in = in | (mat[row, col] == x)
			}
		}
		st_numscalar("r(in)", in)
	}
end
