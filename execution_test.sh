#!/bin/bash
N_THREADS=(1 2 4)
WORKSIZE=1000000
REPETITIONS=(2000 3000 4000)

echo "tool,nthreads,size,repetitions,usec" > results.csv
echo "|size|repetitions|threads|usec(média)|speedup|" > tabela.md
echo "|:---:|:---:|:---:|:---:|:---:|" >> tabela.md

for i in {0..2}; do
    declare -a medias
    for j in {0..2}; do
        SIZE=$((WORKSIZE / N_THREADS[$j]))
        media=0
        for k in {0..3}; do
           resultados=($(./pthreads_dotprod/pthreads_dotprod ${N_THREADS[$j]} $SIZE ${REPETITIONS[$i]}))
           echo "Pthreads,${N_THREADS[$j]},$SIZE,${REPETITIONS[$i]},${resultados[3]}" >> results.csv
           media=$((sum + resultados[3]))
        done
        media=$((media / 4))
        medias+=($media)
        speedup=$(echo "scale=4; ${medias[0]} / $media" | bc -l) 
        echo "|${SIZE}|${REPETITIONS[$i]}|${N_THREADS[$j]}|${media}|${speedup}|" >> tabela.md 
    done
    unset medias
done