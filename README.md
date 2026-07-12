# Estrategia de Ponderación Inversa al Riesgo Penalizada

Este repositorio contiene la implementación en **MATLAB** de las estrategias de **Ponderación Inversa al Riesgo Penalizada** propuesta en el trabajo de grado denominado **Calibración del parámetro de penalización de la volatilidad en selección de portafolios de ponderación inversa alriesgo**  presentado como requisito parcial para optar al título de
Magister en Estadística Aplicada  de la Universidad de Nariño.

La metodología propone una variante de la estrategia clásica de Ponderación Inversa al Riesgo (PIR), incorporando un parámetro de penalización que se calibra mediante la maximización del índice de Sharpe y un control sobre la concentración del portafolio utilizando el coeficiente de Gini.

Además de la implementación del algoritmo, el repositorio incluye los scripts necesarios para reproducir los experimentos computacionales y las tablas presentadas en el trabajo.

---

# Estructura del repositorio

```
.
├── Funciones
│   ├── pirpen.m
│   ├── turnover.m
│   ├── gini_index.m
│   └── calcular_mad.m
│   
├── Evaluacion
|   ├──evaluacion_sharpe_sin_costos.m
|   └── evaluacion_turnover_sharpe.m
|
├── Datos
|   ├── data5.mat
|   ├── data10.mat
|   ├── data12.mat
|   ├── data17.mat
|   ├── data30.mat
|   ├── data31.mat
|   ├── data40.mat
|   ├── data250.mat
|   └── data500.mat        │
|
├──README.md
```

---

# Requisitos

El código fue desarrollado en **MATLAB**.

Se requiere:

- MATLAB R2023b o superior.
- Optimization Toolbox.

Optimization Toolbox es necesaria porque la implementación de las estrategias **Media-Varianza** y **Mínima Varianza** utiliza la función

```matlab
quadprog
```

para resolver los problemas de optimización cuadrática.

No se requieren paquetes adicionales para ejecutar las funciones necesarias.

---

# Funciones implementadas

| Función | Descripción |
|----------|-------------|
| **pirpen.m** | Implementa la estrategia de Ponderación Inversa al Riesgo Penalizada (PIR-PEN). |
| **turnover.m** | Calcula el turnover promedio y los retornos netos considerando costos de transacción. |
| **gini_index.m** | Calcula el coeficiente de Gini asociado a un vector de pesos. |
| **calcular_mad.m** | Calcula la desviación absoluta mediana (MAD). |

---

# Scripts de evaluación

El repositorio incluye dos scripts principales para reproducir los resultados de la tesis.

| Script | Descripción |
|---------|-------------|
| **evaluacion_sharpe_sin_costos.m** | Calcula el índice de Sharpe para todas las estrategias utilizando distintos tamaños de ventana sin considerar costos de transacción. |
| **evaluacion_turnover_sharpe.m** | Calcula el turnover promedio y el índice de Sharpe considerando costos de transacción. |

Ambos scripts generan automáticamente las tablas en formato LaTeX utilizadas en el documento de la tesis.

---

# Datos

La carpeta **Datos** contiene los conjuntos de datos empleados en los experimentos computacionales.

Los archivos deben permanecer dentro de esta carpeta para ejecutar correctamente los scripts de evaluación.

---
# Ejecución

Para ejecutar los scripts basta con abrir MATLAB y ejecutar cualquiera de los archivos contenidos en la carpeta `Evaluacion`.

Los scripts configuran automáticamente las rutas necesarias para acceder a las funciones y a los conjuntos de datos del repositorio, por lo que no es necesario modificar las rutas manualmente.

El tiempo de ejecución de los scripts varía segun el conjunto de datos empleado; además, se debe considerar que se están ejecutando todas las estrategias analizadas y para una lista considerable de diferentes tamaños de ventana.

---

# Reproducibilidad

El objetivo de este repositorio es facilitar la reproducción de los resultados presentados en el trabajo de grado.

Se incluyen:

- El código fuente de los algoritmos implementados.
- Los conjuntos de datos utilizados en los experimentos.
- Los scripts de evaluación.
- La generación automática de las tablas en formato LaTeX.

---

# Autor

**Edwin Andrés Bolaños de la Cruz**

Maestría en Estadística Aplicada

Universidad de Nariño
