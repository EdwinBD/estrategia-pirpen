function coeficiente_gini = gini_index(pesos)
%--------------------------------------------------------------------------
% Función: gini_index
%
% Calcula el coeficiente de Gini asociado a un vector de pesos.
%
% El coeficiente de Gini se utiliza como medida de concentración de los
% pesos del portafolio. Valores cercanos a cero indican una distribución
% más uniforme, mientras que valores cercanos a uno representan una mayor
% concentración.
%
% Entrada:
%   pesos               : Vector de pesos del portafolio.
%
% Salida:
%   coeficiente_gini    : Coeficiente de Gini.
%--------------------------------------------------------------------------

%% Ordenar los pesos de forma creciente

% El orden ascendente es indispensable para aplicar correctamente la
% expresión del coeficiente de Gini utilizada en esta investigación.

pesos_ordenados = sort(pesos,'ascend');

%% Número de activos

numero_activos = length(pesos);

%% Cálculo de la suma ponderada

suma_ponderada = 0;

for i = 1:numero_activos

    suma_ponderada = suma_ponderada + ...
        (2*i - 1) * pesos_ordenados(i);

end

%% Cálculo del coeficiente de Gini

coeficiente_gini = suma_ponderada / numero_activos - 1;

%% Garantizar que el resultado pertenezca al intervalo [0,1]

coeficiente_gini = max(0, min(1, coeficiente_gini));

end