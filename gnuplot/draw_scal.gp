set term pdf enhanced color 
set output "bench_scalaire_nemo.pdf"
set title "Time per point (Non-periodic case)"
set ylabel "µs"
set xlabel "Domain size"
set grid y
set grid x
set yrange [0:5]
set xrange [0:250]
set key bottom right

stats 'scal_nonper_nemo' using 0 nooutput
plot for [i=0:(STATS_blocks - 1)]  'scal_nonper_nemo' index i t column w lp

set title "Time per point (Symmetric case)"
stats 'scal_sym_nemo' using 0 nooutput
plot for [i=0:(STATS_blocks - 1)]  'scal_sym_nemo' index i t column w lp

set title "Time per point (Periodic case)"
set y2label "Speedup"
set y2range [0:100]
set y2tics 
stats 'scal_per_nemo' using 0 nooutput
plot for [i=0:(STATS_blocks - 2)]  'scal_per_nemo' index i t column w lp axes x1y1
replot 'scal_per_nemo' index (STATS_blocks - 1) u 1:($2*100) t column w lp axes x1y2


#NEPTUNE
set yrange [0:5.5]
set output "bench_scalaire_neptune.pdf"
stats 'scal_nonper_neptune' using 0 nooutput
plot for [i=0:(STATS_blocks - 1)]  'scal_nonper_neptune' index i t column w lp

set title "Time per point (Symmetric case)"
stats 'scal_sym_neptune' using 0 nooutput
plot for [i=0:(STATS_blocks - 1)]  'scal_sym_neptune' index i t column w lp

set title "Time per point (Periodic case)"
stats 'scal_per_neptune' using 0 nooutput
plot for [i=0:(STATS_blocks - 1)]  'scal_per_neptune' index i t column w lp
