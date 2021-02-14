# Programação Paralela Multithread

Nome: René Gargano Ferrari

## Pthreads

### Perguntas

1. Explique como se encontram implementadas as 4 etapas de projeto: particionamento, comunicação, aglomeração, mapeamento (use trechos de código para ilustrar a explicação).

   O **Particionamento** consiste em analizar o que no programa pode ser feito em paralelo. No caso a multiplicação dos vetores pode ser dividida entre as threads e somada no final. O particionamento dos vetores é feito nas linhas 34 e 35 e a multiplicação na linha 41:
   
   ```c
   int start = offset*wsize;                 // linha 34
   int end = start + wsize;                  // linha 35
   double mysum;                             // linha 36
                                             // linha 37   
   for (k = 0; k < dotdata.repeat; k++) {    // linha 38
      mysum = 0.0;                           // linha 39
      for (i = start; i < end ; i++)  {      // linha 40
         mysum += (a[i] * b[i]);             // linha 41
      }                                      // linha 42
   }                                         // linha 43
   ```
   
   A **Comunicação** trata-se dos dados que uma thread precisa ter da outra thread pra continuar executando. Nesse caso as threads precisavam saber se havia alguma thread executando na zona crítica do programa para poder prosseguir. Isso acontece nas linhas 45, 46, 47:
   
   ```c
   pthread_mutex_lock (&mutexsum);      // linha 45
   dotdata.c += mysum;                  // linha 46
   pthread_mutex_unlock (&mutexsum);    // linha 47
   ```
   
   A **Aglomeração** ocorre ao juntarmos os dados calculados em paralelo. No caso desse programa ela acontece na linha 46, onde todas as multiplicações são somadas em uma variável compartilhada por todas as threads:
   
   ```c
   dotdata.c += mysum;  // linha 46
   ```
   
   O **Mapeamento** é feito quando se divide de forma igual o trabalho entre todas as threads. Isso acontece quando o programa atribui um tamanho de vetor (worksize) igual para todas as threads, nas linhas 114, 123 e 33:
   
   ```c
   wsize = atoi(argv[2]);        // linha 114
   ...
   dotdata.wsize = wsize;        // linha 123
   ...
   int wsize = dotdata.wsize;    // linha 33
   ```

2. Considerando o tempo (em microssegundos) mostrado na saída do programa, qual foi a aceleração (speedup) com o uso de threads?

   **speedup** = **1_thread_time** / **n_threads_time**

   **speedup** = 6652438 / 3293453 = 2.01989 vezes

3. A aceleração se sustenta para outros tamanhos de vetores, números de threads e repetições? Para responder a essa questão, você terá que realizar diversas execuções, variando o tamanho do problema (tamanho dos vetores e número de repetições) e o número de threads (1, 2, 4, 8..., dependendo do número de núcleos). Cada caso deve ser executado várias vezes, para depois calcular-se um tempo de processamento médio para cada caso. Atenção aos fatores que podem interferir na confiabilidade da medição: uso compartilhado do computador, tempos muito pequenos, etc.

   A aceleração se sustentou para testes com até 4 threads. Com 2 threads houve uma aceleração em torno de **1.7x** e com 4 threads de **2.4x**. A variação do número de repetições teve influência no tempo de execução, mas não na aceleração. Os testes foram feitos com o seguinte [Shell Script](https://github.com/elc139/t2-rgferrari/blob/master/execution_test.sh) e é possível observar os resultados na próxima questão.

4. Elabore um gráfico/tabela de aceleração a partir dos dados obtidos no exercício anterior.

   |size|repetitions|threads|usec(média)|speedup|
   |:---:|:---:|:---:|:---:|:---:|
   |1000000|2000|1|6150937|1.0000|
   |500000|2000|2|3537221|1.7389|
   |250000|2000|4|2441191|2.5196|
   |1000000|3000|1|9148910|1.0000|
   |500000|3000|2|5337825|1.7139|
   |250000|3000|4|3677165|2.4880|
   |1000000|4000|1|12221683|1.0000|
   |500000|4000|2|6921560|1.7657|
   |250000|4000|4|4951454|2.4683|

5. Explique as diferenças entre pthreads_dotprod.c e pthreads_dotprod2.c. Com as linhas removidas, o programa está correto?

   A diferença entre o programa pthreads_dotprod.c e pthreads_dotprod2.c está nas linhas 45 e 47:

   ```c
   pthread_mutex_lock (&mutexsum);      // linha 45
   dotdata.c += mysum;                  // linha 46
   pthread_mutex_unlock (&mutexsum);    // linha 47
   ```

   Como a variável dotdata.c é compartilhada por todas as threads em execução do programa, se forem atribuidos valores a ela ao mesmo tempo por mais de uma thread o resultado pode se tornar não determinístico. Para isso é utilizado no pthreads_dotprod.c a função ``` pthread_mutex_lock()``` que, quando a variável mutexsum não está bloqueada ele a bloqueia e segue em frente. Caso a variável já esteja bloqueada a função interrompe a execução da thread e aguarda a liberação da variável pela thread que a está usando, com a função ```pthread_mutex_unlock()```. 
   
   Ou seja, com as linhas removidas, não é formada uma área de exclusão mútua, deixando o programa incorreto, pois dá chance a resultados não determinísticos.

### Referências

- Linux Documentation. pthread_mutex_lock(3) - Linux man page. https://linux.die.net/man/3/pthread_mutex_lock.
- The Heirloom Project. SH (1). http://heirloom.sourceforge.net/sh/sh.1.html.

## OpenMP

1. Implemente um programa equivalente a pthreads_dotprod.c usando OpenMP.

   [Programa](https://github.com/elc139/t2-rgferrari/blob/master/openmp/openmp_dotprod.c) implementado.

2. Avalie o desempenho do programa em OpenMP, usando os mesmos dados/argumentos do programa com threads POSIX.

   Foram realizados os mesmos testes feitos com Pthreads. A aceleração se manteve em torno de **1.7x** para 2 threads e **2.4x** para 4 threads. Observam-se os resultados na tabela abaixo.  

   |size|repetitions|threads|usec(média)|speedup|
   |:---:|:---:|:---:|:---:|:---:|
   |1000000|2000|1|6066925|1.0000|
   |500000|2000|2|3380981|1.7944|
   |250000|2000|4|2517252|2.4101|
   |1000000|3000|1|9148878|1.0000|
   |500000|3000|2|5093484|1.7961|
   |250000|3000|4|3736830|2.4482|
   |1000000|4000|1|12125893|1.0000|
   |500000|4000|2|6744475|1.7979|
   |250000|4000|4|5032534|2.4095|

### Referências

- dubita illustrandas. Programação Paralela OpenMP - Aula 1 - Equipe DUBITA. https://www.youtube.com/watch?v=1JU931jZP2s.
- Jaka's Corner. OpenMP: For & Reduction. http://jakascorner.com/blog/2016/06/omp-for-reduction.html.
