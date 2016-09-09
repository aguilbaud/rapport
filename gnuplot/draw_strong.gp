set style line 80 lt rgb "#808080"

# Line style for grid
set style line 81 lt 0  # dashed
set style line 81 lt rgb "#808080"  # grey

set grid back linestyle 81
set border 3 back linestyle 80 # Remove border on top and right.  These
             # borders are useless and make it harder
             # to see plotted lines near the border.
    # Also, put it in grey; no need for so much emphasis on a border.
set xtics nomirror
set ytics nomirror

#set log x
#set mxtics 10    # Makes logscale look good.

# Line styles: try to pick pleasing colors, rather
# than strictly primary colors or hard-to-see colors
# like gnuplot's default yellow.  Make the lines thick
# so they're easy to see in small plots in papers.



set terminal pdfcairo enhanced#font "Gill Sans,7"linewidth 2 rounded fontscale 1.0
set output "bench_strong_nemo.pdf"
set ylabel "Efficiency"
set xlabel "# of cores"
set grid y
set grid x
set yrange [0:1.2]
set xtics ("24" 1,"48" 2,"96" 4,"192" 8)
unset mxtics
set title "Strong scalability efficiency"
stats 'strong_per_nemo' using 0 nooutput

#plot for [i=0:(STATS_blocks - 1)] 'strong_per_nemo' index i u 1:3 t column  w lp ls 7 lc i+1 ps 0.5
plot for [i=0:0] 'strong_per_nemo' index i u 1:3 t column  w lp ls 7 lc i+1 ps 0.5

#
# Time percentage bargraph
#

set ylabel "Time percentage"
set y2label "Efficiency"
set xlabel "# of cores" offset 0,-1
set key outside right top
set yrange [0:100]
set y2range [0:1]
set y2tics
unset grid

set style data histograms
set style histogram rowstacked
set style fill transparent solid 0.75  border -1
set boxwidth 0.75
set grid y
unset xtics
set xtics
set ytics 10
set title "Time repartition - Periodic case"

plot 'strong_per_nemo2' using 2:xticlabel(1)  t column(2), for [i=3:4] '' using i:xticlabel(1) title column(i), '' using 5:xtic(1)  t col with lp ls 7 lw 2 ps 0.5 axes x1y2
#,'' using 6:xtic(1)  t col with lp ls 7 lw 2 lc 1 ps 0.5 axes x1y2

plot 'strong_per_nemo2_over4'  using 2:xticlabel(1)  t column(2), for [i=3:4] '' using i:xticlabel(1) title column(i), '' using 5:xtic(1)  t col with lp ls 7 lw 2 ps 0.5 axes x1y2

set title "Time repartition - Aperiodic case, 1st method"
plot 'strong_per_nemo_aper_1' using 2:xtic(1)  t column(2), for [i=3:4] '' using i title column(i), '' using 5:xtic(1)  t col with lp ls 7 lw 2 ps 0.5 axes x1y2

set title "Time repartition - Aperiodic case, 2nd method"
plot 'strong_per_nemo_aper_2' using 2:xtic(1)  t column(2), for [i=3:4] '' using i title column(i), '' using 5:xtic(1)  t col with lp ls 7 lw 2 ps 0.5 axes x1y2




