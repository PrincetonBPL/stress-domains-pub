** Desc: Calcuate minimum q-values from two-stage FDR correction, based on http://are.berkeley.edu/~mlanderson/downloads/fdr_sharpened_qvalues.do.zip
** Author: Justin Abraham
** Input: vector of p-values
** Output: vector of minimum q-values
** Options: q() is the name of the output vector, step() is size of the decrement, label() attaches names to the output vector, plabel labels the input vector

capture program drop minq
program define minq, eclass
syntax anything(name = p), [q(string)] [step(real 0)] [label(string)] [plabel]

* Options

if "`step'" == "0" loc step = 0.001
if "`q'" == "" loc q = "Q"

* Create dataset of p-values

di as text "Input p-values"
mat list `p'

preserve

clear

qui svmat `p'

* Collect the total number of p-values tested

quietly sum `p'
local totalpvals = r(N)

* Sort the p-values in ascending order and generate a variable that codes each p-value's rank

quietly gen int original_sorting_order = _n
quietly sort `p'
quietly gen int rank = _n if `p'~=.

* Set the initial counter to 1

local qval = 1

* Generate the variable that will contain the BKY (2006) sharpened q-values

quietly gen bky06_qval = 1 if `p'~=.

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.

while `qval' > 0 {

* First Stage

	* Generate the adjusted first stage q level we are testing: q' = q/1+q
	local qval_adj = `qval'/(1+`qval')

	* Generate value q'*r/M
	quietly gen fdr_temp1 = `qval_adj'*rank/`totalpvals'

	* Generate binary variable checking condition p(r) <= q'*r/M
	quietly gen reject_temp1 = (fdr_temp1>=`p') if `p'~=.

	* Generate variable containing p-value ranks for all p-values that meet above condition
	quietly gen reject_rank1 = reject_temp1*rank

	* Record the rank of the largest p-value that meets above condition
	quietly egen total_rejected1 = max(reject_rank1)

* Second Stage

	* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
	local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))

	* Generate value q_2st*r/M
	quietly gen fdr_temp2 = `qval_2st'*rank/`totalpvals'

	* Generate binary variable checking condition p(r) <= q_2st*r/M
	quietly gen reject_temp2 = (fdr_temp2>=`p') if `p'~=.

	* Generate variable containing p-value ranks for all p-values that meet above condition
	quietly gen reject_rank2 = reject_temp2*rank

	* Record the rank of the largest p-value that meets above condition
	quietly egen total_rejected2 = max(reject_rank2)

	* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	qui replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.

	* Reduce q by 0.001 and repeat loop
	drop fdr_temp* reject_temp* reject_rank* total_rejected*
	local qval = `qval' - `step'

}

* Generate output vector

qui sort original_sorting_order
qui gen `q' = bky06_qval

* Add labels

if "`label'" == "" mkmat `q', mat(`q')

else {

	loc k = 1
	qui gen varn = ""

	foreach name in `label' {

		qui replace varn = "`name'" if _n == `k'
		loc ++k

	}

	mkmat `q', mat(`q') rownames(varn)

	if "`plabel'" != "" mkmat `p', mat(`p') rownames(varn)

}

di as text "Resulting q-values"
mat list `q'

restore

end
