// Profesor: Ing. Enrique Cohen
// Curso: Sistemas Digitales II
// ALumno: Antony Medina 
// Carné: C14600
// =========================================================
//  controlador para cajero automático
// =========================================================
`timescale 1ns/1ps

module cajero_atm #(
    parameter INTENTOS_MAX = 3
)(
    input  wire        clk,
    input  wire        reset,

    // interfaz de usuario
    input  wire        tarjeta_recibida,
    input  wire [3:0]  digito,
    input  wire        digito_stb,
    input  wire [15:0] pin_correcto,
    input  wire        tipo_trans,        // 0 = depósito, 1 = retiro
    input  wire [31:0] monto,
    input  wire        monto_stb,

    // saldo que llega al insertar la tarjeta
    input  wire [63:0] balance_inicial,

    // salidas
    output reg  [63:0] balance_actualizado,
    output reg         balance_stb,
    output reg         entregar_dinero,
    output reg         fondos_insuficientes,
    output reg         pin_incorrecto,
    output reg         advertencia,
    output reg         bloqueo,

    // salidas de depuración
    output wire [3:0]  estado_actual,
    output wire [15:0] pin_ingresado_out
);

    // asignaciones de salida
    assign estado_actual     = estado;
    assign pin_ingresado_out = pin_ingresado;

    // definición de estados
    localparam ESP_TARJ  = 0,
               LEER_PIN  = 1,
               VERIF_PIN = 2,
               PIN_OK    = 3,
               LEE_MONTO = 4,
               EVAL_OP   = 5,
               FONDOS_N  = 6,
               ACT_BAL   = 7,
               BLOQ_EST  = 8;

    reg [3:0] estado, sig_estado;

    // registros auxiliares
    reg [15:0] pin_ingresado;
    reg [2:0]  dig_cnt;
    reg [1:0]  intentos;

    reg        digito_stb_d;
    reg [31:0] monto_reg;
    reg        monto_ready;
    reg [63:0] balance_actual;
    reg        tarjeta_r;

// ========================================
//  SECUENCIAL
// ========================================
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Reinicio del sistema: se inicializan todas las variables y registros
        estado           <= ESP_TARJ;       // Estado inicial: esperar tarjeta
        dig_cnt          <= 0;              // Contador de dígitos del PIN
        pin_ingresado    <= 0;              // Registro para almacenar el PIN ingresado
        intentos         <= 0;              // Contador de intentos fallidos
        digito_stb_d     <= 0;              // Registro para detectar flancos de digito_stb
        tarjeta_r        <= 0;              // Registro para detectar inserción de tarjeta
        monto_reg        <= 0;              // Registro para almacenar el monto ingresado
        monto_ready      <= 0;              // Señal que indica que el monto está listo
        balance_actual   <= 0;              // Registro para almacenar el balance actual
    end
    else begin
        // Actualización de estado y registros en cada ciclo de reloj
        estado       <= sig_estado;         
        digito_stb_d <= digito_stb;         
        tarjeta_r    <= tarjeta_recibida;   

        // Detectar inserción de una nueva tarjeta
        if (!tarjeta_r && tarjeta_recibida) begin
            balance_actual <= balance_inicial; // reiniciar balance al inicial
            pin_ingresado  <= 0;               // reinicia pin ingresado
            dig_cnt        <= 0;               // reiniciar contador de dígtos
        end
        // Leer dígitos del PIN cuando el estado es LEER_PIN
        if (estado == LEER_PIN && digito_stb && !digito_stb_d) begin
            case (dig_cnt)
                0: pin_ingresado[15:12] <= digito; // primer dígito
                1: pin_ingresado[11:8]  <= digito; // segundo dígito
                2: pin_ingresado[7:4]   <= digito; // tercer dígito
                3: pin_ingresado[3:0]   <= digito; // cuarto dígito
            endcase
            dig_cnt <= dig_cnt + 1; // incrementr contador de dígitos
        end

        // Registrar el monto ingresado
        if (monto_stb) begin
            monto_reg   <= monto;   // Almacenar el monto ingresado
            monto_ready <= 1;       // Indicar que monto esta listo
        end

        // Actualizar balance después de una transacción
        if (estado == ACT_BAL && sig_estado == ESP_TARJ)
            balance_actual <= balance_actualizado;

        // Manejar intentos fallidos de ingreso del PIN
        if (estado == VERIF_PIN && sig_estado == LEER_PIN)
            intentos <= intentos + 1; // Incrementar intentos fallidos
        else if (estado == PIN_OK)
            intentos <= 0; // reiniciar intentos al validar el PIN

        // Limpiar la señal de monto listo después de actualizar el balance
        if (estado == ACT_BAL)
            monto_ready <= 0;
    end
end

// =====================================================
//  LÓGICA COMBINACIONAL
// =====================================================
always @(*) begin
    // Inicialización de señales combinacionales
    sig_estado            = estado;          // Por defecto el sgte estado es el actual
    balance_stb           = 0;               // Señal de balance establecida en 0
    entregar_dinero       = 0;               // Señal para entregar dinero
    fondos_insuficientes  = 0;               // Señal de fondos insuficientes
    pin_incorrecto        = 0;               // Señal de pin incorrecto
    advertencia           = 0;               // Señal de advertencia
    bloqueo               = 0;               // Señal de bloqueo
    balance_actualizado   = balance_actual;  // ELl balance actualizado es el actual

    // Máquina de estados
    case (estado)
        ESP_TARJ: begin
            // Esperar tarjeta
            if (tarjeta_recibida)
                sig_estado = LEER_PIN; // Cambiar al estado de lectura de pin
        end

        LEER_PIN: begin
            // Leer PIN
            if (dig_cnt == 4)
                sig_estado = VERIF_PIN; // Cambiar al estado de verificación de pin
        end

        VERIF_PIN: begin
            // Verificar pin ingresado
            if (pin_ingresado == pin_correcto) begin
                sig_estado = PIN_OK; // pin correcto
            end else begin
                pin_incorrecto = 1; // Señal de PIN incorrecto
                if (intentos == INTENTOS_MAX-1)
                    sig_estado = BLOQ_EST; // Bloquear si se alcanzan los intentos maximos
                else begin
                    advertencia = (intentos == INTENTOS_MAX-2); // Advertencia antes de bloquear
                    sig_estado  = LEER_PIN; // Reintentar ingreso de PIN
                end
            end
        end

        PIN_OK: begin
            // pin validado correctamente
            sig_estado = LEE_MONTO; // Cambiar al estado de lectura de monto
        end

        LEE_MONTO: begin
            // Leer monto de la transacción
            if (monto_ready)
                sig_estado = EVAL_OP; // Cambia al estado de evaluación de operación
        end

        EVAL_OP: begin
            // Evaluar operación
            if (!tipo_trans)
                sig_estado = ACT_BAL; // Depósito
            else if (balance_actual >= monto_reg)
                sig_estado = ACT_BAL; // Retiro válido
            else
                sig_estado = FONDOS_N; // Fondos insuficientes
        end

        FONDOS_N: begin
            // Fondos insuficientes
            fondos_insuficientes = 1; // Señal de fondos insuficientes
            sig_estado           = ESP_TARJ; // Regreso al estado inicial
        end

        ACT_BAL: begin
            // Actualizar balance
            if (tipo_trans) begin
                balance_actualizado = balance_actual - monto_reg; // Retiro
                entregar_dinero     = 1; // Señal para entregar dinero
            end else begin
                balance_actualizado = balance_actual + monto_reg; // Depósito
            end
            balance_stb = 1; // Señal de balance actualizado
            sig_estado  = ESP_TARJ; // Regresar al estado inicial
        end

        BLOQ_EST: begin
            // Bloqueo del sistema
            bloqueo = 1; // Señal de bloqueo
        end
    endcase
end
endmodule