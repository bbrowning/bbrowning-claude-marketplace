# MCP (Model Context Protocol) Authorization Security

This reference provides comprehensive guidance for reviewing MCP server implementations with a focus on OAuth 2.1 authorization and security best practices.

## Overview

The Model Context Protocol (MCP) specification finalized OAuth 2.1-based authorization in June 2025. MCP servers represent high-value targets because they:
- Store authentication tokens for multiple services
- Execute actions across connected services
- Can be invoked by AI agents with varying levels of user oversight
- Potentially have access to sensitive data and operations

**Key Security Principle:** MCP servers must implement strict authorization controls to prevent unauthorized access and token misuse.

## MCP Authorization Requirements

### 1. OAuth 2.1 Compliance (MANDATORY)

The MCP specification requires OAuth 2.1 as the authorization foundation.

**Core Requirements:**
- MUST use OAuth 2.1 (not OAuth 2.0)
- MUST implement PKCE (Proof Key for Code Exchange) for all clients
- MUST implement Resource Indicators (RFC 8707)
- MUST validate tokens with correct audience claims
- MUST NOT use sessions for authentication

**What to Look For in PRs:**
```python
# ❌ NON-COMPLIANT - OAuth 2.0 without PKCE
@app.route('/authorize')
def authorize():
    redirect_uri = request.args.get('redirect_uri')
    # Missing code_challenge and code_challenge_method
    auth_code = generate_auth_code()
    return redirect(f'{redirect_uri}?code={auth_code}')

# ✅ COMPLIANT - OAuth 2.1 with PKCE
@app.route('/authorize')
def authorize():
    code_challenge = request.args.get('code_challenge')
    code_challenge_method = request.args.get('code_challenge_method')

    if not code_challenge or code_challenge_method != 'S256':
        return {'error': 'invalid_request', 'error_description': 'PKCE required'}, 400

    auth_code = generate_auth_code(code_challenge)
    return redirect(f'{redirect_uri}?code={auth_code}')
```

**Severity:** CRITICAL if PKCE missing, HIGH if OAuth 2.0 instead of 2.1

### 2. Resource Indicators (RFC 8707) - MANDATORY

MCP clients MUST implement Resource Indicators to explicitly specify the target MCP server.

**Purpose:**
- Ensures tokens are audience-restricted to specific MCP servers
- Prevents token misuse across different MCP servers
- Enables proper multi-tenant security

**What to Look For in PRs:**
```python
# ❌ MISSING RESOURCE INDICATOR
token_request = {
    'grant_type': 'authorization_code',
    'code': auth_code,
    'redirect_uri': redirect_uri,
    # Missing 'resource' parameter!
}

# ✅ CORRECT - WITH RESOURCE INDICATOR
token_request = {
    'grant_type': 'authorization_code',
    'code': auth_code,
    'redirect_uri': redirect_uri,
    'resource': 'https://mcp-server.example.com',  # Explicit target
    'code_verifier': code_verifier  # PKCE
}
```

**Audience Validation:**
```python
# ✅ MCP SERVER MUST VALIDATE AUDIENCE
def validate_token(token):
    try:
        payload = jwt.decode(
            token,
            public_key,
            algorithms=['RS256'],
            audience='https://mcp-server.example.com',  # Must match resource
            issuer='https://auth.example.com'
        )
        return payload
    except jwt.InvalidAudienceError:
        raise HTTPException(403, 'Token not intended for this MCP server')
```

**Severity:** CRITICAL if missing

### 3. Strict Token Acceptance Policy

**MCP servers MUST NOT accept tokens that were not explicitly issued for them.**

This is the core defense against confused deputy attacks.

**What to Look For in PRs:**
```python
# ❌ VULNERABLE - ACCEPTS ANY TOKEN
def authorize_request(request):
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    # No audience validation!
    payload = jwt.decode(token, public_key, algorithms=['RS256'])
    return payload['user_id']

# ✅ SECURE - VALIDATES AUDIENCE
def authorize_request(request):
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    try:
        payload = jwt.decode(
            token,
            public_key,
            algorithms=['RS256'],
            audience=MCP_SERVER_IDENTIFIER,  # This server's identifier
            issuer=TRUSTED_ISSUER
        )
    except jwt.InvalidAudienceError:
        raise Forbidden('Token not issued for this MCP server')

    return payload
```

**Severity:** CRITICAL

### 4. Scope Validation and Insufficient Scope Response

MCP servers MUST validate that tokens have the required scopes for operations.

**Required Behavior:**
- When a token has insufficient scope, respond with HTTP 403 Forbidden
- Include `WWW-Authenticate` header with `error="insufficient_scope"`
- Optionally include `scope` parameter indicating required scopes

**What to Look For in PRs:**
```python
# ❌ MISSING SCOPE VALIDATION
@app.route('/tools/invoke', methods=['POST'])
def invoke_tool(token_payload):
    # No scope check!
    result = execute_tool(request.json['tool_name'])
    return result

# ✅ CORRECT SCOPE VALIDATION
@app.route('/tools/invoke', methods=['POST'])
def invoke_tool(token_payload):
    required_scope = 'tools.invoke'

    if required_scope not in token_payload.get('scope', '').split():
        response = Response(
            'Insufficient scope',
            status=403,
            headers={
                'WWW-Authenticate': f'Bearer error="insufficient_scope", scope="{required_scope}"'
            }
        )
        return response

    result = execute_tool(request.json['tool_name'])
    return result
```

**Severity:** HIGH

### 5. No Session-Based Authentication

**MCP servers MUST NOT use sessions for authentication.**

This is a specific requirement of the MCP specification.

**What to Look For in PRs:**
```python
# ❌ VIOLATES MCP SPEC - USING SESSIONS
@app.route('/tools/list')
def list_tools():
    if 'user_id' not in session:
        return {'error': 'unauthorized'}, 401
    # Using Flask session - NOT ALLOWED

# ✅ COMPLIANT - TOKEN-BASED
@app.route('/tools/list')
def list_tools():
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    payload = validate_mcp_token(token)  # OAuth 2.1 token validation
    return get_tools_for_user(payload['sub'])
```

**Severity:** CRITICAL - violates MCP specification

### 6. Secure Session ID Generation (if used for OAuth flow)

If the MCP server or authorization server uses session IDs during the OAuth flow (not for authentication):

**Requirements:**
- MUST use secure, non-deterministic session IDs
- MUST use cryptographically secure random number generators
- MUST have sufficient entropy to prevent guessing

**What to Look For in PRs:**
```python
# ❌ WEAK SESSION ID
import random
session_id = str(random.randint(1000, 9999))  # Predictable!

# ✅ SECURE SESSION ID
import secrets
session_id = secrets.token_urlsafe(32)  # Cryptographically secure
```

**Severity:** HIGH

## Token Forwarding to MCP Servers

### The Critical Security Issue

A common anti-pattern is forwarding user authentication tokens from an inference server (or other service) to an MCP server.

**Example of Vulnerable Flow:**
```
User → Inference Server (with user JWT)
         ↓
     Inference Server → MCP Server (forwarding user JWT) ❌ INSECURE
```

**Why This Is Dangerous:**

1. **Audience Mismatch**: User JWT has `aud` claim for inference server, not MCP server
2. **Confused Deputy**: MCP server cannot verify inference server is authorized to delegate
3. **No Scope Restriction**: MCP server receives user's full permissions, not downscoped
4. **Violates MCP Spec**: MCP servers must only accept tokens issued for them

**What to Look For in PRs:**
```python
# ❌ CRITICAL VULNERABILITY
class InferenceServer:
    def call_mcp_tool(self, user_token, tool_name, params):
        # Forwarding user token directly to MCP server!
        response = requests.post(
            f'{MCP_SERVER_URL}/tools/invoke',
            headers={'Authorization': f'Bearer {user_token}'},  # WRONG!
            json={'tool': tool_name, 'params': params}
        )
        return response.json()
```

**Severity:** CRITICAL - Must be blocked before merge

### The Correct Pattern: Token Exchange

**Secure Flow:**
```
User → Inference Server (with user JWT)
         ↓ (validate user JWT)
     Inference Server → Auth Server (token exchange request)
         ↓ (receives MCP-scoped token)
     Inference Server → MCP Server (with MCP-specific token) ✓ SECURE
```

**What to Look For in PRs:**
```python
# ✅ CORRECT - TOKEN EXCHANGE
class InferenceServer:
    def call_mcp_tool(self, user_token, tool_name, params):
        # Step 1: Validate user token
        user_claims = self.validate_user_token(user_token)

        # Step 2: Exchange for MCP-specific token
        mcp_token = self.exchange_token_for_mcp(
            user_token=user_token,
            mcp_server='https://mcp-server.example.com',
            required_scopes=['tools.invoke']
        )

        # Step 3: Use MCP-specific token
        response = requests.post(
            f'{MCP_SERVER_URL}/tools/invoke',
            headers={'Authorization': f'Bearer {mcp_token}'},  # Correct audience
            json={'tool': tool_name, 'params': params}
        )
        return response.json()

    def exchange_token_for_mcp(self, user_token, mcp_server, required_scopes):
        """Exchange user token for MCP-server-specific token"""
        exchange_response = requests.post(
            f'{AUTH_SERVER_URL}/token',
            data={
                'grant_type': 'urn:ietf:params:oauth:grant-type:token-exchange',
                'subject_token': user_token,
                'subject_token_type': 'urn:ietf:params:oauth:token-type:access_token',
                'resource': mcp_server,  # RFC 8707 Resource Indicator
                'scope': ' '.join(required_scopes)  # Downscoped
            }
        )

        if exchange_response.status_code != 200:
            raise AuthorizationError('Token exchange failed')

        return exchange_response.json()['access_token']
```

**Key Security Benefits:**
1. ✅ MCP token has correct `aud` claim for the MCP server
2. ✅ Token is downscoped to minimum needed permissions
3. ✅ Clear audit trail preserved (user → inference → MCP)
4. ✅ Complies with MCP OAuth 2.1 specification
5. ✅ Prevents confused deputy attacks
6. ✅ MCP server can properly validate the token

**Severity:** Implementation of token exchange is CRITICAL when missing

## MCP Server Architecture Patterns

### Pattern 1: Embedded Authorization Server

The MCP server includes its own auth system.

**Characteristics:**
- Handles login, user sessions, consent UI
- Issues and verifies tokens
- Acts as both authorization server and resource server

**Security Considerations:**
- Must implement full OAuth 2.1 spec
- Requires secure user credential management
- Needs proper consent UI for user authorization
- Session management during OAuth flow (not for MCP operations)

### Pattern 2: External Authorization Server (Recommended)

The MCP server delegates OAuth to a trusted external provider.

**Characteristics:**
- Authorization server handles authentication, user management, consent
- MCP server only validates tokens and enforces scopes
- Clear separation of concerns

**Security Benefits:**
- Leverages battle-tested auth infrastructure
- Reduces attack surface of MCP server
- Easier to audit and maintain
- Better compliance with OAuth 2.1 spec

**What to Look For in PRs:**
```python
# ✅ EXTERNAL AUTH SERVER PATTERN
class MCPServer:
    def __init__(self, auth_server_url, mcp_server_id):
        self.auth_server_url = auth_server_url
        self.mcp_server_id = mcp_server_id
        # Fetch public keys from auth server
        self.public_keys = self.fetch_jwks()

    def validate_token(self, token):
        """Validate token issued by external auth server"""
        try:
            payload = jwt.decode(
                token,
                self.public_keys,
                algorithms=['RS256'],
                audience=self.mcp_server_id,
                issuer=self.auth_server_url
            )
            return payload
        except jwt.InvalidTokenError as e:
            raise Unauthorized(str(e))

    def fetch_jwks(self):
        """Fetch JSON Web Key Set from auth server"""
        response = requests.get(f'{self.auth_server_url}/.well-known/jwks.json')
        return response.json()
```

## Transport Security

### Mutual TLS (mTLS)

For production MCP deployments, especially in enterprise environments:

**Requirement:** Transport security SHOULD use mutual TLS (mTLS) for bidirectional verification.

**What to Look For in PRs:**
```python
# ✅ mTLS CONFIGURATION
import ssl

context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
context.verify_mode = ssl.CERT_REQUIRED
context.load_cert_chain(certfile='server.crt', keyfile='server.key')
context.load_verify_locations(cafile='client_ca.crt')

# Use context in server configuration
server = HTTPServer(('localhost', 8443), MCPRequestHandler)
server.socket = context.wrap_socket(server.socket, server_side=True)
```

**Severity:** MEDIUM for internal deployments, HIGH for external-facing servers

### HTTPS Mandatory

**All MCP communication MUST occur over HTTPS (or equivalent secure transport).**

**What to Look For in PRs:**
- HTTP URLs in production configurations (red flag)
- Missing TLS/SSL certificate validation
- Disabled certificate verification (`verify=False`)

**Severity:** CRITICAL if HTTP used in production

## Security Risks Specific to MCP

### 1. High-Value Target

MCP servers store tokens for multiple services. If compromised:
- Attacker gains access to all connected service tokens
- Can execute actions across all integrated services
- Potential for lateral movement across services

**Mitigation:**
- Encrypt tokens at rest
- Use short-lived tokens with refresh
- Implement rate limiting and anomaly detection
- Audit all token usage

### 2. Prompt Injection Attacks

AI agents can be manipulated through prompt injection to:
- Execute unintended MCP tool invocations
- Access unauthorized resources
- Exfiltrate data through tool responses

**What to Look For in PRs:**
- Input validation on tool parameters
- Scope restrictions preventing dangerous operations
- Audit logging of all tool invocations
- User confirmation for sensitive operations

**Severity:** HIGH to CRITICAL depending on MCP server capabilities

### 3. Cross-Prompt Injection

Malicious content embedded in documents or UI can override agent instructions.

**Mitigation:**
- Sanitize external content before processing
- Implement content security policies
- Separate user instructions from external content
- Require explicit user confirmation for sensitive actions

**Severity:** HIGH

### 4. Remote Code Execution Risk

If MCP tools can execute code or system commands, prompt injection could lead to RCE.

**What to Look For in PRs:**
- Code execution capabilities without sandboxing
- System command execution from tool parameters
- File system access without path validation
- Network access without destination whitelisting

**Severity:** CRITICAL

## Review Checklist for MCP Code

When reviewing PRs involving MCP server implementation:

### Critical Checks
- [ ] **OAuth 2.1 compliance**: Using OAuth 2.1 (not 2.0)
- [ ] **PKCE mandatory**: All authorization flows use PKCE with S256
- [ ] **Resource Indicators**: Token requests include explicit `resource` parameter
- [ ] **Audience validation**: Server validates `aud` claim matches its identifier
- [ ] **No token forwarding**: Server doesn't accept tokens issued for other services
- [ ] **Token exchange**: Uses token exchange for upstream service calls
- [ ] **No session auth**: Doesn't use sessions for MCP operation authentication

### High Priority Checks
- [ ] **Scope validation**: Validates required scopes and returns proper insufficient_scope errors
- [ ] **Issuer validation**: Validates `iss` claim against trusted issuers
- [ ] **Algorithm enforcement**: Explicit algorithm list (no `none`, no user-controlled)
- [ ] **Signature validation**: All tokens cryptographically validated
- [ ] **HTTPS/TLS**: All communication over secure transport
- [ ] **Input validation**: Tool parameters validated and sanitized

### Medium Priority Checks
- [ ] **Token storage**: Tokens encrypted at rest
- [ ] **Audit logging**: Tool invocations logged with user context
- [ ] **Rate limiting**: Prevents abuse of MCP endpoints
- [ ] **Least privilege**: Scopes are minimal and specific
- [ ] **mTLS consideration**: mTLS for production deployments
- [ ] **Secure session IDs**: If used in OAuth flow, cryptographically random

### MCP-Specific Security Patterns

**Inference Server + MCP Architecture:**
```
✅ SECURE PATTERN:
1. User authenticates to inference server
2. Inference server validates user token
3. Inference server exchanges token for MCP-specific token
4. Inference server invokes MCP with proper token
5. MCP server validates audience matches its identifier

❌ INSECURE PATTERN:
1. User authenticates to inference server
2. Inference server forwards user token to MCP
3. MCP server accepts token not issued for it
```

## Platform-Specific Considerations

### Windows 11 MCP Proxy

Windows 11 provides centralized MCP proxy for security:

**Features:**
- Proxy-mediated communication for all MCP interactions
- Centralized policy enforcement
- Consistent authentication and authorization
- Enhanced audit and monitoring

**What to Look For in PRs:**
- Windows platform should integrate with Windows 11 MCP proxy
- Proxy configuration and policy settings
- Proper certificate validation for proxy communication

**Severity:** MEDIUM for Windows deployments

## Key Standards and Specifications

- **MCP Authorization Spec** (June 2025): Official OAuth 2.1 authorization for MCP
- **OAuth 2.1**: Required authorization framework
- **RFC 7636**: PKCE - Mandatory for all MCP clients
- **RFC 8707**: Resource Indicators - Mandatory for MCP token requests
- **RFC 8693**: Token Exchange - Recommended for service-to-service delegation
- **RFC 9068**: JWT Profile for OAuth 2.0 Access Tokens
- **RFC 9700**: OAuth 2.0 Security Best Current Practice (January 2025)

## When to Escalate

Escalate to security team or mark as CRITICAL if you find:

1. **Token forwarding**: Inference/API servers forwarding user tokens to MCP servers
2. **Missing audience validation**: MCP server accepts tokens without validating `aud` claim
3. **No PKCE**: Authorization flow missing PKCE implementation
4. **No Resource Indicators**: Token requests missing `resource` parameter
5. **Session-based auth**: Using sessions for MCP operation authentication
6. **Prompt injection risks**: MCP tools with code execution and no sandboxing
7. **Missing OAuth 2.1**: Still using OAuth 2.0 instead of 2.1
8. **HTTP communication**: Production MCP server using HTTP instead of HTTPS

## Summary

MCP authorization security requires:
1. **OAuth 2.1** with PKCE (mandatory)
2. **Resource Indicators** (RFC 8707) for explicit audience targeting
3. **Strict token validation** (audience, issuer, signature, scopes)
4. **Token exchange** for service-to-service delegation (not forwarding)
5. **No session-based authentication** for MCP operations
6. **Secure transport** (HTTPS/TLS, preferably mTLS)
7. **Input validation** and prompt injection protection

The most common vulnerability is token forwarding from inference servers to MCP servers. This must be replaced with proper token exchange flows.
