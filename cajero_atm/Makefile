# Makefile para simular el cajero automático
# Uso:
#   make        -> compila y simula
#   make view   -> abre GTKWave con resultados
#   make clean  -> limpia archivos generados

# Archivos fuente
SRC = cajero.v tester.v testbench.v

# Nombre del ejecutable
OUT = cajero_sim

# Archivo de ondas
WAVE = cajero.vcd

# Compilar y simular
all: $(SRC)
	iverilog -o $(OUT) $(SRC)
	vvp $(OUT)

# Abrir resultados en GTKWave
view: $(WAVE)
	gtkwave $(WAVE) &

# Limpiar
clean:
	rm -f $(OUT) $(WAVE)
