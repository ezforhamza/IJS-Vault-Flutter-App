# Backend API Update Instructions

## Overview

This document outlines the required changes to the **Shared Vault API** (`/vault/shared`) to match the structure of the existing **Vault API** (`/vault/items`). The frontend has already been updated to support these changes and will work automatically once the backend is updated.

---

## Current State

### Vault API (Working) - `/vault/items`

**Request:**
```
GET /vault/items?page=1&limit=20&sortBy=name&sortOrder=asc
```

**Response:**
```json
{
  "success": true,
  "message": "Items retrieved successfully",
  "data": {
    "items": [
      {
        "_id": "...",
        "name": "Folder Name",
        "type": "folder",
        "description": "...",
        "parentId": null,
        "isLocked": false,
        "createdAt": "2025-01-01T00:00:00.000Z",
        "updatedAt": "2025-01-01T00:00:00.000Z"
      }
    ],
    "pagination": {
      "totalCount": 71,
      "totalPages": 4,
      "page": 1,
      "limit": 20,
      "hasNextPage": true,
      "hasPrevPage": false
    }
  }
}
```

### Shared Vault API (Current) - `/vault/shared`

**Request:**
```
GET /vault/shared
```

**Response (Current - No pagination):**
```json
{
  "success": true,
  "message": "Shared items retrieved successfully",
  "data": {
    "items": [...]
  }
}
```

---

## Required Changes

### 1. Add Pagination Support

Update the `/vault/shared` endpoint to accept pagination parameters and return pagination metadata.

**New Request Format:**
```
GET /vault/shared?page=1&limit=20&sortBy=name&sortOrder=asc
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 1 | Page number (1-indexed) |
| `limit` | integer | 20 | Number of items per page |
| `sortBy` | string | "name" | Field to sort by |
| `sortOrder` | string | "asc" | Sort order ("asc" or "desc") |
| `type` | string | null | Filter by item type |
| `fileType` | string | null | Filter by file type |

**New Response Format:**
```json
{
  "success": true,
  "message": "Shared items retrieved successfully",
  "data": {
    "items": [...],
    "pagination": {
      "totalCount": 50,
      "totalPages": 3,
      "page": 1,
      "limit": 20,
      "hasNextPage": true,
      "hasPrevPage": false
    }
  }
}
```

### 2. Add Filter Support

Support the same filters as the main Vault API:

#### Filter: `type`
Filter items by their type.

| Value | Description |
|-------|-------------|
| `folder` | Show only folders |
| `file` | Show only files |
| _(empty)_ | Show all items |

**Example:**
```
GET /vault/shared?type=folder
```

#### Filter: `fileType`
Filter files by their category (only applies when `type=file` or when showing all items).

| Value | Description |
|-------|-------------|
| `document` | Documents (PDF, DOC, TXT, etc.) |
| `media` | Media files (images, videos, audio) |
| `note` | Notes |
| _(empty)_ | Show all file types |

**Example:**
```
GET /vault/shared?type=file&fileType=media
```

### 3. Add Sorting Support

Support sorting by the following fields:

| `sortBy` Value | Description |
|----------------|-------------|
| `name` | Sort alphabetically by name |
| `createdAt` | Sort by creation date |
| `updatedAt` | Sort by last modified date |
| `size` | Sort by file size |

| `sortOrder` Value | Description |
|-------------------|-------------|
| `asc` | Ascending order (A-Z, oldest first, smallest first) |
| `desc` | Descending order (Z-A, newest first, largest first) |

**Example:**
```
GET /vault/shared?sortBy=createdAt&sortOrder=desc
```

---

## Pagination Response Object

The `pagination` object should contain:

```typescript
interface Pagination {
  totalCount: number;   // Total number of items matching the query
  totalPages: number;   // Total number of pages (ceil(totalCount / limit))
  page: number;         // Current page number
  limit: number;        // Items per page
  hasNextPage: boolean; // true if page < totalPages
  hasPrevPage: boolean; // true if page > 1
}
```

---

## Example API Calls

### Get first page with default settings
```
GET /vault/shared?page=1&limit=20
```

### Get folders only, sorted by name
```
GET /vault/shared?page=1&limit=20&type=folder&sortBy=name&sortOrder=asc
```

### Get media files, sorted by newest first
```
GET /vault/shared?page=1&limit=20&type=file&fileType=media&sortBy=createdAt&sortOrder=desc
```

### Get all items sorted by size (largest first)
```
GET /vault/shared?page=1&limit=20&sortBy=size&sortOrder=desc
```

---

## Backward Compatibility

The frontend has been implemented to handle **both** the old and new response formats:

- **Old format** (no pagination): Frontend will display all items without infinite scroll
- **New format** (with pagination): Frontend will enable infinite scroll and filters

This means you can deploy the backend changes without coordinating with frontend deployment.

---

## Testing Checklist

- [ ] `/vault/shared` returns pagination object in response
- [ ] `page` parameter works correctly
- [ ] `limit` parameter works correctly
- [ ] `type=folder` returns only folders
- [ ] `type=file` returns only files
- [ ] `fileType=document` returns only documents
- [ ] `fileType=media` returns only media files
- [ ] `fileType=note` returns only notes
- [ ] `sortBy=name` sorts alphabetically
- [ ] `sortBy=createdAt` sorts by creation date
- [ ] `sortBy=updatedAt` sorts by modification date
- [ ] `sortBy=size` sorts by file size
- [ ] `sortOrder=asc` sorts in ascending order
- [ ] `sortOrder=desc` sorts in descending order
- [ ] `hasNextPage` is `true` when more pages exist
- [ ] `hasNextPage` is `false` on last page
- [ ] `hasPrevPage` is `false` on first page
- [ ] `hasPrevPage` is `true` on subsequent pages

---

## Questions?

Contact the mobile team if you have any questions about the expected API format or behavior.
