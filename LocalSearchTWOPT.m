function [travelledArcs, minDist, numIterations] = LocalSearchTWOPT(travelledArcs, distances, maxIterations)
% metodo iterativo che migliora la soluzione del TSP attreverso degli scambi di archi del tepo 2-Opt 
% Inputs:
%   travelledArcs: iper-matrice che per ogni istanza (i, j, k) indica se l'arco da i a j è attivo nel percorso k
%   disatnces: matrice contentente le distanze tra 2 punti 
%   maxIterations: numero massimo di iterazioni

% definisco numero di percorsi
    numRoutes = length(travelledArcs(1, 1, :));
    numIterations = zeros(numRoutes, 1);

    for k = 1:numRoutes
% definisco delle variabili per gestire le iterazioni
        travelledArcsMatrix = travelledArcs(:, :, k);

        usedVerteces = find(sum(travelledArcsMatrix, 1) > 0);
        numVertecesInRoute = sum(travelledArcsMatrix, "all");

        distanceNew = sum(travelledArcsMatrix.*distances, "all");
        distanceOld = 2*distanceNew;
        
        while (numIterations(k) < maxIterations && distanceNew < distanceOld)
            distanceOld = distanceNew;
        
            for i = usedVerteces
                for j = usedVerteces
                    if j > i
% per ogni coppia di archi opero uno scambio
% è molto più facile lavorare con una versione simmetrica della matrice
                        simmetricMatrix = travelledArcsMatrix + travelledArcsMatrix';
                    
                        simmetricMatrix(i, travelledArcsMatrix(i, :) > 0) = 0;
                        simmetricMatrix(travelledArcsMatrix(i, :) > 0, i) = 0;
                        simmetricMatrix(j, travelledArcsMatrix(j, :) > 0) = 0;
                        simmetricMatrix(travelledArcsMatrix(j, :) > 0, j) = 0;
                    
                        simmetricMatrix(i, j) = 1;
                        simmetricMatrix(j, i) = 1;
                        simmetricMatrix(travelledArcsMatrix(j, :) > 0, travelledArcsMatrix(i, :) > 0) = 1;
                        simmetricMatrix(travelledArcsMatrix(i, :) > 0, travelledArcsMatrix(j, :) > 0) = 1;

                        dist = sum(triu(simmetricMatrix).*distances, "all");
                        if dist < distanceNew
% se ottengo un miglioramento ritrasmormo la matrice simmetria in una orientata
                            distanceNew = dist;
                            bestMatrix = simmetricMatrix;

                            indexPrec = find(bestMatrix(1, :) > 0, 1);
                            bestMatrix(1, indexPrec) = 0;
                            indexPrec = 1;
                            indexSucc = find(bestMatrix(1, :) > 0, 1);
                        
                            for w = 2:numVertecesInRoute
                                bestMatrix(indexSucc, indexPrec) = 0;
                                indexPrec = indexSucc;
                                indexSucc = find(bestMatrix(indexSucc, :) > 0, 1);
                            end
                        end
                    end
                end
            end
        
            if distanceNew < distanceOld
% se nell'intorno della mia soluzione attule esiste una soluzione migliore mi muovo in quella direzione
                travelledArcs(:, :, k) = bestMatrix;
                numIterations(k) = numIterations(k) + 1;
            end
        end
    end

% calcolo dei valori di interesse
    minDist = sum(sum(travelledArcs, 3).*distances, "all");

end

