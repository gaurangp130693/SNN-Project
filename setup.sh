#!/bin/bash

# Get the current working directory using pwd
current_dir=$(pwd)

# Export the variable
export SNN_PROJ_DIR="$current_dir"
export SNN_PROJ_RUN_DIR="$current_dir/run_dir"

# Verify (optional)
echo "SNN_PROJ_DIR is set to: $SNN_PROJ_DIR"
echo "SNN_PROJ_DIR is set to: $SNN_PROJ_RUN_DIR"