# Awan Authentication API Contract

This document outlines the Authentication API contract for the Awan mobile applications (iOS/Android). 

The authentication flow is **passwordless (OTP-only)**. All requests and responses use `camelCase` for JSON properties.


> [!NOTE] Development Email Server
> Currently in the development mode, we are using a containerized development server. Emails are not sent to the actual email vendors, they are sent to our email server and you can retrieve the OTP from it.
> Just open `localhost:8025` from the browser and you can find the sent email messages.

## Standard Error Format
All errors (4xx and 5xx) follow a consistent envelope:

```json
{
  "message": "Human readable message describing what went wrong",
  "statusCode": 400,
  "errorCode": "ERROR_CODE_CONSTANT",
  "info": {
     // Optional metadata, e.g. {"remainingAttempts": 2} or validation errors array
  },
  "timestamp": "2024-05-18T12:00:00.000Z"
}
```


**Base URL**: `/api/v1/auth`

---

## 1. Request OTP
Generates a 6-digit OTP and sends it to the user's email. Rate-limited to 3 requests per 10 minutes per email.

**Endpoint:** `POST /api/v1/auth/otp/request`  
**Auth Required:** No

### Request Body
```json
{
  "email": "user@example.com"
}
```

### Success Response (200 OK)
```json
{
  "expiresInSeconds": 300,
  "resendAvailableInSeconds": 30
}
```

### Possible Errors
- **429 Too Many Requests** (`OTP_RATE_LIMIT_EXCEEDED`): Rate limit hit. Check `info.retryAfterSeconds`.

**Example:**
```json
{
    "message": "Too many OTP requests. Please try again later.",
    "statusCode": 429,
    "errorCode": "OTP_RATE_LIMIT_EXCEEDED",
    "info": {
        "retryAfterSeconds": 600
    },
    "timestamp": "2026-07-15T20:22:37.408937602"
}
```

- **422 Unprocessable Entity** (`VALIDATION_ERROR`): Invalid email format.

**Example:**
```json
{
    "message": "Validation failed",
    "statusCode": 422,
    "errorCode": "VALIDATION_ERROR",
    "info": {
        "errors": [
            {
                "field": "email",
                "message": "must be a well-formed email address",
                "rejectedValue": "abdoemad552"
            }
        ]
    },
    "timestamp": "2026-07-15T20:29:45.598115891"
}
```

---

## 2. Verify OTP
Verifies the 6-digit code. On success, returns access and refresh tokens. If it's a first-time login, `isNewUser` will be `true`.

**Endpoint:** `POST /api/v1/auth/otp/verify`  
**Auth Required:** No

### Request Body
```json
{
  "email": "user@example.com",
  "code": "123456",
  "deviceId": "123e4567-e89b-12d3-a456-426614174000"
}
```
*(Note: `deviceId` must be a valid UUID identifying the physical device or installation).*

### Success Response (200 OK)
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR...",
  "accessTokenExpiresIn": 900,
  "refreshToken": "8f3a8b2c-...",
  "user": {
    "id": "uuid-here",
    "email": "user@example.com",
    "isNew": true
  }
}
```

### Possible Errors
- **400 Bad Request** (`OTP_INVALID_CODE`): Wrong code. Check `info.remainingAttempts`.

First attempt:
```json
{
    "message": "Invalid OTP code.",
    "statusCode": 400,
    "errorCode": "OTP_INVALID_CODE",
    "info": {
        "remainingAttempts": 4
    },
    "timestamp": "2026-07-15T20:56:27.039484095"
}
```

Second attempt:
```json
{
    "message": "Invalid OTP code.",
    "statusCode": 400,
    "errorCode": "OTP_INVALID_CODE",
    "info": {
        "remainingAttempts": 3
    },
    "timestamp": "2026-07-16T08:52:51.308934302"
}
```

And so on till there are no remaining attempts.

- **400 Bad Request** (`OTP_EXPIRED_OR_NOT_FOUND`): OTP has expired or was never requested.

```json
{
    "message": "No valid OTP found for this email. Please request a new one.",
    "statusCode": 400,
    "errorCode": "OTP_EXPIRED_OR_NOT_FOUND",
    "info": {},
    "timestamp": "2026-07-15T20:40:37.438158089"
}
```

- **400 Bad Request** (`OTP_LOCKED`): Account locked after 5 failed attempts. A new OTP must be requested.

```json
{
    "message": "Too many failed attempts. This OTP is now locked. Please request a new one.",
    "statusCode": 400,
    "errorCode": "OTP_LOCKED",
    "info": {},
    "timestamp": "2026-07-16T08:51:55.730669306"
}
```

- **422 Unprocessable Content (`VALIDATION_ERROR`): Code isn't exactly 6 digits, or missing fields.

**Example:** Sent a code with non 6 digits value:
```json
{
    "message": "Validation failed",
    "statusCode": 422,
    "errorCode": "VALIDATION_ERROR",
    "info": {
        "errors": [
            {
                "field": "code",
                "message": "must match \"\\d{6}\"",
                "rejectedValue": "00000"
            }
        ]
    },
    "timestamp": "2026-07-15T20:39:25.488925594"
}
```


---

## 3. Refresh Token
Exchanges a valid refresh token for a new access token and a **new refresh token** (token rotation).

**Endpoint:** `POST /api/v1/auth/refresh`  
**Auth Required:** No

### Request Body
```json
{
  "refreshToken": "537fd6dd-c284-4b38-b78f-a6462e7d5508",
  "deviceId": "b4e7dafe-a2dc-4c4e-94b2-d8e1fe4a3983"
}
```

### Success Response (200 OK)
```json
{
    "accessToken": "...",
    "accessTokenExpiresIn": 900,
    "refreshToken": "b82c16d4-3905-45f5-ad38-de8a81801283"
}
```

### Possible Errors
- **401 Unauthorized** (`REFRESH_TOKEN_INVALID`): Token doesn't exist or device ID doesn't match.

```json
{
    "message": "Invalid or expired refresh token.",
    "statusCode": 401,
    "errorCode": "REFRESH_TOKEN_INVALID",
    "info": {},
    "timestamp": "2026-07-15T21:05:02.487734288"
}
```

- **401 Unauthorized** (`REFRESH_TOKEN_EXPIRED`): Token is older than 30 days. User must log in again.
- **401 Unauthorized** (`REFRESH_TOKEN_REUSE_DETECTED`): **Security Alert!** A previously used/revoked refresh token was presented. All active sessions for this user are instantly revoked. **User must log in again**.

```json
{
    "message": "Refresh token reuse detected. All sessions have been revoked.",
    "statusCode": 401,
    "errorCode": "REFRESH_TOKEN_REUSE_DETECTED",
    "info": {},
    "timestamp": "2026-07-15T21:02:08.553932268"
}
```

---

## 4. Logout
Revokes the current device's refresh token. 

**Endpoint:** `POST /logout`  
**Auth Required:** Yes (`Authorization: Bearer <accessToken>`)

### Request Body
```json
{
  "deviceId": "123e4567-e89b-12d3-a456-426614174000"
}
```

### Success Response
**204 No Content** (Empty body)

### Possible errors
- **401 Unauthorized** (`REFRESH_TOKEN_INVALID`): Token doesn't exist or device ID doesn't match.

