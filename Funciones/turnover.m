function [turnover_medio, retornos_netos] = turnover( ...
    pesos, retornos, datos, tamano_ventana, costo_transaccion)
%--------------------------------------------------------------------------
% Función: turnover
%
% Calcula el turnover medio de una estrategia de inversión implementada
% mediante una ventana móvil (rolling window). Además, estima los retornos
% netos del portafolio considerando costos proporcionales por transacción.
%
% Entradas:
%   pesos               : Matriz de pesos del portafolio. Cada fila
%                         corresponde a una ventana de tiempo y cada
%                         columna a un activo.
%
%   retornos            : Vector de retornos del portafolio obtenido en
%                         cada ventana de evaluación.
%
%   datos               : Matriz de retornos de los activos.
%
%   tamano_ventana      : Tamaño de la ventana de estimación.
%
%   costo_transaccion   : Costo proporcional por transacción (basis
%                         points). Si no se desean considerar costos,
%                         utilizar costo_transaccion = 0.
%
% Salidas:
%   turnover_medio      : Turnover promedio de la estrategia.
%
%   retornos_netos      : Vector de retornos ajustados por costos de
%                         transacción.
%--------------------------------------------------------------------------

%% Dimensiones

[numero_ventanas, numero_activos] = size(pesos);

%% Inicialización

retornos_activos = zeros(numero_ventanas, numero_activos);
pesos_antes_rebalanceo = zeros(numero_ventanas - 1, numero_activos);
pesos_actualizados = zeros(numero_ventanas, numero_activos);

retornos_portafolio = retornos;

%% Retornos de cada activo ponderados por su participación

for t = 1 : numero_ventanas - 1
    for i = 1 : numero_activos
        retornos_activos(t,i) = pesos(t,i) * datos(t + tamano_ventana,i);
    end
end

%% Cálculo de los pesos antes del rebalanceo

for t = 2 : numero_ventanas - 1

    suma_pesos = 0;

    for j = 1 : numero_activos
        suma_pesos = suma_pesos + ...
            pesos(t-1,j) * (1 + retornos_activos(t,j));
    end

    for i = 1 : numero_activos

        pesos_actualizados(t,i) = ...
            pesos(t-1,i) * (1 + retornos_activos(t,i));

        pesos_antes_rebalanceo(t,i) = ...
            pesos_actualizados(t,i) / suma_pesos;

    end

end

%% Cálculo del turnover en cada ventana

turnover_periodo = zeros(numero_ventanas - 2,1);

for t = 2 : numero_ventanas - 1

    suma_diferencias_absolutas = 0;
    suma_diferencias = 0;

    for i = 1 : numero_activos

        diferencia = pesos(t,i) - pesos_antes_rebalanceo(t,i);

        suma_diferencias_absolutas = ...
            suma_diferencias_absolutas + abs(diferencia);

        suma_diferencias = ...
            suma_diferencias + diferencia;

    end

    turnover_periodo(t-1) = ...
        suma_diferencias_absolutas + abs(suma_diferencias);

end

%% Cálculo de los retornos netos

retornos_netos = zeros(numero_ventanas - 2,1);

for t = 1 : numero_ventanas - 2

    retornos_netos(t) = ...
        (1 + retornos_portafolio(t)) * ...
        (1 - turnover_periodo(t) * costo_transaccion) - 1;

end

%% Turnover promedio

turnover_medio = mean(turnover_periodo);

end