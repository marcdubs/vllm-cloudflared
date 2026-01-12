# vLLM with Cloudflared

Custom Docker image that combines [vLLM](https://github.com/vllm-project/vllm) with [Cloudflare Tunnel](https://www.cloudflare.com/products/tunnel/) (cloudflared) for secure remote access.

## Features

- Based on the official `vllm/vllm-openai:latest` image
- Embedded Cloudflare Tunnel (cloudflared) for secure remote access
- OpenAI-compatible API server
- Flexible configuration via environment variables
- Automated builds when upstream vLLM image updates, at least daily, or manually via GitHub Actions

## Usage

### Pull the image

```bash
docker pull ghcr.io/marcdubs/vllm-cloudflared:latest
```

### Run without Cloudflare Tunnel

```bash
docker run -d \
  --gpus all \
  -p 8000:8000 \
  -e VLLM_MODEL="facebook/opt-125m" \
  ghcr.io/marcdubs/vllm-cloudflared:latest
```

### Run with Cloudflare Tunnel

```bash
docker run -d \
  --gpus all \
  -e TUNNEL_TOKEN="your-tunnel-token" \
  -e VLLM_MODEL="facebook/opt-125m" \
  ghcr.io/marcdubs/vllm-cloudflared:latest
```

### Advanced Configuration

```bash
docker run -d \
  --gpus all \
  -e TUNNEL_TOKEN="your-tunnel-token" \
  -e VLLM_MODEL="meta-llama/Llama-2-7b-hf" \
  -e VLLM_TENSOR_PARALLEL_SIZE="2" \
  -e VLLM_GPU_MEMORY_UTILIZATION="0.9" \
  -e VLLM_MAX_MODEL_LEN="4096" \
  ghcr.io/marcdubs/vllm-cloudflared:latest
```

## Environment Variables

### Required
- `VLLM_MODEL`: The model to serve (e.g., `facebook/opt-125m`, `meta-llama/Llama-2-7b-hf`)

### Optional
- `TUNNEL_TOKEN`: Cloudflare Tunnel token (required for tunnel functionality)
- `VLLM_HOST`: Host to bind to (default: `0.0.0.0`)
- `VLLM_PORT`: Port to bind to (default: `8000`)
- `VLLM_TENSOR_PARALLEL_SIZE`: Number of GPUs to use for tensor parallelism
- `VLLM_GPU_MEMORY_UTILIZATION`: Fraction of GPU memory to use (default: `0.9`)
- `VLLM_MAX_MODEL_LEN`: Maximum model context length
- `VLLM_EXTRA_ARGS`: Additional arguments to pass to vLLM (e.g., `--dtype auto --trust-remote-code`)

## API Usage

Once running, the vLLM server exposes an OpenAI-compatible API at `http://localhost:8000/v1`:

```bash
# List models
curl http://localhost:8000/v1/models

# Generate completion
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "San Francisco is a",
    "max_tokens": 50
  }'

# Chat completion
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "messages": [
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

## Building Locally

```bash
docker build -t vllm-cloudflared .
```

## Automated Builds

This repository uses GitHub Actions to automatically build and push Docker images:

- **On Push**: Builds and pushes on every push to master/main branch
- **Daily**: Checks if upstream `vllm/vllm-openai:latest` has been updated and rebuilds if changed
- **Manual**: Can be triggered manually via GitHub Actions workflow dispatch

The workflow tracks the upstream image digest and only rebuilds when necessary, saving resources.

## Getting a Cloudflare Tunnel Token

1. Log in to [Cloudflare Zero Trust](https://one.dash.cloudflare.com/)
2. Go to **Networks** > **Tunnels**
3. Create a new tunnel or use an existing one
4. Copy the tunnel token from the installation instructions

## GPU Requirements

vLLM requires NVIDIA GPUs with CUDA support. Make sure you have:
- NVIDIA Docker runtime installed
- Appropriate GPU drivers
- Sufficient GPU memory for your chosen model

## License

This project uses vLLM and Cloudflared, which have their own respective licenses.
