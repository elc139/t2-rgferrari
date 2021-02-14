#!/bin/bash
N_THREADS=(1 2 4)
WORKSIZE=1000000
REPETITIONS=(2000 3000 4000)

echo "tool,nthreads,size,repetitions,usec" > results.csv

echo "|size|repetitions|threads|usec(média)|speedup|" > tabela_pthreads.md
echo "|:---:|:---:|:---:|:---:|:---:|" >> tabela_pthreads.md

echo "|size|repetitions|threads|usec(média)|speedup|" > tabela_openmp.md
echo "|:---:|:---:|:---:|:---:|:---:|" >> tabela_openmp.md

for i in {0..2}; do
    declare -a medias_pthreads
    declare -a medias_omp
    for j in {0..2}; do
        n_threads=${N_THREADS[$j]}
        size=$((WORKSIZE / n_threads))
        repetitions=${REPETITIONS[$i]}
        media_pthreads=0
        media_omp=0
        for k in {0..3}; do
           resultados_pthreads=($(./pthreads_dotprod/pthreads_dotprod $n_threads $size $repetitions))
           echo "Pthreads,$n_threads,$size,$repetitions,${resultados_pthreads[3]}" >> results.csv
           media_pthreads=$((media_pthreads + resultados_pthreads[3]))

           resultados_omp=($(./openmp/openmp_dotprod $n_threads $size $repetitions))
           echo "OpenMP,$n_threads,$size,$repetitions,${resultados_omp[3]}" >> results.csv
           media_omp=$((media_omp + resultados_omp[3]))
        done
        media_pthreads=$((media_pthreads / 4))
        medias_pthreads+=($media_pthreads)
        speedup=$(echo "scale=4; ${medias_pthreads[0]} / $media_pthreads" | bc -l) 
        echo "|${size}|${repetitions}|${n_threads}|${media_pthreads}|${speedup}|" >> tabela_pthreads.md

        media_omp=$((media_omp / 4))
        medias_omp+=($media_omp)
        speedup=$(echo "scale=4; ${medias_omp[0]} / $media_omp" | bc -l) 
        echo "|${size}|${repetitions}|${n_threads}|${media_omp}|${speedup}|" >> tabela_openmp.md
    done
    unset medias_pthreads
    unset medias_omp
done