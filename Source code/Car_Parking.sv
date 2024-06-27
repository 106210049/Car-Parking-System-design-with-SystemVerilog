`timescale 1ns / 1ps

module parking_system(
    input logic clk, reset_n,
    input logic sensor_entrance, sensor_exit,
    input logic [1:0] password_1, password_2,
    output logic GREEN_LED, RED_LED,
    output logic [6:0] HEX_1, HEX_2
);

    logic [2:0] counter_delay;
    localparam STATE_WIDTH = 3;
    
    typedef enum logic [STATE_WIDTH-1:0] {
        IDLE,
        WAIT_PASSWORD_IN,
        RIGHT_PASSWORD_IN,
        WRONG_PASSWORD_IN,
        STOP
    } SYSTEM_STATE;
    
    SYSTEM_STATE system_current_state, system_next_state;
    
    typedef struct packed {
        logic green_led, red_led;
        logic [6:0] HEX_1, HEX_2;
    } signal_out;
    
    signal_out current_signal, next_signal;
    
    always_ff @(posedge clk or negedge reset_n) begin : fsm_ff_proc
        if (!reset_n) begin
            system_current_state <= IDLE;
            current_signal <= '{default: 0};
        end else begin
            system_current_state <= system_next_state;
            current_signal <= next_signal;
        end
    end : fsm_ff_proc
    
    always_ff @(posedge clk or negedge reset_n) begin : counter_proc
        if (!reset_n) begin
            counter_delay <= 0;
        end else if (system_current_state == WAIT_PASSWORD_IN ) begin
            counter_delay <= counter_delay + 1;
        end else begin
            counter_delay <= 0;
        end
    end : counter_proc
    
    always_comb begin : fsm_comb_proc
        system_next_state = IDLE;
        next_signal = '{default: 0};
        
        case (system_current_state)
            IDLE: begin
                if (sensor_entrance == 1 && sensor_exit == 0) begin
                    system_next_state = WAIT_PASSWORD_IN;
                    next_signal.green_led = 0;
                    next_signal.red_led = 0;
                    next_signal.HEX_1 = 7'b1111111;
                    next_signal.HEX_2 = 7'b1111111;
                
                end else begin
                    system_next_state = IDLE;
                    next_signal.green_led = 0;
                    next_signal.red_led = 0;
                    next_signal.HEX_1 = 7'b1111111;
                    next_signal.HEX_2 = 7'b1111111;
                end
            end
            
            WAIT_PASSWORD_IN: begin
                if (counter_delay <= 3) begin
                    system_next_state = WAIT_PASSWORD_IN;
                end
              if ((password_1 == 2'b01) && (password_2 == 2'b10)) begin
                    system_next_state = RIGHT_PASSWORD_IN;
                    next_signal.green_led = 1;
                    next_signal.red_led = 0;
                    next_signal.HEX_1 = 7'b0000010;
                    next_signal.HEX_2 = 7'b1000000;
                end else begin
                    system_next_state = WRONG_PASSWORD_IN;
                    next_signal.green_led = 0;
                    next_signal.red_led = 1;
                    next_signal.HEX_1 = 7'b0000110;
                    next_signal.HEX_2 = 7'b0000110;
                end
            end
            
            RIGHT_PASSWORD_IN: begin
                if (sensor_entrance == 1 && sensor_exit == 1) begin
                    system_next_state = STOP;
                    next_signal.green_led = 0;
                    next_signal.red_led = 1;
                    next_signal.HEX_1 = 7'b0010010;
                    next_signal.HEX_2 = 7'b0001100;
                end else if (sensor_exit == 1) begin
                    system_next_state = IDLE;
                    next_signal.green_led = 0;
                    next_signal.red_led = 0;
                    next_signal.HEX_1 = 7'b1111111;
                    next_signal.HEX_2 = 7'b1111111;
                end else begin
                    system_next_state = RIGHT_PASSWORD_IN;
                    next_signal.green_led = 1;
                    next_signal.red_led = 0;
                    next_signal.HEX_1 = 7'b0000010;
                    next_signal.HEX_2 = 7'b1000000;
                end
            end
            
            WRONG_PASSWORD_IN: begin
                if ((password_1 == 2'b01) && (password_2 == 2'b10)) begin
                    system_next_state = RIGHT_PASSWORD_IN;
                    next_signal.green_led = 1;
                    next_signal.red_led = 0;
                    next_signal.HEX_1 = 7'b0000010;
                    next_signal.HEX_2 = 7'b1000000;
                end else begin
                    system_next_state = WRONG_PASSWORD_IN;
                    next_signal.green_led = 0;
                    next_signal.red_led = 1;
                    next_signal.HEX_1 = 7'b0000110;
                    next_signal.HEX_2 = 7'b0000110;
                end
            end
            
            
          STOP:	begin
            
   			 if((password_1 == 2'b01) && (password_2 == 2'b10))	begin
              		system_next_state = RIGHT_PASSWORD_IN;
                    next_signal.green_led = 1;
                    next_signal.red_led = 0;
                    next_signal.HEX_1 = 7'b0000010;
                    next_signal.HEX_2 = 7'b1000000;
            end
            else	begin
              		system_next_state = STOP;
                    next_signal.green_led = 0;
                    next_signal.red_led = 1;
                    next_signal.HEX_1 = 7'b0010010;
                    next_signal.HEX_2 = 7'b0001100;
            end
          end
        endcase
    end : fsm_comb_proc
    
    assign GREEN_LED = current_signal.green_led;
    assign RED_LED = current_signal.red_led;
    assign HEX_1 = current_signal.HEX_1;
    assign HEX_2 = current_signal.HEX_2;
    
endmodule : parking_system
