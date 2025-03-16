//==============================================================================
//  File name: input_processor.sv
//  Author : Gaurang Pandey
//  Description: Input Layer - Converts pixel values to spike trains
//
//
//==============================================================================

module input_processor
  import network_pkg::*;
(
  input  logic                     clk,          // Clock signal
  input  logic                     rst_n,        // Active-low reset
  input  logic                     clk_cnt,      // External counter clock input (slower)
  input  logic [PIXEL_WIDTH-1:0]   pixel_value [INPUT_SIZE-1:0], // 8-bit pixel values
  output logic                     spike_out  [INPUT_SIZE-1:0]  // Spike train outputs
);

  // Counter for each input neuron
  logic [$clog2(SPIKE_WINDOW)-1:0] counter [INPUT_SIZE-1:0];

  genvar i;
  generate
    for (i = 0; i < INPUT_SIZE; i++) begin : gen_input
      always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          spike_out[i] <= 1'b0;
        end else begin
          // Compute dynamic threshold (pixel_value * SPIKE_WINDOW / 256)
          logic [$clog2(SPIKE_WINDOW):0] threshold;  // Extra bit to avoid overflow
          threshold = (pixel_value[i] * SPIKE_WINDOW) >> 8; // Equivalent to / 256

          // Generate spike based on pixel intensity threshold
          spike_out[i] <= (counter[i] < threshold);
        end
      end
    end
  endgenerate

  genvar j;
  generate
    for (j = 0; j < INPUT_SIZE; j++) begin : gen_counter
      always_ff @(posedge clk_cnt or negedge rst_n) begin
        if (!rst_n) begin
          counter[j]   <= '0;
        end else begin
          // Reset counter at SPIKE_WINDOW max
          if (counter[j] >= SPIKE_WINDOW-1)
            counter[j] <= 0;
          else
            counter[j] <= counter[j] + 1;
        end
      end
    end
  endgenerate
endmodule