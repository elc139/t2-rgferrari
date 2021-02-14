#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <sys/time.h>

typedef struct {
    double *a;
    double *b;
    double c;
    int wsize;
    int repeat;
} dotdata_t;

// Variaveis globais, acessiveis por todas threads
dotdata_t dotdata;

/*
 * Preenche vetor
 */ 
void fill(double *a, int size, double value)
{  
   int i;
   for (i = 0; i < size; i++) {
      a[i] = value;
   }
}

/* 
 * Distribui o trabalho entre nthreads
 */
void dotprod_threads(int nthreads)
{
    omp_set_num_threads(nthreads);
    int wsize = dotdata.wsize * nthreads;

    //double *mysum = (double *)malloc(nthreads * sizeof(double));
    //fill(mysum, nthreads, 0.0);

    double mysum = 0;
    double *a = dotdata.a;
    double *b = dotdata.b;

    //informa as variáveis compartilhadas entre as threads
    #pragma omp parallel for shared(mysum, a, b) 
    for(int i = 0; i < dotdata.repeat; i++){
        mysum = 0;

        //informa a variável q será modificada em cada iteração pela redução
        #pragma omp parallel for reduction(+: mysum)
        for (int j = 0; j < wsize; j++) {
            mysum += a[j] * b[j];
        }
    }
    
    dotdata.c = mysum;
}

/*
 * Tempo (wallclock) em microssegundos
 */ 
long wtime()
{
   struct timeval t;
   gettimeofday(&t, NULL);
   return t.tv_sec*1000000 + t.tv_usec;
}

/*
 * Funcao principal
 */ 
int main(int argc, char **argv)
{
   int nthreads, wsize, repeat;
   long start_time, end_time;

   if ((argc != 4)) {
      printf("Uso: %s <nthreads> <worksize> <repetitions>\n", argv[0]);
      exit(EXIT_FAILURE);
   }

   nthreads = atoi(argv[1]); 
   wsize = atoi(argv[2]);  // worksize = tamanho do vetor de cada thread
   repeat = atoi(argv[3]); // numero de repeticoes dos calculos (para aumentar carga)

   // Cria vetores
   dotdata.a = (double *) malloc(wsize*nthreads*sizeof(double));
   fill(dotdata.a, wsize*nthreads, 0.01);
   dotdata.b = (double *) malloc(wsize*nthreads*sizeof(double));
   fill(dotdata.b, wsize*nthreads, 1.0);
   dotdata.c = 0.0;
   dotdata.wsize = wsize;
   dotdata.repeat = repeat;

   // Calcula c = a . b em nthreads, medindo o tempo
   start_time = wtime();
   dotprod_threads(nthreads);
   end_time = wtime();

   // Mostra resultado e estatisticas da execucao
   printf("%f\n", dotdata.c);
   printf("%d thread(s), %ld usec\n", nthreads, (long) (end_time - start_time));
   fflush(stdout);

   free(dotdata.a);
   free(dotdata.b);

   return EXIT_SUCCESS;
}