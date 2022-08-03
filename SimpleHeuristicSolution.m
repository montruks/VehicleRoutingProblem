function [travelledArcs, minDist, time] = SimpleHeuristicSolution(verteces, demands, numRoutes, capacity, distances)
% Funzione che calcola  in modo costruttivo una soluzione ammissibile per il VRP le euristiche
%   generalizedAssignment
%   insertionBasedMethod
% Inputs:
%   verteces: matrice contentente per ogni riga le coordinate x e y dei punti. Il punto di partenza è rappresentato dalla prima riga di questa matrice
%   demands: vettore che ad ogni punto associa la domanda
%   numRoutes: scalare con il numero di percorsi che si vuole creare. In questo caso il numero di percorsi creati è uguale a numRoutes e non minore o uguale a numRoutes
%   capacity: scalare che indica la capacità dei veicoli
%   disatnces: matrice contentente le distanze tra 2 punti
    
    tic;

% definisco numero di vertici
    numVerteces = length(verteces);
    
% prima assegno a ogni nodo un percorso
    [nodeInRoute] = GeneralizedAssignment(verteces, demands, numRoutes, capacity, distances);
    
% a seguire calcolo un cammino chiuso passante per tutti i nodi del percorso
    travelledArcs = zeros(numVerteces, numVerteces, numRoutes);
    for k=1:numRoutes
        [travelledArcs(nodeInRoute(:, k) > 0, nodeInRoute(:, k) > 0, k)] = ...
            InsertionBasedMethod(verteces(nodeInRoute(:, k) > 0, :),...
            distances(nodeInRoute(:, k) > 0, nodeInRoute(:, k) > 0));
    end
    
% calcolo dei valori di interesse
    minDist = sum(sum(travelledArcs, 3).*distances, "all");
    time = toc;

end

