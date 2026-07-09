function pesos_optimos = pirpen(datos, medida_riesgo, gmax)
%--------------------------------------------------------------------------
% Función: pirpen
%
% Implementa la estrategia de Ponderación Inversa al Riesgo Penalizada
% (PIR-PEN) propuesta en esta investigación.
%
% La función realiza una búsqueda determinística del parámetro de
% penalización λ con el objetivo de maximizar el índice de Sharpe,
% sujeto a una restricción sobre el coeficiente de Gini de los pesos
% del portafolio.
%
% Entradas:
%   datos           : Matriz de retornos (M observaciones × N activos).
%   medida_riesgo   : Medida de riesgo utilizada:
%                       'mad' -> Desviación Absoluta Mediana.
%                       'std' -> Desviación estándar.
%   gmax            : Valor máximo permitido para el coeficiente de Gini.
%                     Si no se especifica, se utiliza el valor
%                     (1 - 1/N)^N.
%
% Salida:
%   pesos_optimos   : Vector de pesos óptimos del portafolio.
%--------------------------------------------------------------------------

%% Número de activos

[~, numero_activos] = size(datos);

%% Validación de entradas

if nargin < 3
    gmax = (1 - 1/numero_activos)^numero_activos;
end

if ~ismember(medida_riesgo, {'mad','std'})
    error('La medida de riesgo debe ser ''mad'' o ''std''.');
end

%% Cálculo de la medida de riesgo

if strcmp(medida_riesgo,'mad')
    valores_riesgo = mad(datos);
else
    valores_riesgo = std(datos);
end

%% Inicialización

lambda = 1;
incremento = 0.1;
lambda_maximo = 50;

indices_sharpe = [];
coeficientes_gini = [];
valores_lambda = [];

%% Búsqueda determinística del parámetro de penalización

while lambda <= lambda_maximo

    % Calcular pesos mediante la estrategia PIR penalizada
    riesgo_penalizado = valores_riesgo.^lambda;
    pesos = 1 ./ riesgo_penalizado;
    pesos = pesos / sum(pesos);

    % Calcular el coeficiente de Gini
    gini_actual = gini_index(pesos);

    % Verificar la restricción de concentración
    if gini_actual > gmax
        break;
    end

    % Calcular el índice de Sharpe
    retornos_portafolio = datos * pesos';
    sharpe_actual = mean(retornos_portafolio) / std(retornos_portafolio);

    % Almacenar resultados
    indices_sharpe(end+1) = sharpe_actual;
    coeficientes_gini(end+1) = gini_actual;
    valores_lambda(end+1) = lambda;

    % Evaluar el siguiente valor de λ
    lambda = lambda + incremento;

end

%% Selección del parámetro óptimo

[~, indice_optimo] = max(indices_sharpe);
lambda_optimo = valores_lambda(indice_optimo);

%% Cálculo de los pesos óptimos

riesgo_penalizado = valores_riesgo.^lambda_optimo;
pesos_optimos = 1 ./ riesgo_penalizado;
pesos_optimos = pesos_optimos / sum(pesos_optimos);

end