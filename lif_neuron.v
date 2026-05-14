`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.05.2026 19:39:14
// Design Name: 
// Module Name: lif_neuron
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


module lif_neuron #(parameter DATA_SIZE = 4, CONST_SIZE = 8) //default, can be overridden
            (input_spike,weights_flat,clk,reset,threshold,leak,output_spike,
            refractory_period);

    input [DATA_SIZE-1:0] input_spike;
    input [(DATA_SIZE*8)-1:0] weights_flat; //32 bit array each time
    input clk,reset;
    input [CONST_SIZE-1:0] threshold,leak;
    input [3:0] refractory_period; // 0 to 7 clock cycles sufficient
    
    output reg output_spike;
    
    reg [15:0] membrane;
    reg [15:0] sum;
    
    //weighted sum calculation, purely combinational
    integer i;
    always@(*) begin
        sum = 0;
        for(i=0;i<DATA_SIZE;i=i+1) begin
            sum = sum + input_spike[i]*weights_flat[(i*8)+:8];
        end
    end

    //lif neuron implementation
    always@(posedge clk) begin
        if(reset) begin
            membrane <= 0;
            output_spike <= 0;  end
        else if(membrane >= threshold) begin
            membrane <= 0;
            output_spike <= 1; end
        else begin
            if(membrane + sum >= leak) membrane <= membrane + sum - leak;
            else membrane <= membrane + sum;
            output_spike <= 0;
        end
    end
    
endmodule
