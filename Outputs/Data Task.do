**************** DATA TASK ******************


*Created: 04/Enero/2022
*Last edited: 04/Enero/2022
*Author: Maria Paola Castro
*Stata: 14.0

************************************************************************************************
global ruta "/Users/mariapaolacastrorodriguez/Documents/GitHub/Data-Task"           

global outputs  "$ruta/Outputs"
global edited   "$ruta/Edited data"
global graphics "$ruta/Graphics"
global data     "$ruta/Data"


*** I. Data Cleaning
clear all
set more off

* 1. Import the data
import excel "/$data/Data for Analysis Test.xlsx", sheet("Sheet1") firstrow
save "$edited/BD_main.dta", replace

import excel "/$data/Town Names for Analysis Test.xlsx", sheet("Sheet1") firstrow
rename TownID town_id 
save "$edited/BD_sec.dta", replace

* 2. Merge

use "$edited/BD_main.dta", clear
merge m:1 town_id using "$edited/BD_sec.dta"
keep if _merge==3
drop _merge

*3 Encoding 
*From https://www.stata.com/support/faqs/data-management/encoding-string-variable/
encode district, gen (ndistrict)

*4 ID
by town_id, sort: gen unit_id = _n 

egen unique_id = concat(town_id unit_id)

*5 Looking for missing
sum * //variables with missing values: registered_total registered_male registered_female 


foreach var of varlist registered_total registered_male registered_female {
replace `var' = . if `var'<0
}

*6 
tab town_id, gen(town_)

*7 
label var town_id "ID Town"
label var TownName "ID Name of Town"
label var distric "ID Name of Distric"
label var unique_id "ID Unique"

label var turnout_total "Electoral data total turnout"
label var turnout_male "Electoral data male turnout"
label var turnout_female "Electoral data female turnout"
label var registered_total "Electoral data total registered"
label var registered_male "Electoral data male registered"
label var registered_female "Electoral data female  registered"

label var registered_total "Electoral data total registered"
label var registered_male "Electoral data male registered"
label var registered_female "Electoral data female  registered"

label var treatment "Intervention"
label var treatment_phase "Intervention phase"


*8
lab define treatment 1"Treated" 0"Control"
lab val treatment treatment

******* II. Descriptive Statistics 

*9 Average
foreach x in total male female {
gen `x'_tr = turnout_`x'/registered_`x' * 100
}

sum total_tr

scalar average_turnout_rate = r(mean)
scalar min_turnout_rate = r(min)
scalar max_turnout_rate = r(max)

count if total_tr==100  //there are 20 polling booths with full electoral participation

*10
bysort treatment_phase: tab treatment

*11 
egen turnout_district = total(turnout_total), by(district)
egen registered_district = total(registered_total), by(district)
gen district_turnout_rate= turnout_district/registered_district * 100

egen turnout_district_female = total(turnout_female), by(district)
egen registered_district_female = total(registered_male), by(district)
gen district_turnout_rate_female= turnout_district/registered_district * 100

tabstat district_turnout_rate_female if district_turnout_rate>=75, by (district)
// There aren't observations because neither district has turnout over or equal 75%

*12
ttest female_tr, by(treatment)
//Acording to the test on the equality of means, the means are significantly different from each other at the 95% confidence level.
*Given the fact that female turnout is a dummy (from 0 to 1), the ttest can give a good approximation of the difference between proportions. 

*13
histogram turnout_total, freq  by (treatment)
graph export "$graphics/Graph_total turnout.pdf", replace
histogram turnout_female, freq  by (treatment)
graph export "$graphics/Graph_female turnout.pdf", replace

******* III. Regression
*14
reg turnout_total treatment i.town_id registered_total
outreg2 using "$outputs/s3p14.doc", label  bdec(3) sdec(3) drop(i.town_id) nor2 ///
addtext(Town dummies, Yes) replace

*15
sum turnout_total if treatment==0 & e(sample)
scalar mean_control = r(mean)

*16
reg turnout_total treatment i.town_id registered_total
mat coef=e(b)
scalar treat_effect = coef[1,1]

*17
sum turnout_total if treatment==1 & e(sample)

scalar mean_treated = r(mean)
scalar change_var = treat_effect/mean_treated * 100 

scalar list change_var //the change was 1.8%

*18
*The treatment had a positive  effect on the total turnout, specifically, the treatment increase  8.4 votes on average compared to the control group.
*This effect is stadistically significant at the 95% confidence level.

