function resultado = mad(datos)
%--------------------------------------------------------------------------
% Función: mad
%
% Calcula la Desviación Absoluta Mediana (MAD) para cada activo de una
% matriz de retornos.
%
% La MAD se define como la mediana de las desviaciones absolutas respecto
% a la mediana de cada serie y constituye una medida robusta de dispersión.
%
% Entrada:
%   datos       : Matriz de retornos (M observaciones × N activos).
%
% Salida:
%   resultado   : Vector con la MAD de cada activo.
%--------------------------------------------------------------------------

%% Cálculo de la mediana de cada activo

mediana_datos = median(datos);

%% Cálculo de las desviaciones absolutas

desviaciones_absolutas = abs(datos - mediana_datos);

%% Cálculo de la Desviación Absoluta Mediana (MAD)

resultado = median(desviaciones_absolutas);

end