`timescale 1ns / 1ps

module tb_parking_system;

    // Inputs
    reg clk;
    reg reset_n;
    reg sensor_entrance;
    reg sensor_exit;
    reg [1:0] password_1;
    reg [1:0] password_2;

    // Outputs
    wire GREEN_LED;
    wire RED_LED;
    wire [6:0] HEX_1;
    wire [6:0] HEX_2;

    // Instantiate the parking_system module
    parking_system uut (
        .clk(clk),
        .reset_n(reset_n),
        .sensor_entrance(sensor_entrance),
        .sensor_exit(sensor_exit),
        .password_1(password_1),
        .password_2(password_2),
        .GREEN_LED(GREEN_LED),
        .RED_LED(RED_LED),
        .HEX_1(HEX_1),
        .HEX_2(HEX_2)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Test sequence
    initial begin
      $dumpfile("dump.vcd"); $dumpvars;
        // Initialize inputs
        reset_n = 0;
        sensor_entrance = 0;
        sensor_exit = 0;
        password_1 = 2'b00;
        password_2 = 2'b00;

        // Wait for global reset
        #20;
        reset_n = 1;

        // Test case 1: Entrance sensor activated, correct password
        #20;
        sensor_entrance = 1;
        sensor_exit = 0;
        password_1 = 2'b01;
        password_2 = 2'b10;

        // Wait for system to process
        #20;
        sensor_entrance = 0;
      	sensor_exit = 0;
      	#20
        // Deactivate sensors
        sensor_entrance = 0;
      	sensor_exit = 1;
        password_1 = 2'b00;
        password_2 = 2'b00;
        
		#5
// 		Test case 2:
      	sensor_entrance = 0;
        sensor_exit = 0;
        password_1 = 2'b01;
        password_2 = 2'b10;

        // Wait for system to process
        #40;
        
        // Deactivate sensors
        sensor_entrance = 0;
      	sensor_exit = 0;
        password_1 = 2'b00;
        password_2 = 2'b00;
      	  
      	#100
//       Test case 3:
      	sensor_entrance = 1;
        sensor_exit = 0;
        password_1 = 2'b10;
        password_2 = 2'b01;

        // Wait for system to process
        #20;
        sensor_entrance = 0;
        sensor_exit = 0;
      	#20
        // Deactivate sensors
        sensor_entrance = 0;
      	sensor_exit = 1;
        password_1 = 2'b00;
        password_2 = 2'b00;
      	#20
      	password_1 = 2'b01;
        password_2 = 2'b10;
      	#20
      	sensor_entrance = 0;
      	sensor_exit = 1;
        // End simulation
        #100;
        $finish;
    end

endmodule
