`timescale 1ns / 1ps

module traffic_controller(
    input wire clk,
    input wire reset,
    input wire emg_A,
    input wire emg_B,

    output reg A_red,
    output reg A_yellow,
    output reg A_green,

    output reg B_red,
    output reg B_yellow,
    output reg B_green
);

    // State Encoding
    localparam S0 = 3'd0;   // A Green
    localparam S1 = 3'd1;   // A Yellow
    localparam S2 = 3'd2;   // B Green
    localparam S3 = 3'd3;   // B Yellow
    localparam S4 = 3'd4;   // Emergency A
    localparam S5 = 3'd5;   // Emergency B

    reg [2:0] current_state;
    reg [2:0] next_state;

    reg [4:0] counter;

    // Timing Parameters
    localparam A_GREEN_TIME  = 10;
    localparam A_YELLOW_TIME = 3;
    localparam B_GREEN_TIME  = 10;
    localparam B_YELLOW_TIME = 3;

    // State Register
    always @(posedge clk or posedge reset)
    begin
        if(reset)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // Counter Logic
    always @(posedge clk or posedge reset)
    begin
        if(reset)
            counter <= 0;
        else if(current_state != next_state)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    // Next State Logic
    always @(*)
    begin
        next_state = current_state;

        case(current_state)

            // A GREEN
            S0:
            begin
                if(emg_B)
                    next_state = S1;
                else if(counter >= A_GREEN_TIME)
                    next_state = S1;
            end

            // A YELLOW
            S1:
            begin
                if(counter >= A_YELLOW_TIME)
                begin
                    if(emg_B)
                        next_state = S5;
                    else
                        next_state = S2;
                end
            end

            // B GREEN
            S2:
            begin
                if(emg_A)
                    next_state = S3;
                else if(counter >= B_GREEN_TIME)
                    next_state = S3;
            end

            // B YELLOW
            S3:
            begin
                if(counter >= B_YELLOW_TIME)
                begin
                    if(emg_A)
                        next_state = S4;
                    else
                        next_state = S0;
                end
            end

            // EMERGENCY A
            S4:
            begin
                if(!emg_A)
                    next_state = S0;
            end

            // EMERGENCY B
            S5:
            begin
                if(!emg_B)
                    next_state = S2;
            end

            default:
                next_state = S0;

        endcase
    end
    
    // Output Logic (Moore FSM)
    always @(*)
    begin

        // Default Outputs
        A_red    = 1'b0;
        A_yellow = 1'b0;
        A_green  = 1'b0;

        B_red    = 1'b0;
        B_yellow = 1'b0;
        B_green  = 1'b0;

        case(current_state)

            S0:
            begin
                A_green = 1'b1;
                B_red   = 1'b1;
            end

            S1:
            begin
                A_yellow = 1'b1;
                B_red    = 1'b1;
            end

            S2:
            begin
                A_red   = 1'b1;
                B_green = 1'b1;
            end

            S3:
            begin
                A_red    = 1'b1;
                B_yellow = 1'b1;
            end

            S4:
            begin
                A_green = 1'b1;
                B_red   = 1'b1;
            end

            S5:
            begin
                A_red   = 1'b1;
                B_green = 1'b1;
            end

            default:
            begin
                A_red = 1'b1;
                B_red = 1'b1;
            end

        endcase
    end

endmodule