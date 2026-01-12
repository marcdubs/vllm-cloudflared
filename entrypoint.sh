#!/bin/bash
set -e

echo "Starting vLLM service..."

# Build vLLM command with common defaults
VLLM_CMD="python3 -m vllm.entrypoints.openai.api_server"

# Add host and port (default to 0.0.0.0:8000)
VLLM_CMD="$VLLM_CMD --host ${VLLM_HOST:-0.0.0.0} --port ${VLLM_PORT:-8000}"

# Add model if specified
if [ -n "$VLLM_MODEL" ]; then
    VLLM_CMD="$VLLM_CMD --model $VLLM_MODEL"
fi

# Add tensor parallel size if specified
if [ -n "$VLLM_TENSOR_PARALLEL_SIZE" ]; then
    VLLM_CMD="$VLLM_CMD --tensor-parallel-size $VLLM_TENSOR_PARALLEL_SIZE"
fi

# Add GPU memory utilization if specified
if [ -n "$VLLM_GPU_MEMORY_UTILIZATION" ]; then
    VLLM_CMD="$VLLM_CMD --gpu-memory-utilization $VLLM_GPU_MEMORY_UTILIZATION"
fi

# Add max model length if specified
if [ -n "$VLLM_MAX_MODEL_LEN" ]; then
    VLLM_CMD="$VLLM_CMD --max-model-len $VLLM_MAX_MODEL_LEN"
fi

# Add any additional arguments
if [ -n "$VLLM_EXTRA_ARGS" ]; then
    VLLM_CMD="$VLLM_CMD $VLLM_EXTRA_ARGS"
fi

echo "Running: $VLLM_CMD"
$VLLM_CMD &
VLLM_PID=$!

sleep 5

if [ -n "$TUNNEL_TOKEN" ]; then
    echo "Starting Cloudflare Tunnel..."
    cloudflared tunnel --no-autoupdate run --token "$TUNNEL_TOKEN" &
    echo "Tunnel running"
fi

wait $VLLM_PID
