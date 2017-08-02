* Syntax: tokencond string, [min(integer)] [max(integer)]
* If "min" is specified, errors unless there are at least "min" tokens in "string". If "max" is specified, errors unless there are at most "max" tokens
* in "string".
program tokencond
	version 11
	syntax [anything(name=0)] [, min(integer -1) max(integer -1)]
	if `min' == -1 & `max' == -1 error 198
	if `min' < -1 | `max' < -1 error 198
	
	tokenize `"`0'"'
	if `min' > 0 & `"``min''"' == "" error 198
	if `max' != -1 & `"``=`max'+1''"' != "" error 198
end
