# Stress and Temporal Discounting: Do Domains Matter?
## Johannes Haushofer, Chaning Jang, John Lynham, and Justin Abraham

This is a public repository for analysis source code in "Stress and Temporal Discounting: Do Domains Matter?". We registered a [pre-analysis plan](https://www.socialscienceregistry.org/trials/934) with the AEA RCT Registry that outlines the research question, the experiment, the data, the identification strategy, and our hypotheses. The most recent version of the paper can be found [here](https://www.princeton.edu/haushofer/publications/Haushofer_Jang_Lynham_Stress_Domains_2017.02.10_jh.pdf).

### Contents

+ `ado/`: Contains dependencies used in data manipulation and analysis.
+ `do/`: Contains .do files used to replicate results in the paper.
	- `do/stress_master.do`: This is the master .do file that calls the following components of the analysis.
	- `do/stress_append.do`: This merges and cleans raw data from all experiments into the analysis dataset.
	- `do/stress_summary.do`: This produces summary statistics and conducts the randomization check.
	- `do/stress_analysis.do`: This estimates treatment effects: the paper's highlighted results.
	- `do/*_clean.do`: These files prepare the data from each experiment to be merged.
	- `custom_tables/`: Directory for .do files that render results from Stata into Latex tables.
+ `logs/`: Contains time-stamped log files documenting each execution of the source code.

### Data

Releases of the source code will be packaged with only the final dataset used for analysis (`Stress_FinalWide.dta`). Nevertheless, the repo includes the portion of the code which produces the final data from intermediate datasets. The final dataset is stripped of personally identifiable information to protect participant privacy.

### Replication

Ensure that the dataset `Stress_FinalWide.dta` exists in the `data/` directory. Run `stress_master.do` to reproduce tables and figures presented in the paper and appendix. These will be located in `tables/` and `figures/` respectively.

### Contact

Comments? Questions? Send a message to [Justin Abraham](justin.abraham@busaracenter.com "justin.abraham@busaracenter.com").
