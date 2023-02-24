#!/usr/bin/env bash

set -euo pipefail

kubectl apply -f /kubernetes --recursive

tail -f /dev/null
