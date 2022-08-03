function [nodeInRoute] = GeneralizedAssignment(verteces, demands, numRoutes, capacity, distances)
% Funzione assegna i nodi a un percorso in modo che siano rispettati i vincoli di capacità
% Inputs:
%   verteces: matrice contentente per ogni riga le coordinate x e y dei punti. Il punto di partenza è rappresentato dalla prima riga di questa matrice
%   demands: vettore che ad ogni punto associa la domanda
%   numRoutes: scalare con il numero di percorsi che si vuole creare. In questo caso il numero di percorsi creati è uguale a numRoutes e non minore o uguale a numRoutes
%   capacity: scalare che indica la capacità dei veicoli
%   disatnces: matrice contentente le distanze tra 2 punti

% definisco numero di vertici
    numVerteces = length(verteces);

% definisco i seed in modo da massimizzare la distanza tra essi e il nodo di partenza
    isSeed = zeros(numVerteces, 1);
    isSeed(1) = 1;
    seed = zeros(numRoutes,1);

    for k=1:numRoutes
        [~, index] = max(sum(distances(isSeed > 0, :).*(1-isSeed)', 1));
        seed(k) = index;
        isSeed(index) = 1;
    end

% definisco matrice dei costi usando il criterio delle extra miglia
    costMatrix = zeros(numVerteces, numRoutes);
    for i=1:numVerteces
        for k=1:numRoutes
            costMatrix(i,k) = distances(1,i) + distances(i,seed(k)) - distances(1,seed(k));
        end
    end

% Definisco ora problema di ottimizzazione lineare intera da risolvere
    problem = optimproblem('ObjectiveSense', 'min');
    nodeInRoute = optimvar('nodeInRoute', numVerteces, numRoutes, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);
    problem.Objective = sum(nodeInRoute.*costMatrix, "all");

% vincoli di assegnamento ad un unico percorso
    assignConstraint = optimconstr(numVerteces-1);
    for j = 1:numVerteces-1
        assignConstraint(j) = sum(nodeInRoute(j+1, :), "all") == 1;
    end
    problem.Constraints.AssignConstraint = assignConstraint;

    originAssign = optimconstr(numRoutes);
    for k = 1:numRoutes
        originAssign(k) = nodeInRoute(1, k) == 1;
    end
    problem.Constraints.OriginAssign = originAssign;

% vincoli sulla capacità
    capacityConstr = optimconstr(numRoutes);
    for k = 1:numRoutes
        capacityConstr(k) = sum(nodeInRoute(:, k).*demands) <= capacity;
    end
    problem.Constraints.CapacityConstr = capacityConstr;

% soluzione
    options = optimoptions('intlinprog', 'RelativeGapTolerance', 0.05);
    [sol,~,~,~] = solve(problem,'Options',options);
    nodeInRoute = round(sol.nodeInRoute);

end

