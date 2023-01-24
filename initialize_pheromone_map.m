
function pheromone_map = initialize_pheromone_map(A)

    % Inizializza la mappa del feromone come una matrice 4D.
    % Tutti i voxel della matrice originale vengono settati a 0;
    % nella quarta dimensione si avrà, per ogni voxel, un valore
    % true (=1) o false (=0) rispettivamente se è già occupato o
    % meno. Ogni voxel ha un valore false inizialmente.
    %
    % Args
    % ----
    % A : 3d array di double
    %     La matrice dell'immagine.
    %
    % Output
    % ----
    % pheromone_map : 4d array di double
    %                 La mappa del feromone inizializzata.
    
    pheromone_map = zeros(size(A,1), size(A,2), size(A,3), 2);
end
