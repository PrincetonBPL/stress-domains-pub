# Stress and Temporal Discounting: Do Domains Matter?
_Johannes Haushofer, Chaning Jang, John Lynham, and Justin Abraham_

This is a public repository containing replication files for "Stress and Temporal Discounting: Do Domains Matter?".

### Replication

Releases typically contain the data, source code, survey instruments, manuscript, and a summary of the research design. Simply run `stress_master.do` to reproduce tables and figures presented in the manuscript and appendix. These will be output in `tables/` and `figures/` respectively. Experimental data was collected using Z-Tree. Results published in the manuscript were analyzed using Stata 13.1.

### Data

+ The directories `*_raw/` contain each experiment's raw data. These consist of `.xls` files produced by Z-Tree and `.dta` files containing subject demographics. We strip subject data of personally identifiable information to protect participant privacy.
+ `*_Cleaned.dta` are intermediate datasets to be further cleaned.
+ `Stress_FinalWide.dta` is the final subject-level dataset containing data from all three lab experiments. This dataset is used to produce all tables in the manuscript.
+ `Stress_FinalTime.dta` is the final subject-by-question level dataset made by reshaping `Stress_FinalWide.dta` with temporal discounting variables.
+ `Stress_FinalNAS.dta` is the final subject-by-question level dataset made by reshaping `Stress_FinalWide.dta` with negative affect variables.
+ `stress_data_id` is an encrypted volume containing data before de-identification. Available only to authorized users.

### Source Code

+ `ado/`: Contains canned scripts used in data manipulation, analysis, and publishing.
+ `do/`: Contains .do files used to replicate results in the paper.
	- `do/stress_master.do`: This script is the master .do file that reproduces all components of the data analysis. Users need only execute this file to replicate results. Requires Stata 13.1 or higher.
	- `do/stress_append.do`: This script takes `*_Cleaned.dta` and outputs `Stress_FinalWide.dta`.
	- `do/stress_summary.do`: This script produces summary statistics and conducts the randomization check.
	- `do/stress_analysis.do`: This script estimates treatment effects: the paper's highlighted results.
	- `do/*_clean.do`: These files prepare raw data from each experiment and produces intermediate datasets `*_Cleaned.dta`.
	- `custom_tables/`: Directory for .do files that render tables from Stata into Latex.
+ `ztt/`: Contains the .ztt files that implement the experimental protocol on Z-Tree.

### Contact

The corresponding author is [Johannes Haushofer](haushofer@princeton.edu "haushofer@princeton.edu").

<!-- Releases contain 1. source code, 2. data, 3. tables/figures, 4. summary, 5. instruments, 6. manuscript -->
