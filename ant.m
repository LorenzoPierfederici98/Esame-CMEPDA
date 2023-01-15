
classdef ant
    properties
        x   %coordinate del voxel iniziale
        y   %
        z   %
        number = 1; %numero per il conteggio delle formiche
        energy; %energia iniziale
    end
    methods (Static)

        function im_here = mark_voxel(B, x, y, z)
            B(x, y, z, 2) = true;
            im_here = B(x, y, z, 2);
        end

        function im_here = leave_voxel(B, x, y, z)
            B(x, y, z, 2) = false;
            im_here = B(x, y, z, 2);
        end

        function vox_value = pheromone_release(A, eta, x, y, z)
            vox_value = eta + 10*A(x, y, z);
        end

        function E = update_energy(e, alfa, pheromone, pheromone_mean)
            if pheromone == 0
                E = e;
            else
                E = e - alfa*(1 - pheromone/pheromone_mean);
            end
        end

        function output = evaluate_destination(B, delta, beta, x, y, z)
            %trovo i primi vicini considerando le dimensioni della matrice
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
            if z ~=size(B, 3) &&  z ~= 1 
                c = z-1:z+1;
            elseif z==size(B,3)
                c = size(B,3)-1:size(B,3);
            elseif z==1
                c = 1:2;
            end
            
            W = []; %calcola la probabilit� di passare dal voxel i al voxel j
            [X, Y, Z] = findND(B(a, b, c, 2)==false);   %seleziono solo i voxel primi vicini liberi
            X = X'; %i vettori colonna vengono trasposti in vettori riga
            Y = Y';
            Z = Z';
            if isempty(find(X==1))~=1 && x~= 1
                X(find(X==1)) = x-1;
            end
            if isempty(find(X==2))~=1 && x~= 1
                X(find(X==2)) = x;
            end
            if isempty(find(X==3))~=1&& x~=size(B,1)
                X(find(X==3)) = x+1;
            end
            
            if isempty(find(Y==1))~=1 && y~= 1
                Y(find(Y==1)) = y-1;
            end
            if isempty(find(Y==2))~=1 && y~= 1
                Y(find(Y==2)) = y;
            end
            if isempty(find(Y==3))~=1&& y~=size(B,2)
                Y(find(Y==3)) = y+1;
            end

            if isempty(find(Z==1))~=1 && z~= 1
                Z(find(Z==1)) = z-1;
            end
            if isempty(find(Z==2))~=1 && z~= 1
                Z(find(Z==2)) = z;
            end
            if isempty(find(Z==3))~=1&& z~=size(B,3)
                Z(find(Z==3)) = z+1;
            end

            Mat = [X; Y; Z];
            for i=1:length(X)
                x1 = Mat(1, i);
                y1 = Mat(2, i);
                z1 = Mat(3, i);
                W = [W,(1 + B(x1, y1, z1, 1)./(1 + delta*B(x1, y1, z1, 1))).^beta];
            end

            %W(find(W==(1 + B(x, y, z)./(1 + 0.2*B(x, y, z))).^3.5)) = []; %rimuovo il voxel corrente x, y, z
            W = reshape(W, 1, []);
            %W contiene le probabilit� di passare ai voxel primi vicini  
            W = W./sum(W); %probabilit� di transizione ad un voxel
            P = cumsum(W);
            num = rand(); %numero causale fra 0 e 1
            j = find(P>=num, 1); %il primo indice per cui P(i)>=num
            %J = zeros(length(X), length(Y), length(Z));
            %J = reshape(1:length(W), [length(X), length(Y), length(Z)]); %J contiene tutti i possibili j (da 1 a length(W))
            %[nextvox_x, nextvox_y, nextvox_z] = findND(J==j) %trova gli indici della posizione di j, che saranno le coordinate del prossimo voxel
            %if isempty(j) == 1
                %[M, I] = max(W);
                %j = I;
            %end
            W = zeros(size(W));
            output = [X(j), Y(j), Z(j)];
        end
    end
end


