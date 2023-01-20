function Coordinates = initialize_coordinates(B, Ant, x, y, z)
        % Inizializza le coordinate dei voxel delle prime formiche
Coordinates = [];
neighbours = find_first_neigh(B, x, y, z);
a = neighbours{1};
b = neighbours{2};
c = neighbours{3};
All_first_neighbours = combvec(a, b, c);  % Matrice le cui colonne sono le coordinate di tutti i voxel vicini a x, y, z

j = 1;
for i=1:length(Ant)
    Ant(i).x = All_first_neighbours(1,j);
    Ant(i).y = All_first_neighbours(2,j);
    Ant(i).z = All_first_neighbours(3,j);
    Coordinates = [Coordinates; Ant(i).x, Ant(i).y, Ant(i).z];
    j = j + 1;
end
