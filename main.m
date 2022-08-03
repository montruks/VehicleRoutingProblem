%% Input data
clear
close all
clc

load('testSet/150a.mat');


%% Dati
% Calcolo matrice con le distanze euclidee 

numVerteces = length(verteces);
distances = zeros(numVerteces, numVerteces);
for i = 1 : numVerteces - 1
    for j = i + 1 : numVerteces
       distances(i, j) = sqrt((verteces(i, 1) - verteces(j, 1)).^2 + (verteces(i, 2) - verteces(j, 2)).^2);
       distances(j, i) = distances(i, j);
    end
end

%% Euristica semplice

[travelledArcs, minDist, time] = SimpleHeuristicSolution(verteces, demands, numRoutes, capacity, distances);
display(minDist);
display(time);

%% Plot

figure;
plot(verteces(:,1), verteces(:,2), 'k.');
hold on
axis equal
grid on
for k=1:numRoutes
    for i = 1:numVerteces
        for j = 1:numVerteces
            if travelledArcs(i, j, k) > 0.99
                color =  de2bi(64+k);
                plot([verteces(i,1), verteces(j,1)], [verteces(i,2), verteces(j,2)], Color=0.7*color(1:3)+0.3*color(4:6));
                hold on
            end
        end
    end
end
title('Solution')
hold off

%% Euristica iterativa

[travelledArcs, minDist, ~] = LocalSearchTWOPT(travelledArcs, distances, inf);
display(minDist);

[travelledArcs, minDist, numIterations, time] = TabuSearch(travelledArcs, distances, demands, capacity, 6*numVerteces, numRoutes*(numRoutes-1)/2, inf, 2, 5, 10);
display(minDist);
display(time);

display(minimum);

%% Plot

figure;
plot(verteces(:,1), verteces(:,2), 'k.');
hold on
axis equal
grid on
for k=1:numRoutes
    for i = 1:numVerteces
        for j = 1:numVerteces
            if travelledArcs(i, j, k) > 0.99
                color =  de2bi(64+k);
                plot([verteces(i,1), verteces(j,1)], [verteces(i,2), verteces(j,2)], Color=0.7*color(1:3)+0.3*color(4:6));
                hold on
            end
        end
    end
end
title('Solution')
hold off

