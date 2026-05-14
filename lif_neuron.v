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
    
    parameter INTEGRATE = 0, REFRACTORY = 1;
    reg state, next_state;
    reg [3:0] refractory_time,next_refractory_time; //counting elapsed cycles in refractory
    
    output reg output_spike;
    reg next_output_spike;
    
    reg [15:0] membrane,next_membrane;
    reg [15:0] sum;
    
    //weighted sum calculation, purely combinational
    integer i;
    always@(*) begin
        sum = 0;
        for(i=0;i<DATA_SIZE;i=i+1) begin
            sum = sum + input_spike[i]*weights_flat[(i*8)+:8];
        end
    end
    
    //combinational state machine for refractory period implementation
    always@(*) begin
        //defaults
        next_state = INTEGRATE; next_membrane = membrane; 
        next_refractory_time = refractory_time; next_output_spike = 0;
        case(state) 
            INTEGRATE : begin
                        if(membrane >= threshold) begin//firing 
                                next_output_spike = 1;
                                next_state = REFRACTORY;
                                next_membrane = 0; end
                        else begin //integrate
                                if(membrane+sum>=leak) next_membrane = membrane + sum - leak;
                                else next_membrane = membrane + sum; 
                                next_output_spike = 0;
                                next_state = INTEGRATE; end
                        end
                    
            REFRACTORY: begin
                        if(refractory_time >= refractory_period) begin
                            next_state = INTEGRATE; 
                            next_refractory_time = 0; end
                        else begin
                            next_state = REFRACTORY;
                            next_membrane = 0;
                            next_refractory_time = refractory_time + 1; end
                      end
        endcase
    end
    
    always@(posedge clk) begin
        if(reset) begin
            state <= INTEGRATE;
            output_spike <= 0;
            membrane <= 0;
            refractory_time <= 0; end
        else begin
            state <= next_state;
            output_spike <= next_output_spike;
            membrane <= next_membrane;
            refractory_time <= next_refractory_time; end
        
    end

//    //sequential lif neuron implementation
//    always@(posedge clk) begin //reset
//        if(reset) begin
//            membrane <= 0;
//            output_spike <= 0; end
//        else if(membrane >= threshold) begin //firing sequence
//            membrane <= 0;
//            output_spike <= 1;  end
//        else begin //integration sequence
//            if(membrane + sum >= leak) membrane <= membrane + sum - leak;
//            else membrane <= membrane + sum;
//            output_spike <= 0; end
        
//        state <= next_state;
//    end
     
endmodule
