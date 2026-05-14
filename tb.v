`timescale 1ns / 1ps

module network_tb;

parameter DATA_SIZE  = 4;
parameter NEURON_NUM = 4;
parameter CONST_SIZE = 16;

reg clk;
reg reset;

reg [DATA_SIZE-1:0] input_spike;

wire [NEURON_NUM-1:0] output_spike;

network #(
    .DATA_SIZE(DATA_SIZE),
    .NEURON_NUM(NEURON_NUM),
    .CONST_SIZE(CONST_SIZE)
) uut (
    .clk(clk),
    .reset(reset),
    .input_spike(input_spike),
    .output_spike(output_spike)
);

always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;
    input_spike = 0;

    #20;
    reset = 0;

    uut.thresholds[0] = 16'd10;
    uut.thresholds[1] = 16'd15;
    uut.thresholds[2] = 16'd20;
    uut.thresholds[3] = 16'd25;

    uut.leaks[0] = 16'd1;
    uut.leaks[1] = 16'd2;
    uut.leaks[2] = 16'd1;
    uut.leaks[3] = 16'd3;

    uut.refractory_periods[0] = 2;
    uut.refractory_periods[1] = 3;
    uut.refractory_periods[2] = 4;
    uut.refractory_periods[3] = 5;

    uut.weights_flat[0] = {8'd4,8'd3,8'd2,8'd1};
    uut.weights_flat[1] = {8'd1,8'd1,8'd5,8'd2};
    uut.weights_flat[2] = {8'd3,8'd4,8'd1,8'd6};
    uut.weights_flat[3] = {8'd2,8'd2,8'd2,8'd2};

    #10 input_spike = 4'b0001;
    #10 input_spike = 4'b0011;
    #10 input_spike = 4'b1111;
    #10 input_spike = 4'b0101;
    #10 input_spike = 4'b1111;
    #10 input_spike = 4'b0000;
    #10 input_spike = 4'b1111;
    #10 input_spike = 4'b0010;
    #10 input_spike = 4'b0000;

    #200;

    $finish;

end

endmodule