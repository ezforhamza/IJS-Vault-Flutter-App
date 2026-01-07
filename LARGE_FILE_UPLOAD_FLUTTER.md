# Large File Upload (Resumable Upload) - Flutter Implementation Guide

## Overview

For files **> 100MB**, use the resumable (multipart) upload flow. This splits the file into 5MB chunks and uploads them in parallel, allowing for resume on failure.

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/vault/resumable/initiate` | POST | Start upload session |
| `/v1/vault/resumable/part-urls` | POST | Get presigned URLs for parts |
| `/v1/vault/resumable/progress` | GET | Check uploaded parts (for resume) |
| `/v1/vault/resumable/complete` | POST | Finalize upload |
| `/v1/vault/resumable/abort` | POST | Cancel upload |

## Upload Flow

```
1. INITIATE → Get uploadId & key
2. GET PART URLs → Get presigned URLs for each chunk
3. UPLOAD PARTS → PUT chunks directly to DigitalOcean Spaces
4. CHECK PROGRESS → Get real ETags from server
5. COMPLETE → Finalize with ETags
```

---

## Step 1: Initiate Upload

```http
POST /v1/vault/resumable/initiate
Authorization: Bearer {token}
Content-Type: application/json

{
  "filename": "video.mp4",
  "contentType": "video/mp4",
  "size": 157286400,
  "parentId": "folder_id_or_null",
  "description": "optional"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "uploadId": "2~abc123...",
    "key": "vault/{userId}/{timestamp}-video.mp4",
    "partSize": 5242880,
    "totalParts": 30
  }
}
```

**Store these values** - needed for all subsequent calls.

---

## Step 2: Get Part Upload URLs

Request presigned URLs in batches (max 100 per request):

```http
POST /v1/vault/resumable/part-urls
Authorization: Bearer {token}
Content-Type: application/json

{
  "uploadId": "2~abc123...",
  "key": "vault/{userId}/{timestamp}-video.mp4",
  "partNumbers": [1, 2, 3, 4, 5]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "parts": [
      {
        "partNumber": 1,
        "uploadUrl": "https://ijs-vault.sfo3.digitaloceanspaces.com/...?signature=...",
        "expiresIn": 3600
      }
    ]
  }
}
```

---

## Step 3: Upload Parts

Upload each chunk directly to the presigned URL:

```http
PUT {uploadUrl}
Content-Type: application/octet-stream

[binary chunk data - 5MB]
```

**Important:**
- Part size: **5MB** (5,242,880 bytes) except last part
- Last part can be smaller
- Upload in parallel (3-5 concurrent) for speed
- **DO NOT** try to read the `ETag` header from response (CORS blocks it)

---

## Step 4: Check Progress (Get Real ETags)

**Critical:** Due to CORS restrictions, you cannot read the `ETag` header from the upload response. Instead, call the progress API to get the real ETags:

```http
GET /v1/vault/resumable/progress?uploadId={uploadId}&key={key}
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "uploadedParts": [
      { "partNumber": 1, "etag": "\"abc123...\"", "size": 5242880 },
      { "partNumber": 2, "etag": "\"def456...\"", "size": 5242880 }
    ],
    "uploadedPartsCount": 2,
    "totalUploadedBytes": 10485760
  }
}
```

Use these ETags for the complete step.

---

## Step 5: Complete Upload

```http
POST /v1/vault/resumable/complete
Authorization: Bearer {token}
Content-Type: application/json

{
  "uploadId": "2~abc123...",
  "key": "vault/{userId}/{timestamp}-video.mp4",
  "parts": [
    { "partNumber": 1, "etag": "\"abc123...\"" },
    { "partNumber": 2, "etag": "\"def456...\"" }
  ],
  "filename": "video.mp4",
  "contentType": "video/mp4",
  "size": 157286400,
  "parentId": "folder_id_or_null"
}
```

**Important:**
- `parts` must be sorted by `partNumber` ascending
- `etag` must include quotes (e.g., `"\"abc123...\""`)

**Response:**
```json
{
  "success": true,
  "data": {
    "item": {
      "id": "item_id",
      "name": "video.mp4",
      "type": "file",
      "size": 157286400
    }
  },
  "message": "File uploaded successfully"
}
```

---

## Abort Upload (Optional)

Cancel an in-progress upload:

```http
POST /v1/vault/resumable/abort
Authorization: Bearer {token}
Content-Type: application/json

{
  "uploadId": "2~abc123...",
  "key": "vault/{userId}/{timestamp}-video.mp4"
}
```

---

## Flutter Implementation Tips

### 1. Chunking the File
```dart
final file = File(path);
final fileSize = await file.length();
final partSize = 5242880; // 5MB
final totalParts = (fileSize / partSize).ceil();

for (int i = 0; i < totalParts; i++) {
  final start = i * partSize;
  final end = min(start + partSize, fileSize);
  final chunk = await file.openRead(start, end).toList();
  // Upload chunk...
}
```

### 2. Parallel Uploads
```dart
// Upload 3-5 parts concurrently
await Future.wait(
  partUrls.take(5).map((part) => uploadPart(part)),
);
```

### 3. Resume Support
```dart
// On app restart, check progress
final progress = await checkProgress(uploadId, key);
final uploadedPartNumbers = progress.uploadedParts.map((p) => p.partNumber).toSet();

// Only upload missing parts
final missingParts = allPartNumbers.where((n) => !uploadedPartNumbers.contains(n));
```

### 4. Error Handling
- **Network error during part upload**: Retry that part
- **404 on progress/complete**: Upload session expired, restart
- **409 on complete**: Already completing, wait and retry

---

## Quick Reference

| Parameter | Value |
|-----------|-------|
| Part Size | 5,242,880 bytes (5MB) |
| Max Parts per URL Request | 100 |
| URL Expiry | 1 hour |
| Recommended Concurrent Uploads | 3-5 |

---

## Error Codes

| Code | Meaning |
|------|---------|
| 400 | Invalid request parameters |
| 404 | Upload session not found/expired |
| 409 | Completion already in progress |
| 500 | Server error |
