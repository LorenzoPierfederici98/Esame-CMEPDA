
classdef ant 

    % Classe che rappresenta la singola formica.
    % Attributi: 
    %  x, y, z : int
    %            Le coordinate del voxel in cui è presente la formica.
    %
    %  number : int
    %           Un numero che tiene conto di tutte le formiche nello
    %           ambiente.
    %
    %  energy : double
    %           L'energia, che determina l'evoluzione della formica
    %           (riproduzione e morte). Inizialmente settata a 1.2.
    %
    %  alfa, eta, delta, beta : double
    %                           Costanti che determinano l'evoluzione del
    %                           sistema.
    % Metodi:
    %  mark_voxel : implementa la segnalazione alla colonia della
    %  presenza della formica nel voxel, così che questo non sia una
    %  destinazione possibile per altre formiche;
    %
    %  leave_voxel : implementa la segnalazione alla colonia che la
    %  formica ha lasciato il voxel, così che questo possa essere visitato
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
        energy = 1.2;
    end
    properties (SetAccess = private)
        alfa = 0.2;
        beta = 3.5;
        delta = 2;        
        eta = 0.01;
        propor_factor = 1;

    end

    methods(Static)

        function im_here = mark_voxel()
            % Marca il voxel presente.
            %
            % Output
            % ------
            % im_here : bool
            %           Valore assegnato al voxel in cui è presente la
            %           formica per segnalarne la presenza.

            im_here = true;

        end

        function im_here = leave_voxel()
            % Vedi mark_voxel. Il voxel assume il valore false quando la
            % formica si sposta.

            im_here = false;

        end
    end
    methods

        function vox_value = pheromone_release(obj, A)
            % Compone la mappa del feromone tramite un rilascio
            % proporzionale alla differenza fra l'intensità del voxel
            % dell'immagine originale e del minimo valore di intensità, con 
            % un  offset 'eta' che la formica rilascia anche ad intensità 
            % del voxel nulla.
            %
            % Args
            % ------
            % A : 3d array di double
            %     Matrice originale dell'immagine
            %
            % Output
            % ------
            % vox_value : double
            %             Quantità di feromone rilasciato.

            vox_value = obj.eta + obj.propor_factor*(A(obj.x, obj.y, obj.z) - min(A(:)));

        end

        function Energy = update_energy(obj, pheromone, pheromone_mean)
            % L'attributo energy della formica viene aggiornato in base 
            % alla quantità di feromone rilasciato dalla singola formica e 
            % dalla media di feromone rilasciato da tutta la colonia dallo
            % inizio dell'evoluzione. L'aggiornamento è fatto in modo che
            % la formica non compia più di 2 passi in una zona senza
            % feromone.
            %
            % Args
            % ------
            % pheromone : double
            %             La quantità di feromone al netto della costante
            %             eta.
            %
            % pheromone_mean : double
            %                  La media della quantità di feromone
            %                  rilasciata da tutta la coloniadall'inizio
            %                  dell'evoluzione.
            %
            % Output
            % ------
            % Energy : double
            %          L'energia aggiornata della formica.

            if pheromone == 0
                Energy = obj.energy - obj.alfa;
            else
                Energy = obj.energy - obj.alfa*(1 - pheromone/pheromone_mean);
            end

        end

        function obj = set.energy(obj, value)
            obj.energy = value;
        end

        function obj = set.x(obj, value)
            obj.x = value;
        end
    
        function obj = set.y(obj, value)
            obj.y = value;
        end

        function obj = set.z(obj, value)
            obj.z = value;
        end   

        function next_voxel = evaluate_destination(obj, pheromone_thr, B)
            % Valuta la prossima destinazione della formica in base alle
            % dimensioni della matrice dell'immagine ed ai voxel liberi.
            % Vengono trovati i voxel primi vicini a quello di partenza in
            % cui non sia presente un'altra formica e che non superino una
            % certa soglia di feromone; ad ognuno viene assegnata una 
            % probabilità di transizione che tiene conto della quantità di 
            % feromone al suo interno. Viene quindi applicato un algoritmo 
            % "roulette wheel" per scegliere il voxel di destinazione.
            % Gli attributi x, y, z vengono aggiornati come coordinate del
            % voxel scelto.
            %
            % Args
            % ------
            % pheromone_thr : double
            %                 Soglia di feromone oltre la quale un certo
            %                 voxel non rappresenti più una possibile
            %                 destinazione.
            %
            % B : 4d array di double
            %     La mappa del feromone.
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

            % Trova i primi vicini, considerando le dimensioni della matrice
            first_neigh = find_first_neigh(B, obj.x, obj.y, obj.z);

            % Tutte le combinazioni delle coordinate dei primi vicini, ogni
            % riga corrisponde alle coordinate x, y, z di un voxel primo
            % vicino
            first_neigh = combvec(first_neigh{1}, first_neigh{2}, first_neigh{3})';

            W = [];  % Calcola e salva in array le quantità W per ogni possibile
                     % voxel di destinazione

            [X, Y, Z] = findND(B(:, :, :, 2)==0 & B(:, :, :, 1)<=pheromone_thr);  % Seleziona solo i voxel liberi
                                                                                  % con un valore di feromone minore della soglia
            X = X';  % I vettori colonna vengono trasposti in vettori riga
            Y = Y';  
            Z = Z';
                                                                           
            if isempty([X; Y; Z])==1
                next_voxel = [];
                return
            end
             
            % Vettore colonna con 1 o 0 a seconda che le coordinate dei
            % primi vicini siano incluse in [X, Y, Z] o meno
            valid_members = ismember(first_neigh, [X; Y; Z]', 'rows');

            % Seleziona solo i primi vicini che abbiano valore 1 in
            % valid_members. Ogni colonna rappresenta le coordinate x, y, z
            % di ogni possibile voxel di destinazione
            valid_first_neigh = first_neigh(valid_members', :)';

            % Per ogni voxel viene calcolato un elemento di W
            for i=1:size(valid_first_neigh, 2)
                x1 = valid_first_neigh(1, i);
                y1 = valid_first_neigh(2, i);
                z1 = valid_first_neigh(3, i);
                W = [W,(1 + B(x1, y1, z1, 1)./(1 + obj.delta*B(x1, y1, z1, 1))).^obj.beta];
            end
           
            W = reshape(W, 1, []);

            % Algoritmo roulette wheel: viene calcolato l'array di
            % probabilità P di passare ad ogni possibile voxel di
            % destinazione, corrispondente ad un certo indice di W. Viene
            % quindi estratto un numero casuale fra 0 e 1, num, e viene
            % selezionato il primo indice di P, j, tale che P(j)>=num, che 
            % corrisponderà all'indice del voxel di destinazione

            P = cumsum(W./sum(W));
            num = rand();
            j = find(P>=num, 1);  
            next_voxel = [valid_first_neigh(1,j), valid_first_neigh(2, j), valid_first_neigh(3, j)];

        end
    end

end



