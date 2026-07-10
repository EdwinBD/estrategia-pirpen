%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script: evaluacion_sharpe_sin_costos.m
%
% Este script evalúa el desempeño de seis estrategias de selección de
% portafolios utilizando diferentes tamaños de ventana móvil.
%
% Para cada tamaño de ventana se calcula el índice de Sharpe promedio sin
% considerar costos de transacción y posteriormente se genera una tabla en
% formato LaTeX utilizada en la tesis.
%
% Estrategias evaluadas:
%   1. Media-Varianza
%   2. Mínima Varianza
%   3. Ponderación Inversa al Riesgo (PIR)
%   4. PIR Penalizada con desviación estándar (PIR-STD)
%   5. PIR Penalizada con MAD (PIR-MAD)
%   6. Portafolio Naive (1/N)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clc
tic


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configuración de rutas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ruta_script = fileparts(mfilename('fullpath'));

addpath(fullfile(ruta_script,'..','Funciones'));

ruta_datos = fullfile(ruta_script,'..','Datos');

%% Carga de datos

load(fullfile(ruta_datos,'data5.mat'));

datos = data5 / 100;

[numero_periodos, numero_activos] = size(datos);

%% Configuración del experimento

gamma = 1;

ventanas = 60:30:600;
numero_ventanas = length(ventanas);

nombres_estrategias = { ...
    'Media-Varianza', ...
    'Minima-Varianza', ...
    'PIR', ...
    'PIR-STD', ...
    'PIR-MAD', ...
    'Naive'};

tabla_sharpe = zeros(numero_ventanas,6);

%% Evaluación para cada tamaño de ventana

for v = 1:numero_ventanas

    tamano_ventana = ventanas(v);

    % Portafolio equiponderado
    pesos_naive = ones(1,numero_activos)/numero_activos;

    % Retornos obtenidos por cada estrategia
    retornos_estrategias = zeros(numero_periodos-tamano_ventana,6);

    for k = 1:(numero_periodos-tamano_ventana)

        datos_ventana = datos(k:k+tamano_ventana-1,:);

        %% Estrategia Media-Varianza

        media = mean(datos_ventana);

        pesos_media_varianza = quadprog( ...
            cov(datos_ventana), ...
            -media/gamma, ...
            [],[], ...
            ones(1,numero_activos), ...
            1, ...
            zeros(numero_activos,1), ...
            ones(numero_activos,1));

        %% Estrategia Mínima Varianza

        pesos_minima_varianza = quadprog( ...
            cov(datos_ventana), ...
            zeros(numero_activos,1), ...
            [],[], ...
            ones(1,numero_activos), ...
            1, ...
            zeros(numero_activos,1), ...
            ones(numero_activos,1));

        %% Estrategia PIR

        pesos_pir = 1./std(datos_ventana);
        pesos_pir = pesos_pir/sum(pesos_pir);

        %% Estrategia PIR Penalizada (STD)

        pesos_pir_std = pirpen(datos_ventana,'std');

        %% Estrategia PIR Penalizada (MAD)

        pesos_pir_mad = pirpen(datos_ventana,'mad');

        %% Matriz de pesos de todas las estrategias

        matriz_pesos = [ ...
            pesos_media_varianza ...
            pesos_minima_varianza ...
            pesos_pir' ...
            pesos_pir_std' ...
            pesos_pir_mad' ...
            pesos_naive'];

        %% Retornos fuera de la muestra

        retornos_estrategias(k,:) = ...
            datos(k+tamano_ventana,:) * matriz_pesos;

    end

    %% Índice de Sharpe promedio

    for estrategia = 1:6

        tabla_sharpe(v,estrategia) = ...
            mean(retornos_estrategias(:,estrategia)) / ...
            std(retornos_estrategias(:,estrategia));

    end

end

%% Construcción de la tabla de resultados

T_sharpe = array2table( ...
    [ventanas' tabla_sharpe], ...
    'VariableNames', ...
    ['Ventana', nombres_estrategias]);

disp(' ')
disp('Índice de Sharpe promedio por tamaño de ventana')
disp(T_sharpe)

tiempo_ejecucion = toc;

%% Exportación de la tabla a LaTeX

fid = fopen('T_sharpe.tex','w');

[numero_filas, numero_columnas] = size(T_sharpe);

fprintf(fid,'\\begin{table}[H]\n');
fprintf(fid,'\\centering\n');
fprintf(fid,'\\caption{Índice de Sharpe promedio por tamaño de ventana y estrategia.}\n');
fprintf(fid,'\\renewcommand{\\arraystretch}{1.2}\n');

fprintf(fid,'\\begin{tabular}{r');
for j = 2:numero_columnas
    fprintf(fid,'r');
end
fprintf(fid,'}\n');

fprintf(fid,'\\toprule\n');

variables = T_sharpe.Properties.VariableNames;

fprintf(fid,'%s',variables{1});

for j = 2:numero_columnas
    fprintf(fid,' & %s',variables{j});
end

fprintf(fid,' \\\\\n');
fprintf(fid,'\\midrule\n');

for i = 1:numero_filas

    fprintf(fid,'%d',T_sharpe.Ventana(i));

    for j = 2:numero_columnas
        fprintf(fid,' & %.3f',T_sharpe{i,j});
    end

    fprintf(fid,' \\\\\n');

end

fprintf(fid,'\\bottomrule\n');
fprintf(fid,'\\end{tabular}\n');
fprintf(fid,'\\end{table}\n');

fclose(fid);
