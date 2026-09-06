# Práctica I: Del Píxel a la Integral - Área bajo la Curva

## Información del Proyecto
* **Materia:** Lenguajes de Programación / Paradigmas de Programación
* **Institución:** Universidad EAFIT
* **Profesor:** Alexander Narváez Berrío
* **Entrega:** Repositorio GitHub + Sustentación Presencial

## Integrantes del Equipo
* Andrés Estrada Arroyave
* Salomé Palacio Lopez

---

## Resultados y Validación Cruzada
* **Archivo fuente:** `curva_binaria_P4.pbm` (Dimensiones: 567 x 319 píxeles)
* **Área obtenida en Prolog:** 108660 píxeles cuadrados
* **Área obtenida en Haskell:** 108660 píxeles cuadrados

> **Nota:** Ambas soluciones obtienen exactamente el mismo valor de área, confirmando la convergencia entre el paradigma lógico y el paradigma funcional sobre los mismos datos.

---

## Entornos de Desarrollo

### Prolog
* **Intérprete:** SWI-Prolog (v10.x o superior)
* **Plataforma:** Windows / macOS / Linux

### Haskell
* **Compilador/Intérprete:** GHC (Glasgow Haskell Compiler) 9.x, utilizando la biblioteca estándar y el paquete `bytestring` para la manipulación de archivos binarios.

---

## Instrucciones de Ejecución

### Ejecución en Prolog
1. Abrir la terminal o Símbolo del Sistema en el directorio `Prolog/` del repositorio.
2. Iniciar el programa con SWI-Prolog:
   ```bash
   swipl main.pl
3. Dentro de la consola interactiva de Prolog (`?-`), ejecutar la consulta principal:
   ```prolog
   ?- ejecutar.
   ```
4. El programa mostrará las dimensiones de la imagen, el área total calculada, la gráfica reescalada en consola y los 10 puntos de muestra `x_i -> f(x_i)`.

### Ejecución en Haskell
1. Abrir la terminal en el directorio donde se encuentran el archivo `main.hs` y la imagen `curva_binaria_P4.pbm`.
2. Compilar el programa fuente utilizando GHC mediante el comando:
   ```bash
   ghc main.hs
   ```
3. Ejecutar el archivo binario generado:
   * En entornos Linux o macOS: 
     ```bash
     ./main
     ```
   * En entornos Windows: 
     ```bash
     .\main.exe
     ```
*(Nota: Para una ejecución directa sin generar archivos binarios adicionales, también se puede utilizar el comando `runghc main.hs`).*

---

## Estrategia de Visualización en Consola

Dado que la imagen original (567 x 319 píxeles) supera el ancho estándar de una terminal de comandos, se implementó una estrategia de muestreo espacial (downsampling) y reescalado discreto:

1. **Muestreo Horizontal:** Se reduce el dominio de 567 columnas a un ancho cómodo de 80 caracteres en la consola.
2. **Mapeo Vertical:** Se escalan las alturas calculadas a 20 niveles discretos de texto.
3. **Renderizado Unicode:** Se utilizan caracteres de bloque sólido Unicode (`█`) para dibujar la silueta de abajo hacia arriba, preservando la forma continua de la curva original.

---

## Comparación de Paradigmas

### Paradigma Lógico (Prolog)
En Prolog, la solución se formula a través de relaciones lógicas y declaraciones de hechos en lugar de algoritmos imperativos:
* Se define el predicado `pixel_negro/4` para consultar bit a bit el contenido de la imagen.
* La altura de cada columna `f(x)` se determina mediante el predicado `contar_negros_columna/6` que evalúa los píxeles negros desde la base hasta el primer blanco.
* El vector de alturas `M` se construye declarativamente utilizando `findall/3`.
* El área total emerge como la suma de la lista de alturas mediante el predicado `sum_list/2`.

### Paradigma Funcional (Haskell)
La solución propuesta aplica el paradigma de la programación funcional al modelar el cálculo matemático del área como una serie de transformaciones declarativas e inmutables. En lugar de utilizar bucles con estados mutables para recorrer la imagen, el código define el dominio matemático como una lista de coordenadas (`[0 .. w - 1]`) y aplica la función de orden superior `map` para proyectar el cálculo de alturas de manera independiente sobre cada elemento. La función `f` actúa como una función matemática pura `f(x)` que evalúa los píxeles utilizando listas por comprensión y el procesamiento declarativo de colecciones (con funciones como `reverse` y `takeWhile`) para contar los pixeles sin alterar el estado del sistema.

Asimismo, la lectura del formato binario y el cálculo final evidencian el uso de la composición de funciones y la transformación de tipos. El encadenamiento u operador de aplicación (`$`) permite que el flujo de datos sea directo, como se observa al calcular la altura. La abstracción alcanza su punto máximo al calcular la suma de Riemann, que se reduce a una simple operación de plegado matemático mediante la función `sum` sobre la lista de alturas mapeadas (`sum m`), demostrando la expresividad, concisión y ausencia de efectos secundarios que caracterizan a Haskell.
