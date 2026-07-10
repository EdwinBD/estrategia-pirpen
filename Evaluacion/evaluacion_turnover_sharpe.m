%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script: evaluacion_turnover_sharpe.m
%
% Evalúa el desempeño de seis estrategias de selección de portafolios
% utilizando diferentes tamaños de ventana móvil.
%
% Para cada estrategia se calcula:
%   1. El turnover promedio.
%   2. El índice de Sharpe considerando costos de transacción.
%
% Los costos de transacción se incorporan mediante la función turnover(),
% utilizando un costo proporcional de 50 puntos básicos (c = 0.005).
%
% Finalmente, el script genera automáticamente las tablas en formato
% LaTeX utilizadas en la tesis.
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


datos = data5/100;

[numero_periodos, numero_activos] = size(datos);

%% Configuración del experimento

gamma = 1;
costo_transaccion = 0.005;

ventanas = 60:30:600;
numero_ventanas = length(ventanas);

nombres_estrategias = { ...
    'Media-Varianza',...
    'Minima-Varianza',...
    'PIR',...
    'PIR-STD',...
    'PIR-MAD',...
    'Naive'};

numero_estrategias = length(nombres_estrategias);

tabla_turnover = zeros(numero_ventanas,numero_estrategias);
tabla_sharpe = zeros(numero_ventanas,numero_estrategias);

%% Evaluación para cada tamaño de ventana

for v = 1:numero_ventanas

    tamano_ventana = ventanas(v);

    % Portafolio equiponderado
    pesos_naive = ones(1,numero_activos)/numero_activos;

    % Retornos fuera de la muestra
    retornos_estrategias = zeros(numero_periodos-tamano_ventana,numero_estrategias);

    % Almacenamiento de pesos
    pesos_media_varianza = zeros(numero_periodos-tamano_ventana,numero_activos);
    pesos_minima_varianza = zeros(numero_periodos-tamano_ventana,numero_activos);
    pesos_pir = zeros(numero_periodos-tamano_ventana,numero_activos);
    pesos_pir_std = zeros(numero_periodos-tamano_ventana,numero_activos);
    pesos_pir_mad = zeros(numero_periodos-tamano_ventana,numero_activos);

    pesos_naive_historicos = repmat( ...
        pesos_naive,...
        numero_periodos-tamano_ventana,...
        1);

    for k = 1:(numero_periodos-tamano_ventana)

        datos_ventana = datos(k:k+tamano_ventana-1,:);

        %% Estrategia Media-Varianza

        media = mean(datos_ventana);

        pesos_mv = quadprog( ...
            cov(datos_ventana),...
            -media/gamma,...
            [],[],...
            ones(1,numero_activos),...
            1,...
            zeros(numero_activos,1),...
            ones(numero_activos,1));

        %% Estrategia Mínima Varianza

        pesos_minvar = quadprog( ...
            cov(datos_ventana),...
            zeros(numero_activos,1),...
            [],[],...
            ones(1,numero_activos),...
            1,...
            zeros(numero_activos,1),...
            ones(numero_activos,1));

        %% Estrategia PIR

        pesos_pir_actual = 1./std(datos_ventana);
        pesos_pir_actual = pesos_pir_actual/sum(pesos_pir_actual);

        %% Estrategia PIR Penalizada (STD)

        pesos_pir_std_actual = pirpen(datos_ventana,'std');

        %% Estrategia PIR Penalizada (MAD)

        pesos_pir_mad_actual = pirpen(datos_ventana,'mad');

        %% Almacenar los pesos obtenidos

        pesos_media_varianza(k,:) = pesos_mv';
        pesos_minima_varianza(k,:) = pesos_minvar';
        pesos_pir(k,:) = pesos_pir_actual;
        pesos_pir_std(k,:) = pesos_pir_std_actual;
        pesos_pir_mad(k,:) = pesos_pir_mad_actual;

        %% Matriz de pesos

        matriz_pesos = [ ...
            pesos_mv ...
            pesos_minvar ...
            pesos_pir_actual' ...
            pesos_pir_std_actual' ...
            pesos_pir_mad_actual' ...
            pesos_naive'];

        %% Retornos fuera de la muestra

        retornos_estrategias(k,:) = ...
            datos(k+tamano_ventana,:) * matriz_pesos;

    end

    %% Evaluación del turnover y Sharpe con costos

    estrategias_pesos = { ...
        pesos_media_varianza,...
        pesos_minima_varianza,...
        pesos_pir,...
        pesos_pir_std,...
        pesos_pir_mad,...
        pesos_naive_historicos};

    for estrategia = 1:numero_estrategias

        [turnover_medio, retornos_netos] = turnover( ...
            estrategias_pesos{estrategia},...
            retornos_estrategias(:,estrategia),...
            datos,...
            tamano_ventana,...
            costo_transaccion);

        tabla_turnover(v,estrategia) = turnover_medio;

        tabla_sharpe(v,estrategia) = ...
            mean(retornos_netos)/std(retornos_netos);

    end

end

%% Construcción de las tablas de resultados

T_sharpe = array2table( ...
    [ventanas' tabla_sharpe],...
    'VariableNames',...
    ['Ventana', nombres_estrategias]);

T_turnover = array2table( ...
    [ventanas' tabla_turnover],...
    'VariableNames',...
    ['Ventana', nombres_estrategias]);

disp(' ')
disp('Índice de Sharpe considerando costos de transacción')
disp(T_sharpe)

disp(' ')
disp('Turnover promedio')
disp(T_turnover)

tiempo_ejecucion = toc;

%% Exportación de la tabla de Sharpe a LaTeX

fid = fopen('T_sharpe.tex','w');

[numero_filas, numero_columnas] = size(T_sharpe);

fprintf(fid,'\\begin{table}[H]\n');
fprintf(fid,'\\centering\n');
fprintf(fid,'\\caption{Índice de Sharpe promedio considerando costos de transacción.}\n');
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

%% Exportación de la tabla de Turnover a LaTeX

fid = fopen('T_turnover.tex','w');

[numero_filas, numero_columnas] = size(T_turnover);

fprintf(fid,'\\begin{table}[H]\n');
fprintf(fid,'\\centering\n');
fprintf(fid,'\\caption{Turnover promedio por tamaño de ventana y estrategia.}\n');
fprintf(fid,'\\renewcommand{\\arraystretch}{1.2}\n');

fprintf(fid,'\\begin{tabular}{r');
for j = 2:numero_columnas
    fprintf(fid,'r');
end
fprintf(fid,'}\n');

fprintf(fid,'\\toprule\n');

variables = T_turnover.Properties.VariableNames;

fprintf(fid,'%s',variables{1});
for j = 2:numero_columnas
    fprintf(fid,' & %s',variables{j});
end

fprintf(fid,' \\\\\n');
fprintf(fid,'\\midrule\n');

for i = 1:numero_filas

    fprintf(fid,'%d',T_turnover.Ventana(i));

    for j = 2:numero_columnas
        fprintf(fid,' & %.3f',T_turnover{i,j});
    end

    fprintf(fid,' \\\\\n');

end

fprintf(fid,'\\bottomrule\n');
fprintf(fid,'\\end{tabular}\n');
fprintf(fid,'\\end{table}\n');

fclose(fid);
