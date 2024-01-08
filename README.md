# data_protocol_LDPF
Repositorio de funciones para el setup del LDPF

Se tienen los códigos separados por:
1. Old TSP Codes: Códigos antiguos en desuso actual, pero con utilidad para la generación de nuevo código
2. Current TSP Codes: Códigos usados actualmente en el setup

## Current TSP Codes
El archivo más importante de todos es el de correspondiente a "functions.tsp", aquí se tienen las funciones base para cualquier experimento que se desarrolle con el setup.

Las funciones que se incluyen con:
- cc_discharge: Descarga a corriente constante
- cccv_discharge: Descarga a corriente constante-voltaje constante
- charge: Carga a corriente constante-voltaje constante
- resting: Descanso de la celda (no se da o quita energía a la celda)
- vocbor_measure : Medición de voltaje de la celda
- cc_capacity_load : Carga o descarga de la celda por cierta cantidad de energía (mAh)
- custom_profile: Carga o descarga de la celda en base a un perfil de corriente dado
- keithley_control: Cambio en pines I/O del setup para conectar el SourceMeter (Keithley) a la celda
- EIS_control: Cambio en pines I/O del setup para conectar el espectroscopio (Autolab) a la celda

## Descripción de los códigos

### cc_discharge
cc_discharge(voltlimit, discurrent, SOC_0, cell_captotal, test_number)

- voltlimit: Límite de voltaje de descarga de la celda
- discurrent: Corriente de descarga
- SOC_0: Estado de carga inicial de la celda
- cell_captotal: Capacidad total inicial de la celda
- test_number: Número identificador del test (asegurarse que es igual cada vez que se usa una misma función y distinto cada vez que se usa una nueva)

### cccv_discharge

cccv_discharge(voltlimit, discurrent, curr_limit, SOC_0, cell_captotal, test_number)

- voltlimit: Límite de voltaje de descarga de la celda
- discurrent: Corriente de descarga (etapa corriente constante)
- curr_limit: Límite de corriente (etapa voltaje constante)
- SOC_0: Estado de carga inicial de la celda
- cell_captotal: Capacidad total inicial de la celda
- test_number: Número identificador del test (asegurarse que es igual cada vez que se usa una misma función y distinto cada vez que se usa una nueva)

### charge

charge(voltlimit, charcurrent, curr_limit, SOC_0, cell_captotal, test_number)

- voltlimit: Límite de voltaje de carga de la celda
- charcurrent: Corriente de carga (etapa corriente constante)
- curr_limit: Límite de corriente (etapa voltaje constante)
- SOC_0: Estado de carga inicial de la celda
- cell_captotal: Capacidad total inicial de la celda
- test_number: Número identificador del test (asegurarse que es igual cada vez que se usa una misma función y distinto cada vez que se usa una nueva)

### resting

resting(voltlimit, contador_rest, SOC_0, cell_captotal, test_number)

- voltlimit: Límite de voltaje de descarga de la celda
- contador_rest: Iteraciones de descanso de la celda (depende del delay de la función, es de approx 1 seg)
- SOC_0: Estado de carga inicial de la celda
- cell_captotal: Capacidad total inicial de la celda
- test_number: Número identificador del test (asegurarse que es igual cada vez que se usa una misma función y distinto cada vez que se usa una nueva)

### vocbor_measure

vocbor_measure(voltlimit, SOC, test_number)

- voltlimit: Límite de voltaje de descarga de la celda
- SOC: Estado de carga actual de la celda
- test_number: Número identificador del test (asegurarse que es igual cada vez que se usa una misma función y distinto cada vez que se usa una nueva)

### cc_capacity_load

cc_capacity_load(voltlimit, current, load_cap, SOC_0, cell_captotal, currlimit, test_number)

- voltlimit: Límite de voltaje de descarga de la celda
- current: Corriente de carga o descarga de la celda (Positivo = Carga, Negativo = Descarga)
- load_cap: Capacidad a cargar o descargar (en mAh)
- SOC_0: Estado de carga inicial de la celda
- cell_captotal: Capacidad total inicial de la celda
- currlimit: Límite de corriente (para carga o descarga, evita sobrecarga o sobredescarga)
- test_number: Número identificador del test (asegurarse que es igual cada vez que se usa una misma función y distinto cada vez que se usa una nueva)

### custom_profile

custom_profile(SOC_0,cell_captotal,upper_voltlimit,lower_voltlimit,test_number)

- SOC_0: Estado de carga inicial de la celda
- cell_captotal: Capacidad total inicial de la celda
- upper_voltlimit: Límite de voltaje de carga de la celda
- lower_voltlimit: Límite de voltaje de descarga de la celda
- test_number: Número identificador del test (asegurarse que es igual cada vez que se usa una misma función y distinto cada vez que se usa una nueva)

*Esta función necesita que en el USB insertado en el Keithley haya un archivo en formato csv de nombre "csv_test.csv" con 1 columna solo de valores numéricos, correspondientes a los valores de corriente que tomará el keithley en cada iteración (la iteración está sujeta al delay dado, por defecto es de 1 segundo approx.)*

### keithley_control

keithley_control()

### EIS_control

EIS_control(SOC_0,cell_captotal,test_number) 

- SOC_0: Estado de carga inicial de la celda
- cell_captotal: Capacidad total inicial de la celda
- test_number: Número identificador del test (asegurarse que es igual cada vez que se usa una misma función y distinto cada vez que se usa una nueva)

## Experimentos
### ciclado_EIS [Actualizar función]
Experimento que busca realizar un diagnóstico del estado actual de la celda. Los resultados relevantes obtenidos son:
- Curva de Voltaje circuito abierto
- EIS (Espectroscopía de Impedancia Electroquímica) para distintos SOC de la celda
- Obtención de capacidad total actual de la celda (en mAh)

El proceso que se desarrolla es:

Etapa inicial
1. Descarga completa de la celda
2. Descanso por x segundos

Ciclo Macro
1. Carga completa y guardado de capacidad máxima (Uso de capacidad máxima para generar descargas parciales en un porcentaje de dicho valor a la celda)
2. EIS para SOC 100%

Ciclo Micro
1. Descarga parcial por x porcentaje de la capacidad máxima obtenida
2. Medición de voltaje en bornes
2. Descanso de 6 minutos
3. EIS
4. Medición de voltaje circuito abierto


*Fin de ciclos micro: Cuando el SOC de la celda llegue a 0%*
*Fin de ciclos macro: Cuando el número de cargas dado se complete*


#### Sintaxis de la función
cicladoEIS(ciclos_macro, lower_voltlimit, upper_voltlimit, cell_captotal, discurrent, charcurrent, currlimit, porcen_desc)

- ciclos_macro: Cantidad de cargas completas a realizar para la caracterización (Recomendación: Al menos 2 ciclos macro)
- lower_voltlimit: Límite de voltaje de descarga de la celda
- upper_voltlimit: Límite de voltaje de carga de la celda
- cell_captotal: Capacidad total inicial de la celda
- discurrent: Corriente de descarga de la celda
- charcurrent: Corriente de carga de la celda
- porcen_desc: Porcentaje de SOC descargado para ciclos micro
