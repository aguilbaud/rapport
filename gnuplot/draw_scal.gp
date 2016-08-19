set term pdf enhanced color 
set output "bench_scalaire_nemo.pdf"
set ylabel "µs"
set xlabel "Domain size"
set grid y
set grid x
set yrange [0:5]
set xrange [15:400]
set key bottom right
set xtics (20,30,45,68,102,153,230,345)


set title "Time per point (Non-periodic case)"
stats 'scal_nonper_nemo' using 0 nooutput
set logscale x
plot for [i=0:(STATS_blocks - 1)]  'scal_nonper_nemo' index i t column w lp
unset logscale x

set title "Time per point (Symmetric case)"
stats 'scal_sym_nemo' using 0 nooutput
set logscale x
plot for [i=0:(STATS_blocks - 1)]  'scal_sym_nemo' index i t column w lp
unset logscale x

set title "Time per point (Periodic case)"
stats 'scal_per_nemo' using 0 nooutput
set logscale x
plot for [i=0:(STATS_blocks - 2)]  'scal_per_nemo' index i t column w lp axes x1y1
unset logscale x


#NEPTUNE
set yrange [0:5.5]
set output "bench_scalaire_neptune.pdf"

set title "Time per point (Non-periodic case)"
stats 'scal_nonper_neptune' using 0 nooutput
set logscale x
plot for [i=0:(STATS_blocks - 1)]  'scal_nonper_neptune' index i t column w lp
unset logscale x

set title "Time per point (Symmetric case)"
stats 'scal_sym_neptune' using 0 nooutput
set logscale x
plot for [i=0:(STATS_blocks - 1)]  'scal_sym_neptune' index i t column w lp
unset logscale x

set title "Time per point (Periodic case)"
stats 'scal_per_neptune' using 0 nooutput
set logscale x
plot for [i=0:(STATS_blocks - 1)]  'scal_per_neptune' index i t column w lp
unset logscale x


#Speedups
set output "bench_scalaire_speedup_nemo.pdf"
set title "Speedup Lenovo"
set ylabel "Speedup"
set yrange [0:2]
set logscale x

plot for [i=0:2] 'scal_speedup_nemo' index i t column w lp


set output "bench_scalaire_speedup_neptune.pdf"
set title "Speedup Bullx"

plot for [i=0:2] 'scal_speedup_neptune' index i t column w lp 
