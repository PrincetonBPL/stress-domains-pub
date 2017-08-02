#delim ;
prog def outputst;
version 6.0;
*
 Output a non-Stata data set using Stat/Transfer
 (with parameters and switches supplied by the user)
 from the Stata data set in the memory.
 Author: Roger Newson
 Date: 9 November 2000
*;

tempfile tmpdta;
qui save `tmpdta',replace;
stcmd  stata `tmpdta' `0';
capture erase `tmpdta';

end;
