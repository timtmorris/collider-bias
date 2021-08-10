********************************************************************************
* Stata programme for demonstrating collider bias in hypothetical studies
* Tim Morris
* 02/08/2021
********************************************************************************

* Creating collider programme. There are three arguments: 
* 		obs - the number of observations
* 		corr - the desired correlation between x and y
* 		pc - the desired percentile cutoff for sample selection
* 		int - the desired interaction effect
* 		sd - the desired variation on percentile sample selection
clear
capture program drop collider
qui program define collider
args obs corr pc int sd
drop _all
set obs `obs'
matrix C = (1, `corr' \ `corr', 1)
mat A = cholesky(C)
mat list A
gen c1= rnormal()
gen c2= rnormal()
gen x = c1
gen y = `corr'*c1 + A[2,2]*c2
gen z = x * y * `int'
gen e= rnormal(0,`sd')
gen tot=x+y+z+e
qui summ tot, detail
gen selected=1 if tot<r(p`pc')
replace selected=0 if selected==.
twoway 	(scatter x y if selected==1, mcolor(navy%10)) ///
		(scatter x y if selected==0, mcolor(maroon%10)) ///
		(lfit x y if selected==1, lcolor(black) lpattern(dash)) ///
		(lfit x y, lcolor(black) ///
		legend(order(1 "Selected observations" 2 "Non-selected observations" ///
		3 "Sample association" 4 "Population association")) ///
		ytitle("CVD (SD's)") xtitle("CMV (SD's)") ///
		graphregion(color(white)))
corr x y
corr x y if selected==1
end

********************************************************************************
* EXAMPLES: 
********************************************************************************

* No correlation:
collider 10000 0 75 0 0.5

* Positive correlation: 
collider 10000 0.3 75 0 0.5
