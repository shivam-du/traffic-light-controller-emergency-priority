
`timescale 1ns/1ps

module traffic_controller_improved_tb;

reg clk;
reg reset;
reg emg_A;
reg emg_B;

wire A_red;
wire A_yellow;
wire A_green;

wire B_red;
wire B_yellow;
wire B_green;

traffic_controller uut(
    .clk(clk),
    .reset(reset),
    .emg_A(emg_A),
    .emg_B(emg_B),
    .A_red(A_red),
    .A_yellow(A_yellow),
    .A_green(A_green),
    .B_red(B_red),
    .B_yellow(B_yellow),
    .B_green(B_green)
);

always #5 clk = ~clk;

initial
begin
    clk = 0;
    reset = 1;
    emg_A = 0;
    emg_B = 0;

    #20;
    reset = 0;

    // Normal operation
    #150;

    // Emergency on Road B
    emg_B = 1;
    #50;
    emg_B = 0;

    #100;

    // Emergency on Road A
    emg_A = 1;
    #50;
    emg_A = 0;

    #100;

    // Simultaneous emergency
    emg_A = 1;
    emg_B = 1;
    #50;
    emg_A = 0;
    emg_B = 0;

    #100;

    // Reset during operation
    reset = 1;
    #20;
    reset = 0;

    #100;

    $finish;
end

endmodule
