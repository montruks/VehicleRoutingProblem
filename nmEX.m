function [outputMatrix1, outputMatrix2, feasible] = nmEX(travelledArcs1, travelledArcs2, i, j, n, m, demands, capacity)
% funzione che opera lo scambio tra n nodi nel percorso 1 e m nodi nel percorso 2. Restituisce i nuovi percorsi e se la soluzione ottenuta è ammissibile o meno
% Inputs:
%   travelledArcsI: matrice che indica se l'arco da i a j è usato nel percorso 1 o meno
%   travelledArcsJ: matrice che indica se l'arco da i a j è usato nel percorso 2 o meno
%   i: indice del primo nodo da scambiare nel percorso 1
%   j: indice del primo nodo da scambiare nel percorso 2
%   n: numero di nodi da scambiare nel percorso 1
%   m: numero di nodi da scambiare nel percorso 2
%   demands: vettore che ad ogni punto associa la domanda
%   capacity: scalare che indica la capacità dei veicoli

% definisco numero di vertici 
    numVerteces = length(travelledArcs1);

% identifico quali sono i vertici da scambiare nei 2 percorsi
    swappedVertex1 = zeros(1, numVerteces);
    swappedVertex2 = zeros(1, numVerteces);
    toI = i;
    toJ = j;
    
    flag = 1;
    for i_n = 1:n
        if toI == 1
% non si vuole scambiare il vertice di origine perchè ciò porta all'inammissibilità
            flag = 0;
        end
        swappedVertex1(toI) = 1; 
        toI = find(travelledArcs1(toI, :) > 0);
    end
    for j_m = 1:m
        if toJ == 1 
% non si vuole scambiare il vertice di origine perchè ciò porta all'inammissibilità
            flag = 0;
        end
        swappedVertex2(toJ) = 1; 
        toJ = find(travelledArcs2(toJ, :) > 0);
    end
    
    if flag == 1
% opero lo scambio dei nodi prestando attenzione ai casi particolati n = 0 o m = 0

% inserisco gli m nodi del percorso 2 nel percorso 1
        outputMatrix1 = travelledArcs1;
        outputMatrix1(travelledArcs1(:, i) > 0, i) = 0;
        if m > 0
            outputMatrix1(travelledArcs1(:, i) > 0, j) = 1;
        end
        outputMatrix1(swappedVertex1 > 0, :) = zeros(sum(swappedVertex1), numVerteces);
        outputMatrix1(swappedVertex2 > 0, :) = travelledArcs2(swappedVertex2 > 0, :);
        if m > 0
            outputMatrix1(travelledArcs2(:, toJ) > 0, toJ) = 0;
            outputMatrix1(travelledArcs2(:, toJ) > 0, toI) = 1;
        else
            outputMatrix1(travelledArcs1(:, i) > 0, toI) = 1;
        end

% inserisco gli n nodi del percorso 1 nel percorso 2
        outputMatrix2 = travelledArcs2;
        outputMatrix2(travelledArcs2(:, j) > 0, j) = 0;
        if n > 0
            outputMatrix2(travelledArcs2(:, j) > 0, i) = 1;
        end
        outputMatrix2(swappedVertex2 > 0, :) = zeros(sum(swappedVertex2), numVerteces);
        outputMatrix2(swappedVertex1 > 0, :) = travelledArcs1(swappedVertex1 > 0, :);
        if n > 0
            outputMatrix2(travelledArcs1(:, toI) > 0, toI) = 0;
            outputMatrix2(travelledArcs1(:, toI) > 0, toJ) = 1;
        else
            outputMatrix2(travelledArcs2(:, j) > 0, toJ) = 1;
        end

% verifico l'ammissibilità della soluzione
        feasible = sum(outputMatrix1, 1)*demands < capacity && sum(outputMatrix2, 1)*demands < capacity;
    else
        outputMatrix1 = travelledArcs1;
        outputMatrix2 = travelledArcs2;
        feasible = 0;
    end
end

