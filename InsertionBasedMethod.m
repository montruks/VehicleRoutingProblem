function [travelledArcs] = InsertionBasedMethod(verteces, distances)
% Crea una soluzione costruttiva per il TSP usando il criterio delle extra miglia
% Inputs:
%   verteces: matrice contentente per ogni riga le coordinate x e y dei punti. Il punto di partenza è rappresentato dalla prima riga di questa matrice
%   disatnces: matrice contentente le distanze tra 2 punti

% definisco numero di vertici
    numVerteces = length(verteces);
    
% cerco arco di lunghezza minima
    costMatrix = distances + diag(NaN*zeros(numVerteces, 1));
    [~,index] = min(costMatrix(:));
    i = mod(index - 1, numVerteces) + 1; 
    j = ceil(index/numVerteces);

    isInserted = zeros(numVerteces, 1);
    isInserted(i) = 1;
    isInserted(j) = 1;

    travelledArcs = zeros(numVerteces,numVerteces);
    travelledArcs(i, j) = 1;
    travelledArcs(j, i) = 1;
    
    for iter = 3:numVerteces
% definisco la matrice con le distanze tra i nodi inseriti e i nodi non inseriti e cerco il nodo più vicino
        costMatrix = distances;
        costMatrix (isInserted < 1, :) = NaN;
        costMatrix (:, isInserted > 0) = NaN; 
        [~,k] = min(costMatrix(:));
        k = ceil(k/numVerteces);
        isInserted(k) = 1;

% definisco vettore con le extra miglia e cerco l'arco che le minimizza
% il nuovo nodo più vicino verrà inserito al posto dell'arco appena trovato
        costMatrix = costMatrix(:, k) + travelledArcs*distances(:, k) - sum(travelledArcs.*distances, 2); % vettore con extra millage se inserisco il nodo dopo i
        [~,i] = min(costMatrix);
        j = find(travelledArcs(i, :) > 0);
        travelledArcs(i, j) = 0;
        travelledArcs(i, k) = 1;
        travelledArcs(k, j) = 1;
    end
    
end

