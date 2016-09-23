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

red_000 = "#F9B7B0"
red_025 = "#F97A6D"
red_050 = "#E62B17"
red_075 = "#8F463F"
red_100 = "#6D0D03"

blue_000 = "#A9BDE6"
blue_025 = "#7297E6"
blue_050 = "#1D4599"
blue_075 = "#2F3F60"
blue_100 = "#031A49"

green_000 = "#A6EBB5"
green_025 = "#67EB84"
green_050 = "#11AD34"
green_075 = "#2F6C3D"
green_100 = "#025214"

brown_000 = "#F9E0B0"
brown_025 = "#F9C96D"
brown_050 = "#E69F17"
brown_075 = "#8F743F"
brown_100 = "#6D4903"

my_line_width = "2"
# Line styles: try to pick pleasing colors, rather
# than strictly primary colors or hard-to-see colors
# like gnuplot's default yellow.  Make the lines thick
# so they're easy to see in small plots in papers.
set style line 1 linecolor rgbcolor blue_025 linewidth my_line_width pt 7
set style line 2 linecolor rgbcolor green_025 linewidth my_line_width pt 5
set style line 3 linecolor rgbcolor red_025 linewidth my_line_width pt 9
set style line 4 linecolor rgbcolor brown_025 linewidth my_line_width pt 13
set style line 5 linecolor rgbcolor blue_050 linewidth my_line_width pt 11
set style line 6 linecolor rgbcolor green_050 linewidth my_line_width pt 7
set style line 7 linecolor rgbcolor red_050 linewidth my_line_width pt 5
set style line 8 linecolor rgbcolor brown_050 linewidth my_line_width pt 9
set style line 9 linecolor rgbcolor blue_075 linewidth my_line_width pt 13
set style line 10 linecolor rgbcolor green_075 linewidth my_line_width pt 11
set style line 11 linecolor rgbcolor red_075 linewidth my_line_width pt 7
set style line 12 linecolor rgbcolor brown_075 linewidth my_line_width pt 5
set style line 13 linecolor rgbcolor blue_100 linewidth my_line_width pt 9
set style line 14 linecolor rgbcolor green_100 linewidth my_line_width pt 13
set style line 15 linecolor rgbcolor red_100 linewidth my_line_width pt 11
set style line 16 linecolor rgbcolor brown_100 linewidth my_line_width pt 7
set style line 17 linecolor rgbcolor "#224499" linewidth my_line_width pt 5


set terminal pdfcairo enhanced#font "Gill Sans,7"linewidth 2 rounded fontscale 1.0
set output "bench_strong_nemo.pdf"
set ylabel "Speedup"
set xlabel "# of cores"
set grid y
set grid x
#set yrange [0:1.2]
#set xtics ("24" 1,"48" 2,"96" 4,"192" 8)
unset mxtics
set key inside left top
set title "Speedup\n{/*0.7  Overlap 6 - 40 time steps - 400^3}"
stats 'strong_per_nemo' using 0 nooutput

#plot for [i=0:(STATS_blocks - 1)] 'strong_per_nemo' index i u 1:3 t column  w lp ls 7 lc i+1 ps 0.5
plot for [i=0:0] 'strong_per_nemo' index i u ($1*24):5 t column  w lp ls 3 lw 3 ps 0.5, '' index i u ($1*24):1 t 'Maximal' w lp ls 1 lw 3 ps 0.5


plot for [i=1:2] 'strong_per_nemo' index i u ($1*24):5 t column  w lp ls 3+i lw 3 ps 0.5, '' index i u ($1*24):1 t 'Maximal' w lp ls 1 lw 3 ps 0.5
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
set style fill solid  border -1
 
set boxwidth 0.75
set grid y
unset xtics
set xtics
set ytics 10
set title "Time repartition - Periodic case\n{/*0.7 Overlap 6 - 40 time steps - 400^3}"

plot 'strong_per_nemo2' using 2:xticlabel(1)  t column(2) ls 3, for [i=3:4] '' using i:xticlabel(1) title column(i) ls i-2, '' using 5:xtic(1)  t col with lp ls 11  ps 0.5 axes x1y2
#,'' using 6:xtic(1)  t col with lp ls 7 lw 2 lc 1 ps 0.5 axes x1y2

#plot 'strong_per_nemo2_over4'  using 2:xticlabel(1)  t column(2) ls 3, for [i=3:4] '' using i:xticlabel(1) title column(i), '' using 5:xtic(1)  t col with lp ls 7 lw 2 ps 0.5 axes x1y2

set title "Time repartition - Aperiodic case, Trivial method\n{/*0.7 Overlap 6 - 40 time steps - 400^3}"
plot 'strong_per_nemo_aper_1' using 2:xtic(1)  t column(2) ls 3, for [i=3:4] '' using i title column(i) ls i-2, '' using 5:xtic(1)  t col with lp ls 11 lw 2 ps 0.5 axes x1y2

set title "Time repartition - Aperiodic case, Constant size method\n{/*0.7 Overlap 6 - 40 time steps - 400^3}"
plot 'strong_per_nemo_aper_2' using 2:xtic(1)  t column(2) ls 3, for [i=3:4] '' using i title column(i) ls i-2, '' using 5:xtic(1)  t col with lp ls 11 ps 0.5 axes x1y2



set title "Bandwith influence\n{/*0.7}"
set ylabel "Time/point (µs)"
set xlabel "# of cores" offset 0,-1
set yrange[0:8]
unset y2tics
unset x2tics
unset y2label
set xtics 2
set ytics 1
set grid x

plot 'bandwith_influence' using 1:2 t column(2) w lp ls 1 lw 3  ps 0.5, '' u 1:3 t column(3) w lp ls 3 lw 3 ps 0.5
