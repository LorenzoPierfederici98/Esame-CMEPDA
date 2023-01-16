
classdef ant < handle

    % Classe che rappresenta la singola formica.
    % Attributi: 
    %  x, y, z : int
    %            Le coordinate del voxel in cui � presente la formica.
    %
    %  number : int
    %           Un numero che tiene conto di tutte le formiche nello
    %           ambiente.
    %
    %  energy : double
    %           L'energia, che determina l'evoluzione della formica
    %           (riproduzione e morte). Inizialmente settata a 1.2.
    %
    % Metodi:
    %  mark_voxel : implementa la segnalazione alla colonia della
    %  presenza della formica nel voxel, cos� che questo non sia una
    %  destinazione possibile per altre formiche;
    %
    %  leave_voxel : implementa la segnalazione alla colonia che la
    %  formica ha lasciato il voxel, cos� che questo possa essere visitato
    %  da altre formiche;
    %
    %  pheromone_release : implementa il rilascio di feromone da parte
    %  della formica nel voxel presente;
    %
    %  update_energy : implementa l'aggiornamento dell'energia della
    %  formica dopo il rilascio di feromone;
    %
    %  evaluate_destination : implementa la valutazione del prossimo
    %  voxel di destinazione della formica in dipendenza dalle dimensioni
    %  della matrice e dai voxel liberi.
 
    properties
        x;  
        y;  
        z;        
        number = 1;
        energy = 1.2;  
    end
    
    methods (Static)

        function im_here = mark_voxel(B, x, y, z)
            % Marca il voxel presente.
            %
            % Args
            % ------
            % B : 4d array di double
            %     La mappa del feromone. La quarta dimensione consente di
            %     attribuire un valore true (=1) o false (=0) se � o meno
            %     presente una formica.
            %
            % x, y, z : int
            %           Le coordinate del voxel da marcare.
            %
            % Output
            % ------
            % im_here : bool
            %           Valore assegnato al voxel in cui � presente la
            %           formica per segnalarne la presenza.

            B(x, y, z, 2) = true;
            im_here = B(x, y, z, 2);

        end

        function im_here = leave_voxel(B, x, y, z)
            % Vedi mark_voxel. Il voxel assume il valore false quando la
            % formica si sposta.

            B(x, y, z, 2) = false;
            im_here = B(x, y, z, 2);

        end

        function vox_value = pheromone_release(A, eta, x, y, z)
            % Compone la mappa del feromone tramite un rilascio
            % proporzionale alla intensit� del voxel dell'immagine
            % originale, con un  offset 'eta' che la formica rilascia anche 
            % ad intensit� del voxel nulla.
            %
            % Args
            % ------
            % A : 3d array di double
            %     Matrice originale dell'immagine.
            %
            % eta : double
            %       Valore dell'offset.
            %
            % x, y, z : int
            %           Coordinate del voxel in cui � presente la formica
            %           ed in cui viene rilasciato il feromone.
            %
            % Output
            % ------
            % vox_value : double
            %             Quantit� di feromone rilasciato.

            vox_value = eta + (A(x, y, z) - min(A(:)));

        end

        function E = update_energy(e, alfa, pheromone, pheromone_mean)
            % Aggiorna l'energia della formica in base alla quantit� di
            % feromone rilasciato dalla singola formica e dalla media di
            % feromone rilasciato da tutta la colonia dall'inizio
            % dell'evoluzione. L'aggiornamento � fatto in modo che la
            % formica non compia pi� di 2 passi in una zona senza feromone.
            %
            % Args
            % ------
            % e : double
            %     L'energia della formica da aggiornare.
            %
            % alfa : double
            %        E' una costante dell'evoluzione del sistema con valore
            %        0.2 cos� che, se la formica si sposta consecutivamente
            %        in due voxel senza feromone, avr� energia <1 che ne
            %        causer� la morte.
            %
            % pheromone : double
            %             La quantit� di feromone al netto della costante
            %             eta.
            %
            % pheromone_mean : double
            %                  La media della quantit� di feromone
            %                  rilasciata da tutta la coloniadall'inizio
            %                  dell'evoluzione.
            %
            % Output
            % ------
            % E : double
            %     L'energia aggiornata della formica.

            if pheromone == 0
                E = e - alfa;
            else
                E = e - alfa*(1 - pheromone/pheromone_mean);
            end

        end

        function next_voxel = evaluate_destination(B, delta, beta, x, y, z)
            % Valuta la prossima destinazione della formica in base alle
            % dimensioni della matrice dell'immagine ed ai voxel liberi.
            % Vengono trovati i voxel primi vicini a quello di partenza in
            % cui non sia presente un'altra formica e ad ognuno viene
            % assegnata una probabilit� di transizione che tiene conto
            % della quantit� di feromone al suo interno. Viene quindi
            % applicato un algoritmo "roulette wheel" per scegliere il
            % voxel di destinazione.
            %
            % Args
            % ------
            % B : 4d array di double
            %     La mappa del feromone.
            %
            % delta, beta : double
            %               Costanti dell'evoluzione del sistema,
            %               rispettivamente 0.2 e 3.5. beta � la
            %               'osmotropotaxic sensitivity': maggiore � beta e
            %               maggiore � l'importanza del valore del feromone
            %               per la decisione del voxel di destinazione.
            %               delta � la capacit� sensoriale: all'aumentare
            %               della quantit� di feromone in un voxel
            %               diminuisce la sensibilit� della formica verso
            %               di esso.
            %
            % x, y, z : int
            %           Le coordinate del voxel di partenza.
            %
            % Output
            % ------
            % next_voxel : array di int
            %              Array con le coordinate del voxel di
            %              destinazione.
            %
            % See also
            % --------
            % findND : funzione che trova le coordinate di un ndarray che
            %          rispetti una certa condizione.

            % Trova i primi vicini, le cui coordinate vengono salvate negli
            % array a, b e c, considerando le dimensioni della matrice
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
            
            W = [];  % Calcola e salva in array le quantit� W per ogni possibile
                     % voxel di destinazione

            [X, Y, Z] = findND(B(a, b, c, 2)==false);  % Seleziona solo i voxel primi vicini liberi

            X = X';  % I vettori colonna vengono trasposti in vettori riga
            Y = Y';  % X, Y, Z sono array di lunghezza pari al numero di primi vicini liberi
            Z = Z';

            % findND fornisce degli indici 1, 2 e 3 della sottomatrice
            % length(a)*length(b)*length(c) della mappa del feromone. Gli
            % indici vengono riconvertiti in coordinate
            if isempty(find(X==1, 1))~=1 && x~= 1
                X(X==1) = x-1;
            end
            if isempty(find(X==2, 1))~=1 && x~= 1
                X(X==2) = x;
            end
            if isempty(find(X==3, 1))~=1&& x~=size(B,1)
                X(X==3) = x+1;
            end
            
            if isempty(find(Y==1, 1))~=1 && y~= 1
                Y(Y==1) = y-1;
            end
            if isempty(find(Y==2, 1))~=1 && y~= 1
                Y(Y==2) = y;
            end
            if isempty(find(Y==3, 1))~=1&& y~=size(B,2)
                Y(Y==3) = y+1;
            end

            if isempty(find(Z==1, 1))~=1 && z~= 1
                Z(Z==1) = z-1;
            end
            if isempty(find(Z==2, 1))~=1 && z~= 1
                Z(Z==2) = z;
            end
            if isempty(find(Z==3, 1))~=1&& z~=size(B,3)
                Z(Z==3) = z+1;
            end
            
            % X, Y, Z vengono disposti in una matrice di dimensioni
            % 3*(numero di primi vicini liberi). Ogni colonna � quindi
            % composta dalle coordinate di un possibile voxel di
            % destinazione. Per ogni voxel viene calcolato un elemento di W
            Mat = [X; Y; Z];
            for i=1:length(X)
                x1 = Mat(1, i);
                y1 = Mat(2, i);
                z1 = Mat(3, i);
                W = [W,(1 + B(x1, y1, z1, 1)./(1 + delta*B(x1, y1, z1, 1))).^beta];
            end
           
            W = reshape(W, 1, []);

            % Algoritmo roulette wheel: viene calcolato l'array di
            % probabilit� P di passare ad ogni possibile voxel di
            % destinazione, corrispondente ad un certo indice di W. Viene
            % quindi estratto un numero casuale fra 0 e 1, num, e viene
            % selezionato il primo indice di P, j, tale che P(j)>=num, che 
            % corrisponder� all'indice del voxel di destinazione

            P = cumsum(W./sum(W));
            num = rand();
            j = find(P>=num, 1);  
            next_voxel = [X(j), Y(j), Z(j)];
        end
    end

end



