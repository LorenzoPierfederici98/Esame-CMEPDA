function Coordinates = initialize_coordinates(A, N_start, x, y, z)
        % Inizializza le coordinate dei voxel delle prime N_start formiche
        % selezionando casualmente le coordinate dei voxel primi vicini.
        %
        % Args
        % ----
        % B : 3d array di double
        %     La matrice dell'immagine.
        %
        % N_start : int
        %           Numero iniziale di formiche.
        %
        % x, y, z : int
        %           Le coordinate del voxel iniziale.
        %
        % Output
        % ------
        % Coordinates : 2d array di double
        %               Ogni riga contiene le coordinate degli N_start
        %               voxel da assegnare alle formiche.
        %
        % See also
        % --------
        % randperm

Coordinates = [];
neighbours = find_first_neigh(A, x, y, z);
all_first_neighbours = combvec(neighbours{1}, neighbours{2}, neighbours{3});  % Matrice le cui colonne sono le coordinate di tutti i voxel vicini a x, y, z

unique_combinations = randperm(N_start);  % Sequenza di numeri casuali senza ripetizioni per selezionare le colonne di all_first_neighbours
for j=1:N_start
    Coordinates = [Coordinates; all_first_neighbours(1,unique_combinations(j)), all_first_neighbours(2,unique_combinations(j)), all_first_neighbours(3,unique_combinations(j))];
end
