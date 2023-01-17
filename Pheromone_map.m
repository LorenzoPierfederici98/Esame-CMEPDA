classdef Pheromone_map

    % Classe che rappresenta la mappa del feromone.
    % Attributi:
    % A : 3d array di double
    %       La matrice originale dell'immagine
    %
    % Metodi:
    % initialize_matrix : implementa l'inizializzazione della mappa del
    % feromone.

    properties
        A 
    end
    methods 
        function B = initialize_matrix(obj)
            % inizializza la mappa del feromone come una matrice 4D.
            % Tutti i voxel della matrice originale vengono settati a 0;
            % nella quarta dimensione si avrà, per ogni voxel, un valore
            % true (=1) o false (=0) rispettivamente se è già occupato o
            % meno. Ogni voxel ha un valore false inizialmente.
            %
            % Output
            % ----
            % B : 4d array di double
            %     La mappa del feromone inizializzata.
            B = zeros(size(obj.A,1), size(obj.A,2), size(obj.A,3), 2);
        end
    end


end
