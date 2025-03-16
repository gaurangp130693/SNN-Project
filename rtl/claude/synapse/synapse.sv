//==============================================================================
//  File name: synapse.sv
//  Author : Gaurang Pandey
//  Description : Synapse module without learning, weight is loaded externally 
//  and affects output spike generation
//==============================================================================

module synapse
  import neuron_pkg::*;
#(
  parameter int SPIKING_WINDOW = 16  // Spiking window (e.g., 16 clock cycles)
)(
  input  logic        clk,
  input  logic        rst_n,
  input  logic        pre_spike,       // Incoming spike train
  input  weight_t     weight,          // Synaptic weight
  input  weight_t     threshold,       // Threshold for generating spikes
  output logic        weighted_spike   // Output weighted spike train
);

  logic [15:0] spike_counter; // Counter to accumulate weighted spikes
  logic [3:0]  cycle_counter; // Counts cycles within the spiking window

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      spike_counter <= 0;
      cycle_counter <= 0;
      weighted_spike <= 0;
    end else begin
      if (cycle_counter < SPIKING_WINDOW) begin
        cycle_counter <= cycle_counter + 1;

        if (pre_spike) begin
          spike_counter <= spike_counter + weight;
        end

        // Generate a weighted spike if spike_counter < threshold
        weighted_spike <= (spike_counter > threshold);
      end
      // Reset the spike counter & cycle counter at the end of the spiking window
      if (cycle_counter == SPIKING_WINDOW - 1) begin
        spike_counter <= 0;
        cycle_counter <= 0;
      end
    end
  end

endmodule