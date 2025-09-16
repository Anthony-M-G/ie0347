// Archivo: testbench.v
// Autor: Antony Medina
// Descripción: Banco de pruebas principal para el cajero automático.
// Instancia el DUT (Device Under Test) y el tester, y conecta todas las señales.
// Incluye comentarios para entender el propósito de cada bloque.
`timescale 1ns/1ps

module testbench;
    // =========================
    // Declaración de señales
    // =========================
    // Estas wires conectan el tester y el cajero_atm
    wire        clk, reset, tarjeta_recibida, digito_stb, tipo_trans, monto_stb;
    wire [3:0]  digito, estado_actual;
    wire [15:0] pin_correcto, pin_ingresado_out;
    wire [31:0] monto;
    wire [63:0] balance_inicial, balance_actualizado;
    wire        balance_stb, entregar_dinero, fondos_insuficientes;
    wire        pin_incorrecto, advertencia, bloqueo;

    // =========================
    // Instancia del DUT (cajero_atm)
    // =========================
    cajero_atm dut (
        .clk(clk), .reset(reset),
        .tarjeta_recibida(tarjeta_recibida),
        .digito(digito), .digito_stb(digito_stb),
        .pin_correcto(pin_correcto),
        .tipo_trans(tipo_trans), .monto(monto), .monto_stb(monto_stb),
        .balance_inicial(balance_inicial),
        .balance_actualizado(balance_actualizado),
        .balance_stb(balance_stb),
        .entregar_dinero(entregar_dinero),
        .fondos_insuficientes(fondos_insuficientes),
        .pin_incorrecto(pin_incorrecto),
        .advertencia(advertencia),
        .bloqueo(bloqueo),
        .estado_actual(estado_actual),
        .pin_ingresado_out(pin_ingresado_out)
    );

    // =========================
    // Instancia del tester
    // =========================
    // El tester genera todos los estímulos y verifica los casos de prueba
    tester test (
        .clk(clk), .reset(reset),
        .tarjeta_recibida(tarjeta_recibida),
        .digito(digito), .digito_stb(digito_stb),
        .pin_correcto(pin_correcto),
        .tipo_trans(tipo_trans), .monto(monto), .monto_stb(monto_stb),
        .balance_inicial(balance_inicial),
        .balance_actualizado(balance_actualizado),
        .balance_stb(balance_stb),
        .entregar_dinero(entregar_dinero),
        .fondos_insuficientes(fondos_insuficientes),
        .pin_incorrecto(pin_incorrecto),
        .advertencia(advertencia),
        .bloqueo(bloqueo),
        .estado_actual(estado_actual),
        .pin_ingresado_out(pin_ingresado_out)
    );

    // =========================
    // Monitor de señales
    // =========================
    // Este bloque imprime en consola el estado de las señales más importantes
    // y genera el archivo de ondas para GTKWave
    initial begin
        $dumpfile("cajero.vcd"); // Archivo de salida para GTKWave
        $dumpvars(0, testbench);
        $display("\n==== INICIO DE SIMULACIÓN DEL CAJERO ====");
        $monitor("t=%0t | BAL=%0d | STB=%b | ENTREGAR=%b | INSUF=%b | PIN_INC=%b | ADV=%b | BLOQ=%b | ESTADO=%0d | PIN_IN=%h",
                  $time, balance_actualizado, balance_stb, entregar_dinero,
                  fondos_insuficientes, pin_incorrecto, advertencia, bloqueo, estado_actual, pin_ingresado_out);
    end

endmodule
