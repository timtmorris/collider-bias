********************************************************************************
* Stata programme for demonstrating collider bias in hypothetical studies
* Tim Morris
* 02/08/2021
********************************************************************************

* Creating collider programme. There are three arguments: 
* 		obs - the number of observations
* 		corr - the desired correlation between x and y
* 		pc - the desired percentile cutoff for sample selection
clear
capture program drop collider
qui program define collider
args obs corr pc
drop _all
set obs `obs'
matrix C = (1, `corr' \ `corr', 1)
mat A = cholesky(C)
mat list A
gen c1= invnorm(uniform())
gen c2= invnorm(uniform())
gen x = c1
gen y = `corr'*c1 + A[2,2]*c2
gen tot=x+y
qui summ tot, detail
gen selected=1 if tot<r(p`pc')
replace selected=0 if selected==.
corr x y if selected==1
twoway 	(scatter x y if selected==1, mcolor(navy%20)) ///
		(scatter x y if selected==0, mcolor(maroon%20)) ///
		(lfit x y if selected==1, lcolor(black) lpattern(dash)) ///
		(lfit x y, lcolor(black) ///
		legend(order(1 "Selected observations" 2 "Non-selected observations" ///
		3 "Sample association" 4 "Population association")) ///
		ytitle("Y variable (SD's)") xtitle("X variable (SD's)") ///
		graphregion(color(white)))
corr x y
corr x y if selected==1
end

********************************************************************************
* EXAMPLES: 
********************************************************************************

* No correlation:
collider 10000 0 75

* Positive correlation: 
collider 10000 0.3 75
