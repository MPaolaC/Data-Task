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

