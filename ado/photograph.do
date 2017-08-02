
// Adding a picture as background to a graph

//The above picture can be improved on, if required, by converting a picture
//into html and then cleaning this file up in Stata.

//The picture is first loaded into GIMP (free software program) and then saved
//as html (Remmember the larger the picture the more computer resources are
//required and the longer it will take to process the code)


clear all
set more off
set memory 900m


program hex

  syntax varname , Newv(name)

    generate `newv'=((strpos("`=c(alpha)'",`varlist')-1)/2)+10
    replace `newv'=real(`varlist') if `newv'==9.5

end


//values that can be changed
local divide=8     //sample size




insheet using "/Users/haushofer/Documents/car.png", clear

generate row=.
replace row=1 if strpos(v1,"< TR>")
replace row=sum(row)

keep if strpos(v1, " < TD  BGCOLOR")

split v1,p(#)
split v12,p(>)
keep row v121

generate obs=_n

bysort row (obs):gen col=_n

rename v121 hex
generate hex1=substr(hex,1,1)
generate hex1a=substr(hex,2,1)

generate hex2=substr(hex,3,1)
generate hex2a=substr(hex,4,1)

generate hex3=substr(hex,5,1)
generate hex3a=substr(hex,6,1)

hex hex1, newv(dec1)
hex hex1a, newv(dec1a)

hex hex2, newv(dec2)
hex hex2a, newv(dec2a)

hex hex3, newv(dec3)
hex hex3a, newv(dec3a)


generate dec1b=16*dec1+dec1a
generate dec2b=16*dec2+dec2a
generate dec3b=16*dec3+dec3a

keep dec1b dec2b dec3b row col

generate dec1c=floor(dec1b/`divide')*`divide'
generate dec2c=floor(dec2b/`divide')*`divide'
generate dec3c=floor(dec3b/`divide')*`divide'

gen str20 color=char(34)+string(dec1c,"%3.0f")+" "+string(dec2c,"%3.0f") ///
+" "+string(dec3c,"%3.0f")+char(34)

egen group_col=group(color)

compress
save pict_graph, replace

use pict_graph, clear
quiet summarize col

local size="*`=33/`r(max)''"     //marker size, can be adjusted

levelsof color, local(a) 

merge 1:1 _n using  "C:\Program Files\stata11\ado\base/a/auto.dta"
summarize length

gen y=90+(((_N-_n+1)-90))/(_N/r(max))

//scaling x axis picture data
replace col=col/9

local z=1

foreach i of local a {

  if `z'==1 {
local zz =  ///
`"(scatter y col if group_col==`z',msymbol(square) mcolor(`i') msize(`size'))"'

    local z=2
   }
      else {
local zz1 = ///
`"(scatter y col if group_col==`z' ,msymbol(square) mcolor(`i') msize(`size'))"'

local zz "`zz' `zz1'"
local ++z
      }
}

twoway `zz'                                      ///
(scatter  length mpg, mcolor(red) msize(large))  ///
(lfit  length mpg)                               ///
,yscale( range(100 325))                         ///
ytitle(Length ins.) xtitle(mpg)                  ///
title(Mpg v Length) legend(off)

exit

