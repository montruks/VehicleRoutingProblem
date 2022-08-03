function [travelledArcs, minDist, numIterations, time] = TabuSearch(travelledArcs, distances, demands, capacity, N_max, alpha_max, beta_max, M, theta_min, theta_max)
% Funzione che migliora in modo iterativo una soluzione ammissibile tramite una ricerca locale di tipo tabu search 
% Inputs:
%   travelledArcs: iper-matrice che per ogni istanza (i, j, k) indica se l'arco da i a j è attivo nel percorso k
%   distances: matrice contentente le distanze tra 2 punti
%   demands: vettore che ad ogni punto associa la domanda
%   capacity: scalare che indica la capacità dei veicoli
%   N_max: numero massimo di iterazioni senza miglioramento
%   alpha_max: numero massimo di vicini generati
%   beta_max: numero massimo di iterazioni nell'algoritmo LoalSearchTWOPT
%   M: numero massimo di nodi scambiati tra 2 percorsi
%   (theta_min, theta_max): limiti sulla durata del tabu

    tic;

% definisco numero di vertici e numero di percorsi
    numRoutes = length(travelledArcs(1, 1, :));
    numVerteces = length(travelledArcs);

    % definisco delle variabili per gestire le iterazioni
    iterationMatrix = travelledArcs;

    minDist = sum(sum(travelledArcs, 3).*distances, "all");

    tabu = [nchoosek(1:numRoutes, 2), zeros(numRoutes*(numRoutes-1)/2, 1)];

    numIterations = 0;
    bestDeltaDist = 0;

    while numIterations < N_max && bestDeltaDist < inf

        tabu(tabu(:, 3) > 0, 3) = tabu(tabu(:, 3) > 0, 3) - 1;
        
% scelgo random alpha_max possibili coppie di percorsi tra cui effettuare gli scambi
        nonTabuExchanges = find(tabu(:, 3) == 0)';
        numNonTabuExchanges = length(nonTabuExchanges);
        random = randperm(numNonTabuExchanges, min(alpha_max, numNonTabuExchanges));

        tabu(nonTabuExchanges(random), 3) = 2;

        bestDeltaDist = inf;

        for index = nonTabuExchanges(random)
            partialDist = sum(iterationMatrix(:, :, tabu(index, 1)).*distances, "all") + sum(iterationMatrix(:, :, tabu(index, 2)).*distances, "all");
            
% per ogni possibile coppia di percorsi scelgo random un massimo di M nodi per percorso da scambiare 
% continuo a esplorare possibili scambi tra gli stessi 2 percorsi finchè non ne ottengo uno ammissibile
            exchangedNodes1 = randperm(M + 1, M + 1);
            exchangedNodes2 = randperm(M + 1, M + 1);
            nodesInRoute1 = find(sum(iterationMatrix(:, :, tabu(index, 1)), 1) > 0);
            nodesInRoute2 = find(sum(iterationMatrix(:, :, tabu(index, 2)), 1) > 0);
            
            feasible = 0;
            
            nn = M + 1;
            while nn > 0 && feasible == 0
                n = exchangedNodes1(nn) - 1;
                mm = M +1;
                while mm > 0 && feasible == 0
                    m = exchangedNodes2(mm) - 1;
                    ii = length(nodesInRoute1);
                    while ii > 0 && feasible == 0 && n + m > 0
                        i = nodesInRoute1(ii);
                        jj = length(nodesInRoute2);
                        while jj > 0 && feasible == 0 && i > 1
                            j = nodesInRoute2(jj);
                            if j > 1
                                [outputMatrix1, outputMatrix2, feasible] = nmEX(iterationMatrix(:, :, tabu(index, 1)), iterationMatrix(:, :, tabu(index, 2)), i, j, n, m, demands, capacity);
                                if feasible
% quando trovo uno scambio ammissibile ottimizzo i 2 percorsi appena creati usando LocalSearchTWOPT  
                                    [outputMatrix1, ~, ~] = LocalSearchTWOPT(outputMatrix1, distances, beta_max);
                                    [outputMatrix2, ~, ~] = LocalSearchTWOPT(outputMatrix2, distances, beta_max);
                                    deltaDist = sum(outputMatrix1.*distances, "all") + sum(outputMatrix2.*distances, "all") - partialDist;
                                    if deltaDist < bestDeltaDist
                                        bestDeltaDist = deltaDist;
                                        bestNeighbourMatrix = iterationMatrix;
                                        bestNeighbourMatrix(:, :, tabu(index, 1)) = outputMatrix1;
                                        bestNeighbourMatrix(:, :, tabu(index, 2)) = outputMatrix2;
                                        bestIndex = index;
                                    end
                                end
                            end
                            jj = jj - 1;
                        end
                        ii = ii -1;
                    end
                    mm = mm - 1;
                end
                nn = nn - 1;
            end
        end
        
        if bestDeltaDist < inf
% se è stato trovato un vicino ammissibile mi sposto in quello che minimizza la funzione obiettivo
            iterationMatrix = bestNeighbourMatrix;
            tabu(bestIndex, 3) = randi([theta_min, theta_max]);
            numIterations = numIterations + 1;
            
            dist = sum(sum(iterationMatrix, 3).*distances, "all");
            if dist < minDist
% se il vicino trovato è la migliore soluzione trovata fin'ora azzero il contatore delle itarezione
                minDist = dist;
                numIterations = 0;
                travelledArcs = iterationMatrix;
            end
        elseif sum(tabu(:, 3), "all") > 2*length(random)
% se non sono state trovate soluzioni ammissibili procedo secondo la mossa che è tabu da più tempo
            bestDeltaDist = 0;
            tabu(tabu(:, 3) > 0, 3) = tabu(tabu(:, 3) > 0, 3) - min(tabu(tabu(:, 3) > 0, 3)) + 1;
        end
        
% se non sono state trovatesoluzioni migliori in 3*numVerteces iterazioni torno alla soluzione migliore precedente
        if mod(numIterations, 3*numVerteces) == 0
            iterationMatrix = travelledArcs;
        end
    end

% calcolo dei valori di interesse
    time = toc;

end

