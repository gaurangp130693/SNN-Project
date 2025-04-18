#!/bin/bash

# Usage:
# ./run.sh <test_name> <enable_coverage: 1|0>

TEST_NAME=$1
ENABLE_COV=$2

# Default to some test if not provided
if [ -z "$TEST_NAME" ]; then
  TEST_NAME=base_test
fi

# If coverage is enabled (1), add coverage option
if [ "$ENABLE_COV" == "1" ]; then
  COV_OPTIONS="-covfile coverage.ccf"
else
  COV_OPTIONS=""
fi

# Run the simulation
xrun -sv -uvmhome $UVM_HOME \
     -f files.f \
     -access +rwc \
     -licqueue \
     -timescale 1ns/1ps \
     -input waves.tcl \
     +UVM_TESTNAME=$TEST_NAME \
     $COV_OPTIONS