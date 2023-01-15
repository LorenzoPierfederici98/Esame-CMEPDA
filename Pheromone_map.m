classdef Pheromone_map
    properties
        A   %matrice che rappresenta l'immagine originale
    end
    methods (Static)
        function B = initialize_matrix(A)
            %inizializza la mappa del feromone come una matrice 4D.
            %Tutti i voxel della matrice originale vengono settati a 0;
            %la quarta dimensione avrà, per ogni voxel, un valore true(=1)
            %o false(=0) rispettivamente se è già occupato o meno.
            %Ogni voxel ha un valore false inizialmente.
            B = zeros(size(A,1), size(A,2), size(A,3), 2);
        end
    end


end
