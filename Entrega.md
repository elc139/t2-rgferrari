# Programação Paralela Multithread

Nome: René Gargano Ferrari

## Pthreads

### Perguntas

1. Explique como se encontram implementadas as 4 etapas de projeto: particionamento, comunicação, aglomeração, mapeamento (use trechos de código para ilustrar a explicação).

2. Considerando o tempo (em microssegundos) mostrado na saída do programa, qual foi a aceleração (speedup) com o uso de threads?

**speedup** = **1_thread_time** / **n_threads_time**

**speedup** = 6652438 / 3293453 = 2.01989 vezes

3. A aceleração se sustenta para outros tamanhos de vetores, números de threads e repetições? Para responder a essa questão, você terá que realizar diversas execuções, variando o tamanho do problema (tamanho dos vetores e número de repetições) e o número de threads (1, 2, 4, 8..., dependendo do número de núcleos). Cada caso deve ser executado várias vezes, para depois calcular-se um tempo de processamento médio para cada caso. Atenção aos fatores que podem interferir na confiabilidade da medição: uso compartilhado do computador, tempos muito pequenos, etc.

4. Elabore um gráfico/tabela de aceleração a partir dos dados obtidos no exercício anterior.

5. Explique as diferenças entre pthreads_dotprod.c e pthreads_dotprod2.c. Com as linhas removidas, o programa está correto?

A diferença entre o programa pthreads_dotprod.c e pthreads_dotprod2.c está nas linhas 45 e 47:

```c
   pthread_mutex_lock (&mutexsum);      // linha 45
   dotdata.c += mysum;                  // linha 46
   pthread_mutex_unlock (&mutexsum);    // linha 47
```

Como a variável dotdata.c é compartilhada por todas as threads em execução do programa, se forem atribuidos valores a ela ao mesmo tempo por mais de uma thread o resultado pode se tornar não determinístico. Para isso é utilizado no pthreads_dotprod.c a função ```c pthread_mutex_lock()``` que, quando a variável mutexsum não está bloqueada ele a bloqueia e segue em frente. Caso a variável já esteja bloqueada a função interrompe a execução da thread e aguarda a liberação da variável pela thread que a está usando, com a função ```c pthread_mutex_unlock()```. 

Ou seja, com as linhas removidas, não é formada uma área de exclusão mútua, deixando o programa incorreto, pois dá chance a resultados não determinísticos.

### Referências

- Linux Documentation. pthread_mutex_lock(3) - Linux man page. https://linux.die.net/man/3/pthread_mutex_lock.
- Complete aqui: Autor (nome de pessoa ou instituição). Título. URL.

## OpenMP

### Referências

- Complete aqui: Autor (nome de pessoa ou instituição). Título. URL.
