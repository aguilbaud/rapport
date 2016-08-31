set term pdf enhanced color 
set output "bench_strong_nemo.pdf"
set ylabel "Efficiency"
set xlabel "Number of nodes"
set grid y
set grid x
set xtics 0,1
set yrange [0:1.2]

set title "Strong scalabily efficiency"
stats 'strong_per_nemo' using 0 nooutput

plot for [i=0:(STATS_blocks - 1)] 'strong_per_nemo' index i u 1:3 t column  w lp 
