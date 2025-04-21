#!/bin/bash

# Usage:
# ./run.sh <test_name> <enable_coverage: 1|0>

TEST_NAME=$1
ENABLE_COV=$2
NEURON_NUM=$3
SCB_EN=$4

# Default to some test if not provided
if [ -z "$TEST_NAME" ]; then
  TEST_NAME=base_test
fi

# If coverage is enabled (1), add coverage option
if [ "$ENABLE_COV" == "1" ]; then
  COV_OPTIONS="-covfile $SNN_PROJ_DIR/verif/network/coverage.ccf"
else
  COV_OPTIONS=""
fi

# Create run directory if it doesn't exist
if [ ! -d "run" ]; then
  mkdir -p run
fi

# Create test directory inside run directory
mkdir -p run/$TEST_NAME

# Change to the test directory
cd run/$TEST_NAME

echo "Running simulation for test: $TEST_NAME in directory: $(pwd)"

# Run the simulation
xrun -sv -uvmhome $UVM_HOME \
     -f $SNN_PROJ_DIR/verif/network/files.f \
     -access +rwc \
     -licqueue \
     -timescale 1ns/1ps \
     -input $SNN_PROJ_DIR/verif/network/waves.tcl \
     +UVM_TESTNAME=$TEST_NAME \
     +NEURON_NUM=$NEURON_NUM \
     +SCB_EN=$SCB_EN \
     $COV_OPTIONS