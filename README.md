# Vehicle Routing Problem

## Introduzione ##

Abbiamo svolto un problema VRP simmetrico con capacità monodimensionale, veicoli identici e in numero dato.

Sono stati implementati i seguenti script MatLab i quali generano due soluzioni, una semplice costruttiva e una iterativa che utilizza come punto di parteza la soluzione trovata in precedenza.

- *main*
- *SimpleHeuristicSolution*
- *GeneralizedAssignment*
- *InsertionBasedMethod*
- *LocalSearchTWOPT*
- *TabuSearch*
- *nmEX*

## Metodi Implementati ##

Nel *main* vengono caricati i dati presi da una libreria online e viene costruisce la matrice delle distanze euclidee; a seguire vengono eseguiti i diversi metodi per generare le 2 soluzioni e, infine, vengono stampati i risultati con i rispettivi plot.

La prima funzione che viene richiamata è *SimpleHeuristicSolution*, questa è una semplice euristica costruttiva del tipo *cluster-first, route-second*. All'interno viene prima richiamata la funzione *GeneralizedAssignment* la quale inizialmente assegna i seed in modo che siano i più lontani fra di loro e dal centro e del nodo centrale; successivamente assegna i nodi alla singola route risolvendo il problema di minimo

$$\min \sum_{i=1}^{n} \sum_{k=1}^{m} c_{ik}y_{ik}$$

$$s.t. \sum_{k=1}^{m} y_{ik} = 1, i=1,...,n$$

$$\sum_{i=1}^{n} p_{ik}y_{ik} < R_k, k = 1,...,m$$

$$y_{ik}\in \{0,1\}$$

dove le variabili decisionale $y_{ik}$ valgono 1 se il nodo $i$ è inserito nel percorso $k$, 0 altrimenti.
$c_{ik}$ è un'approssimaziona del costo di assegnare il  nodo $i$ al percorso $k$, questa approssimazione è fatta utilizzando il criterio delle extra miglia rispetto al deposito 0 e al seed $\sigma_k$, ovvero

$$c_{ik} = d_{0,i} +d_{i, \sigma_k} - d_{0, \sigma_k}.$$

Lo step successivo è l’esecuzione dell’*InsertionBasedMethod*, un’euristica costruttiva che dato un insieme di nodi crea un percorso passante per tutti i punti inserendone uno per volta, il nodo da inserire viene scelte sempre secondo il criterio delle extra miglia. Questa funzione viene chiamata separatamente per ogni percorso, si ottiene così una soluzione ammissibile per il VRP. 

Prima di usare questa soluzione come punto di partenza per il metodo iterativo, ottimizziamo la soluzione trovata eseguiendo *LocalSearchTWOPT*, un algoritmo che ottimizza separatamente ogni singola route esplorando dei vicini generati dalla regola *2-Opt*.
Viene ora eseguita la funzione *TabuSearch*, essa è un'euristica iterativa i cui parametri sono elencati di seguito:

- $N_{max}$: numero massimo di iterazioni senza nessun miglioramento
- $\alpha_{max}$: numero massimo di vicini generati nell’intorno
- $\beta_{max}$: numero massimo di scambi 2-Opt 
- $M$: numero massimo di vertici scambiati
- $(\theta_{min}, \theta_{max})$: bound sulla durata del tabu

Gli steps fondamentali del metodo sono i seguenti:

- Generare un vicino
  - Scegliere casualmente due percorsi R1 e R2
  - Scegliere casulamente n e m vertici (compresi tra 0 e M) rispettivamente da R1 e R2
  - Se questo inserimento porta all’inammissibilità si ripete il passaggio precendente
  - Inserire i vertici scelti utilizzando la procedura di inserimento: script \textit{“nmEX”}
  - Applicare la procedura 2-Opt a R1 e R2 indipendentemente per $\beta_{max}$ volte
  - Calcola il valore della funzione obiettivo della situazione finale
- Ripetere i passaggi precedenti per $\alpha_{max}$ volte
- Implementare la mossa con il miglior valore della funzione obiettivo, dopo di che gli scambi tra i 2 percorsi scelti diventano tabù.

Se tutte le mosse nell'intero vicinato diventano tabù, l'algoritmo sceglie la mossa tabù più vecchia e procede di conseguenza. Nella fase di miglioramento della soluzione ogni $3\cdot numVerteces$ l'algoritmo verifica se è stata trovata una nuova soluzione migliore. In caso contrario, torna all'ultima soluzione migliore.

## Risultati computazionali ##

I punti di partenza utilizzati nelle simulazioni sono 75 e 100. Per ciasco dei 2 casi sono stati analizzati 4 diverse distribuzioni iniziali chiamate semplicemente *a*, *b*, *c*, *d*. I metodi sono quelli descritti in precedenza: *SimpleHeuristic*, *2-Opt* e *Tabù search* con due diverse inizializzazioni del parametro $N_{max}$, ovvero $12\cdot numVerteces$ ( $12n$ )e $6\cdot numVerteces$ ( $6n$ ). La seguente tabella mostra i risultati per i vari casi e il valore ottimo nell'ultima colonna.
    
    \begin{figure}[H]
    \centering
        \includegraphics[width=1\textwidth]{Images/Cattura1.PNG}
    \end{figure}


\noindent I dati evidenziati in verde sono il valore ottimo mentre i dati evidenziati in arancio rappresentano la migliore delle soluzioni fra quelle ottenute dall'euristiche implementate.

Per quanto riguarda l'euristica costruttiva possiamo, in generale, osservare che se esiste una soluzione ammissibile, allora questa viene sicuramente trovata. Tuttavia, nei casi presi in esame si può vedere che la soluzione trovata è ben lontana dalla soluzione ottima.

Soffermandoci invece sulla soluzione ottimizzata con $2-Opt$ notiamo che essa produce dei risultati migliorando ogni singolo percorso, ma per quanto riguarda il problema nella sua interezza non vi è un grosso miglioramento.

Notiamo, infine, che la Tabù search ($12n$) è quella che si avvicina di più al minimo assoluto con un un'unica eccezione nel caso 75c in cui il risultato migliore è dato dalla Tabù search ($6n$).
Come si può vedere sono stati calcolati anche i tempi di esecuzione. Essi sono molto bassi per quanto riguarda il calcolo dell'euristica semplice che però porta a risultati di bassa qualità. La tabù serch ha dei tempi di esecuzione decisamente più alti, ma ciò si traduce in soluzioni di più alta qualità. Osservando le 2 diverse inizializzazioni della tabù search si nota un \emph{trade-off} tra tempo di esecuzione e qualità della soluzione trovata (entrambi maggiori nel caso ($12n$)). 

