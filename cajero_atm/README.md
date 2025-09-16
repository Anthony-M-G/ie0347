# Cajero Automático en Verilog

Este proyecto implementa un cajero automático (ATM) utilizando Verilog. El sistema simula operaciones básicas de un cajero, permitiendo la interacción con un usuario a través de un testbench.

## Estructura del Proyecto

- `cajero.v`: Módulo principal del cajero automático.
- `tester.v`: Módulo de pruebas que simula escenarios de uso.
- `testbench.v`: Testbench que integra el cajero y el tester.
- `Makefile`: Facilita la simulación y compilación usando Icarus Verilog y la visualización en GTKWave.

## Funcionalidades Principales

- Simulación de ingreso de usuario y validación de PIN.
- Consulta de saldo.
- Depósito y retiro de efectivo.
- Manejo de errores y bloqueos por intentos fallidos.

## Instrucciones de Uso

### Requisitos

- [Icarus Verilog](http://iverilog.icarus.com/) para simulación.
- [GTKWave](http://gtkwave.sourceforge.net/) para visualizar las señales.
- Make (opcional, para usar el Makefile).

### Simulación rápida

Ejecuta en la terminal dentro de la carpeta `cajero_atm`:

```bash
make
```
Esto compilará y simulará el testbench, generando el archivo de ondas `cajero.vcd` y mostrando los resultados de las pruebas en consola.

### Visualización de resultados en GTKWave

Para abrir el archivo de ondas generado y analizar las señales:

```bash
make view
```
Esto abrirá GTKWave con el archivo `cajero.vcd`.

### Simulación manual

Si prefieres compilar manualmente:

```bash
iverilog -o cajero_sim cajero.v tester.v testbench.v
vvp cajero_sim
gtkwave cajero.vcd &
```

### Limpieza de archivos generados

Para eliminar archivos de simulación y ondas:

```bash
make clean
```

## Pruebas

El archivo `testbench.v` incluye diferentes escenarios de prueba, como:
- Ingreso correcto e incorrecto de PIN.
- Operaciones de depósito y retiro.
- Manejo de saldo insuficiente.
- Bloqueo tras múltiples intentos fallidos.

Puedes modificar `tester.v` para agregar o ajustar casos de prueba según tus necesidades.

## Autor

Anthony M. G.

## Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo `LICENSE` para más detalles.
