//==============================================================================
//  File name: snn_apb_csr.sv
//  Author : Gaurang Pandey
//  Description: CSR block for each neuron layer
//==============================================================================

module snn_csr_apb #(
  parameter int INPUT_SIZE = 8,   // Number of input neurons
  parameter int OUTPUT_SIZE = 4,  // Number of output neurons
  parameter int WEIGHT_BASE_ADDR = 16'h0000,
  parameter int SPIKE_THRESH_BASE_ADDR = 16'h1000,
  parameter int NEURON_THRESH_BASE_ADDR = 16'h2000,
  parameter int CONTROL_STATUS_BASE_ADDR = 16'h3000
)(
  input logic clk,
  input logic rst_n,

  // APB Interface
  input logic psel,
  input logic penable,
  input logic pwrite,
  input logic [15:0] paddr,
  input logic [31:0] pwdata,
  output logic [31:0] prdata,
  output logic pready,

  // Registers
  output logic [31:0] weight_reg [(INPUT_SIZE * OUTPUT_SIZE) - 1:0],
  output logic [31:0] spike_threshold [(INPUT_SIZE * OUTPUT_SIZE) - 1:0],
  output logic [31:0] neuron_threshold [OUTPUT_SIZE-1:0],
  output logic [31:0] cntrl_status_csr
);

  integer i, j;

  always_ff @(posedge clk or negedge rst_n) begin
    logic [31:0] idx;
    if (!rst_n) begin
      // Reset all registers to zero
      for (i = 0; i < INPUT_SIZE; i++) begin
        for (j = 0; j < OUTPUT_SIZE; j++) begin
          weight_reg[i * OUTPUT_SIZE + j]      <= 32'h0000_0000;
          spike_threshold[i * OUTPUT_SIZE + j] <= 32'h0000_0000;
        end
      end
      for (j = 0; j < OUTPUT_SIZE; j++) begin
        neuron_threshold[j] <= 32'h0000_0000;;
      end
      cntrl_status_csr <= 32'h0000_0000;
    end else if (psel && penable && pwrite) begin
      if (paddr >= WEIGHT_BASE_ADDR && paddr < (WEIGHT_BASE_ADDR + (INPUT_SIZE * OUTPUT_SIZE * 4))) begin
        idx = (paddr - WEIGHT_BASE_ADDR >> 2);
        weight_reg[idx] <= pwdata[31:0];
      end

      if (paddr >= SPIKE_THRESH_BASE_ADDR && paddr < (SPIKE_THRESH_BASE_ADDR + (INPUT_SIZE * OUTPUT_SIZE * 4))) begin
        idx = (paddr - SPIKE_THRESH_BASE_ADDR >> 2);
        spike_threshold[idx] <= pwdata[31:0];
      end

      if (paddr >= NEURON_THRESH_BASE_ADDR && paddr < (NEURON_THRESH_BASE_ADDR + (OUTPUT_SIZE * 4))) begin
        idx = (paddr - NEURON_THRESH_BASE_ADDR >> 2);
        neuron_threshold[idx]   <= pwdata[31:0];
      end

      if (paddr >= CONTROL_STATUS_BASE_ADDR && paddr < (CONTROL_STATUS_BASE_ADDR + 4)) begin
        cntrl_status_csr   <= pwdata[31:0];
      end
    end
  end

  // APB Read Logic
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      prdata <= 32'h00000000;
    else if (psel && !penable && !pwrite) begin
      // Capture the read value in the setup phase
      if (paddr >= WEIGHT_BASE_ADDR && paddr < (WEIGHT_BASE_ADDR + (INPUT_SIZE * OUTPUT_SIZE * 4)))
        prdata <= weight_reg[(paddr - WEIGHT_BASE_ADDR >> 2)];
      else if (paddr >= SPIKE_THRESH_BASE_ADDR && paddr < (SPIKE_THRESH_BASE_ADDR + (INPUT_SIZE * OUTPUT_SIZE * 4)))
        prdata <= spike_threshold[(paddr - SPIKE_THRESH_BASE_ADDR >> 2)];
      else if (paddr >= NEURON_THRESH_BASE_ADDR && paddr < (NEURON_THRESH_BASE_ADDR + (OUTPUT_SIZE * 4)))
        prdata <= neuron_threshold[(paddr - NEURON_THRESH_BASE_ADDR >> 2)];
      else if (paddr >= CONTROL_STATUS_BASE_ADDR && paddr < (CONTROL_STATUS_BASE_ADDR + 4))
        prdata <= cntrl_status_csr;
      else
        prdata <= 32'h00000000;
    end
  end


  // Always ready for APB transaction
  assign pready = 1'b1;

endmodule