function first_neighbours = find_first_neigh(B, x, y, z)
         % Funzione che trova le coordinate dei voxel primi vicini al voxel
         % (x, y, z) considerando le dimensioni della matrice B.
         %
         % Args
         % ----
         % B : 4d array di double
         %
         % x, y, z : int
         %           Coordinate del voxel di cui cercare i primi vicini.
         %
         % Output
         % ------
         % first_neighbours : 2d cell array di int
         %                    Le colonne rappresentano rispettivamente le
         %                    coordinate x, y, z dei primi vicini.
                  
            if x ~=size(B, 1) &&  x ~= 1 
                a = x-1:x+1;
            elseif x==size(B,1)
                a = size(B,1)-1: size(B,1);
            elseif x==1
                a = 1:2;
            end
            if y ~=size(B, 2) &&  y ~= 1 
                b = y-1:y+1;
            elseif y==size(B,2)
                b = size(B,2)-1: size(B,2);
            elseif y==1
                b = 1:2;
            end
            if z ~=size(B, 3) && z ~= 1 
                c = z-1:z+1;
            elseif z==size(B,3)
                c = size(B,3)-1:size(B,3);
            elseif z==1
                c = 1:2;
            end
            first_neighbours{1} = a;
            first_neighbours{2} = b;
            first_neighbours{3} = c;
end