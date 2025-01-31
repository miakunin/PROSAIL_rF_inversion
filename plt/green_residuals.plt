set terminal pngcairo enhanced size 2000,1650 font "Verdana,14"

set grid

set xlabel "Green area ratio"
set ylabel "Residuals"

set output "../plots/residuals_green_ratio_0407.png"

set key top left inside

set xrange [0:1]
set xtics 0.25

set multiplot layout 4,5 #title "Residuals vs green ratio, Cab" font ",14"

#set ytics 3

filename = "../data/plots_green_ratio_residuals_two_sets.csv"

set title " "

f(x) = m*x + b

do for [p=2:5] {

	if (p == 5) {
		set ytics 0.003
		set ytics format "%1.0e"
	}

do for [i=0:4] {
    if (i == 2) {
			if (p == 2) {
        set title "Cab" font ",19"
			}
			if (p == 3) {
        set title "Car" font ",19"
			}
			if (p == 4) {
        set title "LAI" font ",19"
			}
			if (p == 5) {
        set title "LMA" font ",19"
			}
    } else {
        set title " "
    }

		if (i == 0) {
				keyl = "IGM"
		}
 
		if (i == 1) {
				keyl = "EGM"
		}

 		if (i == 2) {
				keyl = "EGG"
		}

		if (i == 3) {
				keyl = "NutNet C"
		}
 
		if (i == 4) {
				keyl = "NutNet NPK"
		}

    fit f(x) filename using 6:p index i via m,b
    plot  filename u 6:p skip 1 index i notitle w points pt 7 ps 3, \
					filename u 6:p skip 1 index i t keyl w points pt 7 ps -1, \
          f(x) w l notitle lw 3
}
}

unset multiplot
