*****************************************************************************
/* Merging Barcodes with Observations for Domains Paper 
Author: Daniel Mellow
Last Update: 2017.11.07
Project: Stress Domains
I: Load Salivettes
II: Merge with Cleaned Data
III: Repeat I and II for CPT, Productivitiy and TSST
*/
*****************************************************************************

clear
cap log close
set more off, permanently
set matsize 800
pause on
version 14

gl date: disp   %tdYYNNDD date(c(current_date), "DMY") 
gl initals "DM"
if c(os) == "MacOSX" gl user "/Users/`c(username)'"
else if c(os) == "Windows" gl user "C:\\Users\\`c(username)'" 
else if c(os) == "Unix" gl user "/usr/`c(username)'"


gl root_dir "Box Sync/_Busara Field/_Project Folders (Internal)"

loc project_name "_Old/Stress_domains"

global data_dir "$root_dir/data"
gl lab_dir "$root_dir/`project_name'/lab"
global dofile_dir "$root_dir/`project_name'/code/do"
global ado_dir "$root_dir/`project_name'/code/ado"
global fig_dir "$root_dir/`project_name'/figures"
global tab_dir "$root_dir/`project_name'/tables"

sysdir set PERSONAL "${ado_dir}"


****** CPT

import delimited "$lab_dir/CPT/Salivettes/Barcode entry.csv", ///
	encoding(ISO-8859-1) clear
	


