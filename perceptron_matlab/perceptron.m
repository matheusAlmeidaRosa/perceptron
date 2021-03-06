% lendo o arquivo dos dados;
M = csvread('data.csv');
% definindo uma matriz tal que as classificacoes sejam 1 - 100, 2 - 010 e 3 - 001
M_binary_classes = zeros(size(M,1),3);
% matriz final que juntará as classificacoes em "binario" e as colunas das
%features;
total = zeros(size(M,1)+3,size(M,2)-1);

%loop de mapeamento das classificacoes
for i = 1:size(M,1)
    if(M(i,1) == 1)
        M_binary_classes(i,1) = 1;
        M_binary_classes(i,2) = 0;
        M_binary_classes(i,3) = 0;
    end
    if(M(i,1) == 2)
        M_binary_classes(i,1) = 0;
        M_binary_classes(i,2) = 1;
        M_binary_classes(i,3) = 0;
    end
    if(M(i,1) == 3)
        M_binary_classes(i,1) = 0;
        M_binary_classes(i,2) = 0;
        M_binary_classes(i,3) = 1;
    end
    total = [M_binary_classes M(:,2:14)];
end

% vetor de indices aleatorios;
rand_index = randperm(size(total,1));

% aleatorizacao da matriz final
rand_total = zeros(size(total));
for i = 1:size(total,1)
   rand_total(i,:) = total(rand_index(i),:);
end

total = rand_total;

% vetor de bias a ser inserido na matriz de entradas;
bias = ones(size(total,1),1);
% vetor de referencia;
D = total(:,1:3);
% vetor auxiliar com as colunas das features;
aux = total(:,4:16);
% vetor final de entradas;
X = [bias aux];

% processo de normalizacao (min-max) do vetor de entradas;
for i = 2:size(X,2)
    X(:,i) = (X(:,i) - min(X(:,i)))/(max(X(:,i)) - min(X(:,i)));
end

% separando grupo de teste: 1/3 das amostras;
NX = size(X,1);
ND = size(D,1);
X_teste = X(118:NX,:);
D_teste = D(118:ND,:);

% separando grupo de treinamento: 2/3 das amostras;
X = X(1:117,:);
% vetor de pesos sinapticos;
W = zeros(size(D,2),size(X,2));
% variavel de iteracao;
t = 1;
% variavel do erro médio quadrático das epocas;
E = 1;
% numero maximo de iteracoes;
max_it = 50;
% numero de linhas do vetor de entradas;
N = size(X,1);
% matriz auxiliar com a transposta da matriz de entradas;
X_transp = X';
% taxa de aprendizado da rede;
alpha = 0.001;
% vetor que armazena os erros de cada epoca;
E_epoca = zeros(1,max_it);
% loop principal de TREINAMENTO: atualizacao dos pesos, calculo do erro objetivo;
while (t < max_it) && (E > 0)
   E = 0;
   for i = 1:N
       yi = hardlim(W*X_transp(:,i));
       ei = D(i,:)' - yi;
       W = W + alpha*ei*X(i,:);
       E = E + ei'*ei;
   end
   E_epoca(t) = E;
   t = t+1;
end

% exibição dos resultados para o treinamento;
figure;
title('Erro de treinamento');
xlabel('iteracoes');
ylabel('erro de treinamento');
plot(E_epoca);

% Verificaao de taxa de acerto
X_transp = X_teste';
acertos = 0;
for i = 1:size(X_transp,2)
  yi = hardlim(W*X_transp(:,i));
  if D_teste(i,:)'== yi;
    acertos++;
  end
end

fprintf('Taxa de acerto: %.2f %%\n', 100*acertos/size(X_transp,2));
