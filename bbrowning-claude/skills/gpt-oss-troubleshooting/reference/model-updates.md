# Updating gpt-oss Model Files

## Why Update Model Files?

The `openai_harmony.HarmonyError: Unexpected token` errors are often caused by outdated `generation_config.json` files. HuggingFace updates these files to fix token parsing issues.

## Current Configuration Files

### gpt-oss-20b generation_config.json

Latest version includes:
```json
{
  "bos_token_id": 199998,
  "do_sample": true,
  "eos_token_id": [
    200002,
    199999,
    200012
  ],
  "pad_token_id": 199999,
  "transformers_version": "4.55.0.dev0"
}
```

**Key elements**:
- **eos_token_id**: Multiple EOS tokens including 200012 (tool call completion)
- **do_sample**: Enabled for generation diversity
- **transformers_version**: Indicates compatible transformers version

### gpt-oss-120b Critical Commit

**Commit**: 8b193b0ef83bd41b40eb71fee8f1432315e02a3e
- Fixed generation_config.json
- Confirmed to resolve token parsing errors by user andresC98
- Applied to gpt-oss-120b model

## How to Update Model Files

### Method 1: Re-download with HuggingFace CLI

```bash
# Install or update huggingface-hub
pip install --upgrade huggingface-hub

# For gpt-oss-20b
huggingface-cli download openai/gpt-oss-20b --local-dir ./gpt-oss-20b

# For gpt-oss-120b
huggingface-cli download openai/gpt-oss-120b --local-dir ./gpt-oss-120b
```

### Method 2: Manual Update via Web

1. Visit HuggingFace model page:
   - gpt-oss-20b: https://huggingface.co/openai/gpt-oss-20b
   - gpt-oss-120b: https://huggingface.co/openai/gpt-oss-120b

2. Navigate to "Files and versions" tab

3. Download latest `generation_config.json`

4. Replace in your local model directory:
   ```bash
   # Find your model directory (varies by vLLM installation)
   # Common locations:
   # ~/.cache/huggingface/hub/models--openai--gpt-oss-20b/
   # ./models/gpt-oss-20b/

   # Replace the file
   cp ~/Downloads/generation_config.json /path/to/model/directory/
   ```

### Method 3: Update with git (if model was cloned)

```bash
cd /path/to/model/directory
git pull origin main
```

## Verification Steps

After updating:

1. **Check file contents**:
   ```bash
   cat generation_config.json
   ```

   Verify it matches the current version shown above.

2. **Check modification date**:
   ```bash
   ls -l generation_config.json
   ```

   Should be recent (after the commit date).

3. **Restart vLLM server**:
   ```bash
   # Stop existing server
   # Start with correct flags (see tool-calling-setup.md)
   vllm serve openai/gpt-oss-20b \
     --tool-call-parser openai \
     --enable-auto-tool-choice
   ```

4. **Test tool calling**:
   ```python
   from openai import OpenAI

   client = OpenAI(base_url="http://localhost:8000/v1")

   response = client.chat.completions.create(
       model="openai/gpt-oss-20b",
       messages=[{"role": "user", "content": "What's the weather?"}],
       tools=[{
           "type": "function",
           "function": {
               "name": "get_weather",
               "description": "Get the weather",
               "parameters": {
                   "type": "object",
                   "properties": {
                       "location": {"type": "string"}
                   }
               }
           }
       }]
   )

   print(response)
   ```

## Troubleshooting Update Issues

### vLLM Not Picking Up Changes

**Symptom**: Updated files but still getting errors

**Solutions**:
1. Clear vLLM cache:
   ```bash
   rm -rf ~/.cache/vllm/
   ```

2. Restart vLLM with fresh model load:
   ```bash
   # Use --download-dir to force specific directory
   vllm serve openai/gpt-oss-20b \
     --download-dir /path/to/models \
     --tool-call-parser openai \
     --enable-auto-tool-choice
   ```

3. Check vLLM is loading the correct model directory:
   - Look for model path in vLLM startup logs
   - Verify it matches where you updated files

### File Permission Issues

```bash
# Ensure files are readable
chmod 644 generation_config.json

# Check ownership
ls -l generation_config.json
```

### Multiple Model Copies

**Problem**: vLLM might be loading from a different location

**Solution**:
1. Find all copies:
   ```bash
   find ~/.cache -name "generation_config.json" -path "*/gpt-oss*"
   ```

2. Update all copies or remove duplicates

3. Use explicit `--download-dir` flag when starting vLLM

## Additional Files to Check

While `generation_config.json` is the primary fix, also verify these files are current:

### config.json
Contains model architecture configuration

### tokenizer_config.json
Token encoding settings, including special tokens

### special_tokens_map.json
Maps special token strings to IDs

**To update all**:
```bash
huggingface-cli download openai/gpt-oss-20b \
  --local-dir ./gpt-oss-20b \
  --force-download
```

## When to Update

Update model files when:
- Encountering token parsing errors
- HuggingFace shows recent commits to model repo
- vLLM error messages reference token IDs
- After vLLM version upgrades
- Community reports fixes via file updates

## Cross-References

- Known issues: See known-issues.md
- vLLM configuration: See tool-calling-setup.md
