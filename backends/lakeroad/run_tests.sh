#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
YOSYS=$(realpath "$SCRIPT_DIR/../../yosys")

function run_lakeroad_backend() {
  $YOSYS -q -l "<stderr>" -p "read_verilog -sv $1; write_lakeroad"
}

failed=0

for f in "$SCRIPT_DIR"/tests/*.sv ; do
  # Fail if "$f".expect does not exist
  if [ ! -f "$f".expect ]; then
    echo "No expect file for $f"
    failed=1
    continue
  fi

  # Run Lakeroad Yosys backend
  out=$(run_lakeroad_backend "$f")

  # Check result
  if ! diff <(echo "$out") <(cat "$f".expect); then
    echo "Test failed for $f"
    failed=1
  fi 
done

exit $failed