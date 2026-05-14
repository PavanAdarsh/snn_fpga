`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.05.2026 11:29:25
// Design Name: 
// Module Name: network
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module network(clk,reset,input_spike,output_spike);

    parameter DATA_SIZE = 4, NEURON_NUM = 4, CONST_SIZE = 16;
    
    input clk,reset;
    input [DATA_SIZE-1:0] input_spike;
    output [NEURON_NUM-1:0] output_spike;
    
    reg [CONST_SIZE-1:0] thresholds [NEURON_NUM-1:0];
    reg [CONST_SIZE-1:0] leaks [NEURON_NUM-1:0];
    //reg [7:0] weights [NEURON_NUM-1:0][DATA_SIZE-1:0];
    
    //4(neuron_num) separate 32(data_size*8)bit registers.
    //flattening weights to avoid verilog 2-d array issues
    reg [(DATA_SIZE*8)-1:0] weights_flat [NEURON_NUM-1:0]; 
     
    genvar i;
    generate //to instantiate NEURON_NUM copies of LIF module
        for(i=0;i<NEURON_NUM;i=i+1)
        begin : neuron_array
            lif_neuron #(.DATA_SIZE(DATA_SIZE),.CONST_SIZE(CONST_SIZE)) 
            neuron_inst (
                        .clk(clk),.reset(reset),.threshold(thresholds[i]),.leak(leaks[i]),
                        .input_spike(input_spike),.output_spike(output_spike[i]),
                        .weights_flat(weights_flat[i]));
        end
    endgenerate
endmodule
