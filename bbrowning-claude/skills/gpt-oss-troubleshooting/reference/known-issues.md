# Known GitHub Issues for gpt-oss and vLLM

## Active Issues

### vLLM Repository

#### Issue #22519: Token Error with gpt-oss-20b Tool Calls
- **URL**: https://github.com/vllm-project/vllm/issues/22519
- **Error**: `Unexpected token 12606 while expecting start token 200006`
- **Status**: Open, To Triage
- **Model**: gpt-oss-20b
- **Symptoms**:
  - Error occurs after model returns token 200012
  - Token 12606 = "comment"
  - Hypothesis: Model incorrectly splitting "commentary" into "comment" + "ary"
- **Workaround**: None currently documented

#### Issue #22515: Same Error, Fixed by Config Update
- **URL**: https://github.com/vllm-project/vllm/issues/22515
- **Error**: Same token parsing error
- **Status**: Open
- **Fix**: Update generation_config.json from HuggingFace
  - Specific commit: 8b193b0ef83bd41b40eb71fee8f1432315e02a3e
  - User andresC98 confirmed this resolved the issue
- **Version**: Reported in vLLM v0.10.2

#### Issue #22578: gpt-oss-120b Tool Call Support
- **URL**: https://github.com/vllm-project/vllm/issues/22578
- **Error**: Chat Completions endpoint tool_call not working
- **Status**: Open
- **Model**: gpt-oss-120b
- **Symptoms**: Tool calling doesn't work correctly via /v1/chat/completions

#### Issue #22337: Empty Tool Calls Array
- **URL**: https://github.com/vllm-project/vllm/issues/22337
- **Error**: tool_calls returning empty arrays
- **Status**: Open
- **Model**: gpt-oss-120b
- **Symptoms**: Content appears in wrong format, tool_calls=[]

#### Issue #23567: Unexpected Tokens in Message Header
- **URL**: https://github.com/vllm-project/vllm/issues/23567
- **Error**: `openai_harmony.HarmonyError: unexpected tokens remaining in message header`
- **Status**: Open
- **Symptoms**: Occurs in multi-turn conversations with gpt-oss-120b
- **Version**: vLLM v0.10.1 and v0.10.1.1

#### PR #24787: Tool Call Turn Tracking
- **URL**: https://github.com/vllm-project/vllm/pull/24787
- **Title**: Pass toolcall turn to kv cache manager
- **Status**: Merged (September 2025)
- **Description**: Adds toolcall_turn parameter for tracking turns in tool-calling conversations
- **Impact**: Enables better prefix cache statistics for tool calling

### HuggingFace Discussions

#### gpt-oss-20b Discussion #80: Tool Calling Configuration
- **URL**: https://huggingface.co/openai/gpt-oss-20b/discussions/80
- **Summary**: Community discussion about tool calling best practices
- **Key Findings**:
  - Explicit tool listing in system prompt improves results
  - Better results with tool_choice='required' or 'auto'
  - Avoid requiring JSON response format
  - Configuration and prompt engineering significantly impact tool calling behavior

#### gpt-oss-120b Discussion #69: Chat Template Spec Errors
- **URL**: https://huggingface.co/openai/gpt-oss-120b/discussions/69
- **Summary**: Errors in chat template compared to spec
- **Impact**: May affect tool calling format

### openai/harmony Repository

#### Issue #33: EOS Error While Waiting for Message Header
- **URL**: https://github.com/openai/harmony/issues/33
- **Error**: `HarmonyError: Unexpected EOS while waiting for message header to complete`
- **Status**: Open
- **Context**: Core Harmony parser issue affecting message parsing

## Error Pattern Summary

### Token Mismatch Errors
- **Pattern**: `Unexpected token X while expecting start token Y`
- **Root Cause**: Model generating text tokens instead of Harmony control tokens
- **Common Triggers**: Tool calling, multi-turn conversations
- **Primary Fix**: Update generation_config.json

### Streaming Errors
- **Pattern**: Parse failures during streaming responses
- **Root Cause**: Incompatibility between request format and vLLM token generation
- **Affected**: Both 20b and 120b models

### Tool Calling Failures
- **Pattern**: Empty tool_calls arrays or text descriptions instead of calls
- **Root Cause**: Configuration issues or outdated model files
- **Primary Fix**: Correct vLLM flags and update generation_config.json

## Version Compatibility

### vLLM Versions
- **v0.10.2**: Multiple token parsing errors reported
- **v0.10.1/v0.10.1.1**: Multi-turn conversation errors
- **Latest**: Check for fixes in newer releases

### Recommended Actions by Version
- **Pre-v0.11**: Update to latest, refresh model files
- **v0.11+**: Verify tool calling flags are set correctly

## Cross-References

- Model file updates: See model-updates.md
- Tool calling configuration: See tool-calling-setup.md
