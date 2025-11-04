# Tool Calling Configuration for gpt-oss with vLLM

## Required vLLM Server Flags

For gpt-oss tool calling to work, vLLM must be started with specific flags.

### Minimal Configuration

```bash
vllm serve openai/gpt-oss-20b \
  --tool-call-parser openai \
  --enable-auto-tool-choice
```

### Full Configuration with Tool Server

```bash
vllm serve openai/gpt-oss-20b \
  --tool-call-parser openai \
  --enable-auto-tool-choice \
  --tool-server demo \
  --max-model-len 8192 \
  --dtype auto
```

## Flag Explanations

### --tool-call-parser openai
- **Required**: Yes
- **Purpose**: Uses OpenAI-compatible tool calling format
- **Effect**: Enables proper parsing of tool call tokens
- **Alternatives**: None for gpt-oss compatibility

### --enable-auto-tool-choice
- **Required**: Yes
- **Purpose**: Allows automatic tool selection
- **Effect**: Model can choose which tool to call
- **Note**: Only `tool_choice='auto'` is supported

### --tool-server
- **Required**: Optional, but needed for demo tools
- **Options**:
  - `demo`: Built-in demo tools (browser, Python interpreter)
  - `ip:port`: Custom MCP tool server
  - Multiple servers: `ip1:port1,ip2:port2`

### --max-model-len
- **Required**: No
- **Purpose**: Sets maximum context length
- **Recommended**: 8192 or higher for tool calling contexts
- **Effect**: Prevents truncation during multi-turn tool conversations

## Tool Server Options

### Demo Tool Server

Requires gpt-oss library:
```bash
pip install gpt-oss
```

Provides:
- Web browser tool
- Python interpreter tool

Start command:
```bash
vllm serve openai/gpt-oss-20b \
  --tool-call-parser openai \
  --enable-auto-tool-choice \
  --tool-server demo
```

### MCP Tool Servers

Start vLLM with MCP server URLs:
```bash
vllm serve openai/gpt-oss-20b \
  --tool-call-parser openai \
  --enable-auto-tool-choice \
  --tool-server localhost:5000,localhost:5001
```

Requirements:
- MCP servers must be running before vLLM starts
- Must implement MCP protocol
- Should return results in expected format

### No Tool Server (Client-Managed Tools)

For client-side tool management (e.g., llama-stack with MCP):
```bash
vllm serve openai/gpt-oss-20b \
  --tool-call-parser openai \
  --enable-auto-tool-choice
```

Tools are provided via API request, not server config.

## Environment Variables

### Search Tools

For demo tool server with search:
```bash
export EXA_API_KEY="your-exa-api-key"
```

### Python Execution

For safe Python execution (recommended for demo):
```bash
export PYTHON_EXECUTION_BACKEND=dangerously_use_uv
```

**Warning**: Demo Python execution is for testing only.

## Client Configuration

### OpenAI-Compatible Clients

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8000/v1",
    api_key="not-needed"  # vLLM doesn't require auth by default
)

response = client.chat.completions.create(
    model="openai/gpt-oss-20b",
    messages=[{"role": "user", "content": "What's 2+2?"}],
    tools=[{
        "type": "function",
        "function": {
            "name": "calculator",
            "description": "Perform calculations",
            "parameters": {
                "type": "object",
                "properties": {
                    "expression": {"type": "string"}
                },
                "required": ["expression"]
            }
        }
    }],
    tool_choice="auto"  # MUST be 'auto' - only supported value
)
```

### llama-stack Configuration

Example run.yaml for llama-stack with vLLM:
```yaml
inference:
  - provider_id: vllm-provider
    provider_type: remote::vllm
    config:
      url: http://localhost:8000/v1
      # No auth_credential needed if vLLM has no auth

tool_runtime:
  - provider_id: mcp-provider
    provider_type: mcp
    config:
      servers:
        - server_name: my-tools
          url: http://localhost:5000
```

## Common Configuration Issues

### Issue: tool_choice Not Working

**Symptom**: Error about unsupported tool_choice value

**Solution**: Only use `tool_choice="auto"`, other values not supported:
```python
# GOOD
tool_choice="auto"

# BAD - will fail
tool_choice="required"
tool_choice={"type": "function", "function": {"name": "my_func"}}
```

### Issue: Tools Not Being Called

**Symptoms**:
- Model describes tool usage in text
- No tool_calls in response
- Empty tool_calls array

**Checklist**:
1. Verify `--tool-call-parser openai` flag is set
2. Verify `--enable-auto-tool-choice` flag is set
3. Check generation_config.json is up to date (see model-updates.md)
4. Try simpler tool schemas first
5. Check vLLM logs for parsing errors

### Issue: Token Parsing Errors

**Error**: `openai_harmony.HarmonyError: Unexpected token X`

**Solutions**:
1. Update model files (see model-updates.md)
2. Verify vLLM version is recent
3. Check vLLM startup logs for warnings
4. Restart vLLM server after any config changes

## Performance Tuning

### GPU Memory

```bash
vllm serve openai/gpt-oss-20b \
  --tool-call-parser openai \
  --enable-auto-tool-choice \
  --gpu-memory-utilization 0.9
```

### Tensor Parallelism

For multi-GPU:
```bash
vllm serve openai/gpt-oss-20b \
  --tool-call-parser openai \
  --enable-auto-tool-choice \
  --tensor-parallel-size 2
```

### Batching

```bash
vllm serve openai/gpt-oss-20b \
  --tool-call-parser openai \
  --enable-auto-tool-choice \
  --max-num-batched-tokens 8192 \
  --max-num-seqs 256
```

## Testing Your Configuration

### Basic Test

```bash
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "messages": [{"role": "user", "content": "Calculate 15 * 7"}],
    "tools": [{
      "type": "function",
      "function": {
        "name": "calculator",
        "description": "Perform math",
        "parameters": {
          "type": "object",
          "properties": {"expr": {"type": "string"}}
        }
      }
    }],
    "tool_choice": "auto"
  }'
```

### Expected Response

Success indicates tool_calls array with function call:
```json
{
  "choices": [{
    "message": {
      "role": "assistant",
      "content": null,
      "tool_calls": [{
        "id": "call_123",
        "type": "function",
        "function": {
          "name": "calculator",
          "arguments": "{\"expr\": \"15 * 7\"}"
        }
      }]
    }
  }]
}
```

### Failure Indicators

- `content` field has text describing calculation instead of null
- `tool_calls` is empty or null
- Error in response about tool parsing
- HarmonyError in vLLM logs

## Cross-References

- Model file updates: See model-updates.md
- Known issues: See known-issues.md
