# JWT Security Best Practices

This reference provides comprehensive guidance for reviewing JWT (JSON Web Token) implementation and usage in pull requests.

## Critical Security Principles

### 1. Never Forward JWTs to Unintended Services

**The Problem:**
A JWT contains an `aud` (audience) claim that specifies which service(s) the token is intended for. Forwarding a JWT to a service not listed in the audience claim creates serious security vulnerabilities.

**Security Impact:**
- **Confused Deputy Attack**: The receiving service cannot verify that the forwarding service is authorized to act on behalf of the user
- **Privilege Escalation**: If the receiving service accepts tokens not intended for it, attackers can misuse tokens from one service at another
- **ALBEAST-Class Vulnerability**: Tokens intended for one tenant/service can be used at another

**What to Look For in PRs:**
```python
# ❌ CRITICAL SECURITY ISSUE
def call_external_api(user_token):
    # Forwarding user's JWT directly to third-party service
    response = requests.get(
        "https://third-party-api.com/resource",
        headers={"Authorization": f"Bearer {user_token}"}
    )
```

**Severity:** CRITICAL - Must be blocked before merge

### 2. Validate Audience Claims

Every service that accepts JWTs **MUST** validate the `aud` claim matches its own identifier.

**RFC Requirements:**
- Per RFC 7519: "Each principal intended to process the JWT MUST identify itself with a value in the audience claim"
- Per RFC 9068: "The resource server MUST validate that the aud claim contains a resource indicator value corresponding to an identifier the resource server expects for itself"
- **The JWT MUST be rejected if the audience does not match**

**What to Look For in PRs:**
```python
# ❌ MISSING VALIDATION
def verify_token(token):
    decoded = jwt.decode(token, public_key, algorithms=['RS256'])
    # Missing audience validation!
    return decoded

# ✅ CORRECT VALIDATION
def verify_token(token):
    decoded = jwt.decode(
        token,
        public_key,
        algorithms=['RS256'],
        audience='https://api.myservice.com'  # Validates aud claim
    )
    return decoded
```

**Severity:** CRITICAL if missing, HIGH if incomplete

### 3. Validate All Critical Claims

Beyond audience, validate:

**Required Validations:**
- `iss` (issuer): Verify the token came from a trusted authorization server
- `aud` (audience): Verify the token is intended for this service
- `exp` (expiration): Reject expired tokens
- `nbf` (not before): Reject tokens used before their valid time
- `alg` (algorithm): Prevent algorithm confusion attacks

**What to Look For in PRs:**
```python
# ❌ VULNERABLE TO ALGORITHM CONFUSION
def verify_token(token):
    # Accepts ANY algorithm from the token header
    decoded = jwt.decode(token, secret, algorithms=None)

# ✅ CORRECT - EXPLICIT ALGORITHM
def verify_token(token):
    # Only accepts expected algorithm
    decoded = jwt.decode(
        token,
        public_key,
        algorithms=['RS256'],  # Explicit, not from token
        issuer='https://auth.example.com',
        audience='https://api.example.com'
    )
```

**Severity:** CRITICAL for algorithm validation, HIGH for other claims

### 4. Use Token Exchange for Service-to-Service Communication

When a service needs to call another service on behalf of a user, **use OAuth Token Exchange (RFC 8693)** rather than forwarding the original token.

**The Correct Pattern:**
```python
# ✅ SECURE TOKEN EXCHANGE PATTERN
def call_downstream_service(user_token):
    # Exchange user token for service-specific token
    exchange_response = requests.post(
        'https://auth.example.com/token',
        data={
            'grant_type': 'urn:ietf:params:oauth:grant-type:token-exchange',
            'subject_token': user_token,
            'subject_token_type': 'urn:ietf:params:oauth:token-type:access_token',
            'resource': 'https://downstream-service.example.com',
            'scope': 'read:data'  # Downscoped to minimum needed
        }
    )

    downstream_token = exchange_response.json()['access_token']

    # Use the service-specific token
    response = requests.get(
        'https://downstream-service.example.com/api/resource',
        headers={'Authorization': f'Bearer {downstream_token}'}
    )
```

**Benefits of Token Exchange:**
1. **Correct Audience**: New token has proper `aud` claim for downstream service
2. **Least Privilege**: Token is downscoped to minimum permissions needed
3. **Audit Trail**: Clear chain of delegation (user → service A → service B)
4. **Prevents Confused Deputy**: Downstream service can validate the token was properly issued

**What to Look For in PRs:**
- Services forwarding user JWTs to other services without exchange
- Missing token exchange implementation where multi-service calls exist
- Tokens with overly broad scopes being passed between services

**Severity:** CRITICAL in security-sensitive contexts, HIGH otherwise

### 5. Apply Principle of Least Privilege

**Scope Downscoping:**
When exchanging tokens, request only the minimum scopes needed for the specific operation.

```python
# ❌ OVER-PRIVILEGED
exchange_data = {
    'scope': 'read write admin delete'  # Too many permissions!
}

# ✅ LEAST PRIVILEGE
exchange_data = {
    'scope': 'read:invoices'  # Only what's needed
}
```

**Severity:** MEDIUM to HIGH depending on the over-privileging

### 6. Secure Token Storage and Transmission

**Transport Security:**
- JWTs MUST be transmitted over HTTPS only
- Never log full JWTs (mask them if needed for debugging)
- Never include JWTs in URLs (query parameters, path segments)

**Storage Security:**
- Don't store JWTs in localStorage if they contain sensitive data (XSS risk)
- Consider httpOnly cookies for web applications
- Use secure, encrypted storage on mobile platforms
- Implement token refresh to minimize long-lived token exposure

**What to Look For in PRs:**
```javascript
// ❌ SECURITY ISSUES
localStorage.setItem('token', jwt);  // XSS vulnerability
console.log('Token:', jwt);  // Logging sensitive data
const url = `/api/resource?token=${jwt}`;  // Token in URL

// ✅ BETTER PRACTICES
// Use httpOnly cookie or secure storage
document.cookie = `token=${jwt}; Secure; HttpOnly; SameSite=Strict`;
console.log('Token:', jwt.substring(0, 10) + '...');  // Masked logging
```

**Severity:** HIGH for URL exposure, MEDIUM for storage issues

## Algorithm Confusion Attacks

### The Vulnerability

JWT headers include an `alg` parameter that specifies the signing algorithm. If the verification code doesn't enforce the expected algorithm, attackers can:

1. Change RS256 (RSA) to HS256 (HMAC)
2. Use the RSA public key as the HMAC secret
3. Create validly-signed tokens

**What to Look For in PRs:**
```python
# ❌ VULNERABLE
def verify_token(token):
    # Algorithm taken from token header - DANGEROUS!
    header = jwt.get_unverified_header(token)
    alg = header['alg']
    decoded = jwt.decode(token, key, algorithms=[alg])

# ✅ SECURE
def verify_token(token):
    # Algorithm explicitly specified and validated
    decoded = jwt.decode(
        token,
        public_key,
        algorithms=['RS256']  # Only RS256 accepted
    )
```

**Severity:** CRITICAL

### None Algorithm Attack

Some JWT libraries accept `"alg": "none"` which bypasses signature verification entirely.

**What to Look For in PRs:**
```python
# ❌ VULNERABLE
jwt.decode(token, verify=False)  # Dangerous!
jwt.decode(token, algorithms=['RS256', 'none'])  # Allows none!

# ✅ SECURE
jwt.decode(token, public_key, algorithms=['RS256'])
```

**Severity:** CRITICAL

## Common JWT Anti-Patterns

### 1. Treating ID Tokens as Access Tokens

**Problem:** ID tokens (from OpenID Connect) are meant for the client that requested authentication, NOT for API authorization.

```python
# ❌ WRONG
# Forwarding ID token to API
api_call(headers={'Authorization': f'Bearer {id_token}'})

# ✅ CORRECT
# Use access token for API calls
api_call(headers={'Authorization': f'Bearer {access_token}'})
```

**Severity:** HIGH

### 2. Missing Signature Validation

**Problem:** Accepting unsigned JWTs or skipping validation.

```python
# ❌ VULNERABLE
payload = jwt.decode(token, options={"verify_signature": False})

# ✅ SECURE
payload = jwt.decode(token, public_key, algorithms=['RS256'])
```

**Severity:** CRITICAL

### 3. Trusting Token Content Without Validation

**Problem:** Extracting claims before validating signature and claims.

```python
# ❌ DANGEROUS
def get_user_id(token):
    # Decodes without validation!
    payload = jwt.decode(token, options={"verify_signature": False})
    return payload['user_id']

# ✅ SAFE
def get_user_id(token):
    # Validates first, then extracts
    payload = jwt.decode(
        token,
        public_key,
        algorithms=['RS256'],
        audience='https://api.example.com',
        issuer='https://auth.example.com'
    )
    return payload['user_id']
```

**Severity:** CRITICAL

### 4. Using Weak Secrets for HS256

**Problem:** Using predictable or weak secrets for HMAC signing.

```python
# ❌ WEAK SECRET
secret = "secret123"
jwt.encode(payload, secret, algorithm='HS256')

# ✅ STRONG SECRET
# Use cryptographically random, high-entropy secret
# At least 256 bits (32 bytes) for HS256
import secrets
secret = secrets.token_bytes(32)
```

**Severity:** CRITICAL

### 5. Overly Broad Audiences

**Problem:** Using wildcard or overly generic audience values.

```python
# ❌ TOO BROAD
token_data = {
    'aud': '*',  # Accepts anywhere!
    'aud': 'https://example.com'  # Too generic
}

# ✅ SPECIFIC
token_data = {
    'aud': 'https://api.example.com/v1/orders'  # Specific service
}
```

**Severity:** MEDIUM to HIGH

## Review Checklist for JWT Code

When reviewing PRs involving JWT authentication/authorization:

### Critical Checks
- [ ] **Audience validation**: Every service validates `aud` claim matches its identifier
- [ ] **Algorithm enforcement**: Explicit algorithm list, no `none`, no user-controlled algorithm
- [ ] **Signature validation**: All tokens are cryptographically validated
- [ ] **Issuer validation**: `iss` claim validated against trusted issuers
- [ ] **No token forwarding**: Tokens are not forwarded to services not in their `aud` claim

### High Priority Checks
- [ ] **Token exchange**: Service-to-service calls use token exchange, not forwarding
- [ ] **Expiration validation**: `exp` claim checked and enforced
- [ ] **Scope downscoping**: Exchanged tokens request minimum necessary scopes
- [ ] **ID token misuse**: ID tokens not used for API authorization
- [ ] **Transport security**: Tokens only transmitted over HTTPS

### Medium Priority Checks
- [ ] **Least privilege**: Scopes are specific and minimal
- [ ] **Secure storage**: Tokens stored securely (not localStorage for sensitive data)
- [ ] **Token refresh**: Short-lived tokens with refresh mechanism
- [ ] **Logging safety**: Tokens not logged in full
- [ ] **Error messages**: Don't leak token information in errors

### Code Pattern Recognition

**Token Forwarding Pattern (Usually Wrong):**
```python
# Server receives user_token from client
# Server forwards user_token to another service
downstream_service.call(authorization=user_token)  # ❌ Check this!
```

**Token Exchange Pattern (Usually Correct):**
```python
# Server receives user_token from client
# Server exchanges for service-specific token
new_token = auth_server.exchange_token(user_token, target_service)
# Server uses new token
downstream_service.call(authorization=new_token)  # ✅ Good!
```

## Key RFCs and Standards

- **RFC 7519**: JSON Web Token (JWT) - Core standard
- **RFC 8693**: OAuth 2.0 Token Exchange - Service-to-service delegation
- **RFC 8707**: Resource Indicators for OAuth 2.0 - Explicit audience specification
- **RFC 9068**: JWT Profile for OAuth 2.0 Access Tokens - Access token best practices
- **RFC 9700**: OAuth 2.0 Security Best Current Practice (January 2025) - Latest security guidance

## When to Escalate

Escalate to security team or mark as CRITICAL if you find:
- Tokens forwarded to services not in their audience
- Missing signature validation
- Algorithm confusion vulnerabilities (accepting `none` or user-controlled algorithm)
- Tokens containing sensitive data logged or exposed in URLs
- No audience or issuer validation
- Token exchange not used in multi-service architectures
