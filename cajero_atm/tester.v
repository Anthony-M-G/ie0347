`timescale 1ns/1ps
// Archivo: tester.v
// Autor: Antony Medina
// Descripción: Módulo generador de estímulos para probar el cajero automático (cajero_atm)
// Aquí se simulan las acciones de un usuario y se automatizan varias pruebas.
module tester (
    output reg        clk,
    output reg        reset,
    output reg        tarjeta_recibida,
    output reg [3:0]  digito,
    output reg        digito_stb,
    output reg [15:0] pin_correcto,
    output reg        tipo_trans,      // 0=depósito, 1=retiro
    output reg [31:0] monto,
    output reg        monto_stb,
    output reg [63:0] balance_inicial,

    input  wire [63:0] balance_actualizado,
    input  wire        balance_stb,
    input  wire        entregar_dinero,
    input  wire        fondos_insuficientes,
    input  wire        pin_incorrecto,
    input  wire        advertencia,
    input  wire        bloqueo,
    input  wire [3:0]  estado_actual,
    input  wire [15:0] pin_ingresado_out
);

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // periodo de 10ns
    end



    // Secuencia de pruebas
    initial begin
        // Señales iniciales
        reset = 1; tarjeta_recibida = 0; digito = 0; digito_stb = 0;
        pin_correcto = 16'h1234; tipo_trans = 0; monto = 0; monto_stb = 0;
        balance_inicial = 500; // saldo inicial
        #20 reset = 0;

        // ========== PRUEBA 1: Depósito básico ==========
        insertar_tarjeta();
        ingresar_pin(16'h1234); // pin correcto
        ingresar_monto(100, 0); // depósito de 100
        #50;

        // ========== PRUEBA 2: Retiro básico ==========
        insertar_tarjeta();
        ingresar_pin(16'h1234);
        ingresar_monto(50, 1); // retiro de 50
        #50;

        // ========== PRUEBA 3: Fondos insuficientes ==========
        insertar_tarjeta();
        ingresar_pin(16'h1234);
        ingresar_monto(1000, 1); // retiro mayor al saldo
        #50;

        // ========== PRUEBA 4: PIN incorrecto ==========
        insertar_tarjeta();
        ingresar_pin(16'h9999); // pin incorrecto
        #50;

        // ========== PRUEBA 5: Secuencia combinada ==========
        insertar_tarjeta();
        ingresar_pin(16'h1234);
        ingresar_monto(200, 0); // depósito de 200
        #30;
        insertar_tarjeta();
        ingresar_pin(16'h1234);
        ingresar_monto(800, 1); // retiro de 800 (puede quedar insuficiente)
        #100;

        $finish;
    end

    // -------------------
    // TAREAS AUXILIARES
    // -------------------

    task insertar_tarjeta;
    begin
        tarjeta_recibida = 1; #10;
        tarjeta_recibida = 0; #10;
    end
    endtask

    task ingresar_pin(input [15:0] pin);
    integer i;
    reg [3:0] dig;
    begin
        for (i = 3; i >= 0; i = i-1) begin
            dig = pin[4*i +: 4];
            digito = dig;
            digito_stb = 1; #10; digito_stb = 0; #10;
        end
    end
    endtask

    task ingresar_monto(input [31:0] val, input tipo);
    begin
        tipo_trans = tipo;
        monto = val;
        monto_stb = 1; #10; monto_stb = 0;
    end
    endtask

endmodule
