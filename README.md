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