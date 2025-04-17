${SNN_PROJ_DIR}/rtl/claude/network/network_pkg.sv
${SNN_PROJ_DIR}/rtl/claude/network/neuron_pkg.sv
${SNN_PROJ_DIR}/rtl/claude/lif_neuron/lif_neuron.sv
${SNN_PROJ_DIR}/rtl/claude/input_processor/input_processor.sv
${SNN_PROJ_DIR}/rtl/claude/synapse/synapse.sv
${SNN_PROJ_DIR}/rtl/claude/neuron_layer/neuron_layer.sv
${SNN_PROJ_DIR}/rtl/claude/snn_csr/snn_csr_apb.sv
${SNN_PROJ_DIR}/rtl/claude/network/clock_divider.sv
${SNN_PROJ_DIR}/rtl/claude/network/reset_synchronizer.sv
${SNN_PROJ_DIR}/rtl/claude/network/network.sv
${SNN_PROJ_DIR}/rtl/claude/network/network_tb.sv

+incdir+${SNN_PROJ_DIR}/verif/apb_agent
${SNN_PROJ_DIR}/verif/apb_agent/apb_if.sv
${SNN_PROJ_DIR}/verif/apb_agent/apb_pkg.sv

+incdir+${SNN_PROJ_DIR}/verif/snn_reg_model
${SNN_PROJ_DIR}/verif/snn_reg_model/snn_reg_pkg.sv

+incdir+${SNN_PROJ_DIR}/verif/network/snn_agent
+incdir+${SNN_PROJ_DIR}/verif/network/vseq
+incdir+${SNN_PROJ_DIR}/verif/network/env
+incdir+${SNN_PROJ_DIR}/verif/network/test
+incdir+${SNN_PROJ_DIR}/verif/network/tb
${SNN_PROJ_DIR}/verif/network/tb/snn_if.sv
${SNN_PROJ_DIR}/verif/network/tb/snn_tb_pkg.sv
${SNN_PROJ_DIR}/verif/network/tb/snn_tb_top.sv