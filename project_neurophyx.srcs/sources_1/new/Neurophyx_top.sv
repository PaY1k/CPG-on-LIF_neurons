
module neurophyx_top#(
    parameter int unsigned POTENTIAL_CAPACITY_A     = 16, // Разрядность потенциала
    parameter int unsigned POTENTIAL_CAPACITY_B     = 32, // Разрядность потенциала
    parameter int unsigned INHIBITION_VALUE_A       = 16, // Тормозящий потенциал
    parameter int unsigned INHIBITION_VALUE_B       = 16, // Тормозящий потенциал
    parameter int unsigned SPIKE_VALUE_A            = 16, // Потенциал спайка А
    parameter int unsigned SPIKE_VALUE_B            = 16, // Потенциал спайка B
    parameter int unsigned BACKGROUND_CURRENT       =  6, // Фоновый ток
    parameter int unsigned LEAKEDGE_VALUE_A         =  1, // Утечка нейрона А 
    parameter int unsigned LEAKEDGE_VALUE_B         =  1, // Утечка нейрона В
    parameter int unsigned REFRACTORY_PERIOD_TIME_A =  5, // Период рефракторинга А 
    parameter int unsigned REFRACTORY_PERIOD_TIME_B =  5  // Период рефракторинга В  
)   (
    input clk,arstn,
    input start,
    input [31:0] initial_spike,
    output is_spike_A_o,
    output is_spike_B_o,
    output [31:0] potential_a_o,
    output [31:0] potential_b_o
    );
    logic        is_spike_A;
    logic        is_spike_B;
    logic        is_refractory_A = '0;
    logic        is_refractory_B = '0;
    logic [31:0] spike_from_A;
    logic        inhibition_b;
    logic        start_impulse;
    logic [31:0] neuron_potential_a = '0;
    logic [31:0] neuron_potential_b = '0;
    logic [31:0] refractory_timer_A = '0;
    logic [31:0] refractory_timer_B = '0;
    assign inhibition_b  = (is_spike_B) ? INHIBITION_VALUE_B : '0;
    assign start_impulse = (start) ? initial_spike : '0;
    assign spike_from_A  = (is_spike_A) ? SPIKE_VALUE_A : '0;
   
    
    //Refractory period logic
    //A
    always_ff @( posedge clk or negedge arstn ) begin 
        if (!arstn) begin
            refractory_timer_A <= '0;
        end
        else if (refractory_timer_A == REFRACTORY_PERIOD_TIME_A) begin
            refractory_timer_A <= '0;
        end
        else if (is_refractory_A) begin
            refractory_timer_A <= refractory_timer_A + 1'b1;;
        end
        else begin
            refractory_timer_A <= '0;
        end
    end
    always_comb begin
        if (refractory_timer_A == REFRACTORY_PERIOD_TIME_A) begin
            is_refractory_A = 1'b0;
        end
        else if (is_spike_A) begin
            is_refractory_A = 1'b1;
        end
    end
    //B
    always_ff @( posedge clk or negedge arstn ) begin 
        if (!arstn) begin
            refractory_timer_B <= '0;
        end
        else if (refractory_timer_B == REFRACTORY_PERIOD_TIME_B) begin
            refractory_timer_B <= '0;
        end
        else if (is_refractory_B) begin
            refractory_timer_B <= refractory_timer_B + 1'b1;;
        end
        else begin
            refractory_timer_B <= '0;
        end
    end
    always_comb begin
        if (refractory_timer_B == REFRACTORY_PERIOD_TIME_B) begin
            is_refractory_B = 1'b0;
        end
        else if (is_spike_B) begin
            is_refractory_B = 1'b1;
        end
    end
    //LIF-neurons logic
   //Neuron A
    always_ff @( posedge clk or negedge arstn ) begin : neuron_A
        if (!arstn) begin
            neuron_potential_a <= '0;
        end
        //Refractory period logic
        else if (is_refractory_A) begin
            neuron_potential_a <= '0;
        end
        else begin
            if ((neuron_potential_a + BACKGROUND_CURRENT + start_impulse) > (LEAKEDGE_VALUE_A + inhibition_b)) begin
                if (neuron_potential_a > 0) begin
                    neuron_potential_a <= neuron_potential_a + BACKGROUND_CURRENT + start_impulse - inhibition_b - LEAKEDGE_VALUE_A;
                end
                else begin
                    neuron_potential_a <= neuron_potential_a + BACKGROUND_CURRENT + start_impulse;
                end
            end
            else begin
                neuron_potential_a <= '0 + BACKGROUND_CURRENT + start_impulse;
            end
        end
    end
    //Spike A
    always_comb begin : spike_A
        if (neuron_potential_a >= POTENTIAL_CAPACITY_A) begin
            is_spike_A <= 1'b1;
        end
        else begin
            is_spike_A <= 1'b0;
        end
    end
    //Neuron B
    always_ff @( posedge clk or negedge arstn ) begin : neuron_B
        if (!arstn) begin
            neuron_potential_b <= '0;
        end
        //Refractory period logic
        else if (is_refractory_B) begin
            neuron_potential_b <= '0;
        end
        else begin
            if ((neuron_potential_b + spike_from_A) > LEAKEDGE_VALUE_B) begin
                if (neuron_potential_b > 0) begin
                    neuron_potential_b <= neuron_potential_b - LEAKEDGE_VALUE_B + spike_from_A;
                end
                else begin
                    neuron_potential_b <= neuron_potential_b + spike_from_A;
                end
            end
            else begin
                neuron_potential_b <= '0 + spike_from_A;
            end
        end
    end
    //Spike B
    always_comb begin : spike_B
        if (neuron_potential_b >= POTENTIAL_CAPACITY_B) begin
            is_spike_B <= 1'b1;
        end
        else begin
            is_spike_B <= 1'b0;
        end
    end
    assign is_spike_A_o = is_spike_A;
    assign is_spike_B_o = is_spike_B;
endmodule
