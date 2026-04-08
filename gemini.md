# Hybrid RAG System - Flutter Frontend Integration Guide

## Project Overview

This is a **Hybrid RAG (Retrieval-Augmented Generation) System** consisting of a Python FastAPI backend and a Next.js frontend. The system allows users to upload documents, create conversations, and query using AI-powered hybrid search (combining vector similarity search and keyword search).

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER MOBILE APP                       │
│  (You need to build this)                                       │
└────────────────────────────┬────────────────────────────────────┘
                             │ REST API (JSON)
                             │ SSE (Server-Sent Events for streaming)
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     FASTAPI BACKEND (Python)                    │
│  Port: 8000                                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Endpoints:                                               │   │
│  │ - POST /api/ingest          (upload documents)          │   │
│  │ - GET  /api/documents       (list documents)            │   │
│  │ - DELETE /api/documents/{id} (delete document)         │   │
│  │ - POST /api/query           (single query)              │   │
│  │ - POST /api/query/stream    (streaming query)           │   │
│  │ - GET  /api/conversations   (list conversations)        │   │
│  │ - GET  /api/conversations/{id} (get messages)           │   │
│  │ - PUT  /api/conversations/{id} (rename conversation)    │   │
│  │ - DELETE /api/conversations/{id} (delete conversation) │   │
│  └─────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                POSTGRESQL + pgvector (Database)                 │
│  Tables: documents, chunks, conversations, messages             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Backend Configuration

### CORS Configuration
**Current:** Only allows `http://localhost:3000` (Next.js frontend)

**For Flutter:** You must update CORS in `backend/main.py`:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8080", "http://127.0.0.1:8080"],  # Add your Flutter app's origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Base URL
- **Backend URL:** `http://localhost:8000` (or your server IP for production)
- **API Prefix:** `/api` (all endpoints use this prefix)

---

## API Endpoints Reference

### 1. Document Upload
**Endpoint:** `POST /api/ingest`

**Content-Type:** `multipart/form-data`

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| file | File | Yes | PDF, TXT, or MD file (max 10MB) |
| user_id | String | Yes | User identifier |

**Response:**
```json
{
  "message": "File successfully ingested.",
  "document_id": "uuid-string",
  "filename": "document.pdf",
  "chunks_created": 5
}
```

---

### 2. List Documents
**Endpoint:** `GET /api/documents?user_id={user_id}`

**Response:**
```json
{
  "documents": [
    {
      "id": "uuid-string",
      "filename": "document.pdf",
      "file_type": "pdf",
      "file_size_bytes": 1024,
      "uploaded_at": "2024-01-01T12:00:00"
    }
  ]
}
```

---

### 3. Delete Document
**Endpoint:** `DELETE /api/documents/{document_id}?user_id={user_id}`

**Response:**
```json
{
  "message": "Document and all associated chunks successfully deleted."
}
```

---

### 4. Query (Non-Streaming)
**Endpoint:** `POST /api/query`

**Request Body:**
```json
{
  "query": "What is the main topic?",
  "user_id": "user-123",
  "conversation_id": "uuid-string (optional)",
  "top_k": 5,
  "document_ids": ["uuid1", "uuid2"]  // optional - for document selection
}
```

**Response:**
```json
{
  "answer": "The main topic is...",
  "sources": [
    {
      "filename": "doc.pdf",
      "content_preview": "First 200 chars...",
      "score": 0.85,
      "similarity": 0.82
    }
  ],
  "chunks_found": 5
}
```

---

### 5. Query (Streaming)
**Endpoint:** `POST /api/query/stream`

**Request Body:** Same as `/api/query`

**Response:** Server-Sent Events (SSE) stream with events:

```javascript
// 1. Meta event (conversation created)
data: {"type": "meta", "conversation_id": "uuid", "title": "New Chat"}

// 2. Sources event
data: {"type": "sources", "data": [{filename, content_preview, score, similarity}]}

// 3. Token events (streamed answer)
data: {"type": "token", "data": "The "}
data: {"type": "token", "data": "answer "}
data: {"type": "token", "data": "is..."}

// 4. Done event
data: {"type": "done"}
```

**Error event:**
```javascript
data: {"type": "error", "data": "Error message"}
```

---

### 6. List Conversations
**Endpoint:** `GET /api/conversations?user_id={user_id}`

**Response:**
```json
{
  "conversations": [
    {
      "id": "uuid-string",
      "title": "Chat about documents",
      "created_at": "2024-01-01T12:00:00"
    }
  ]
}
```

---

### 7. Get Conversation Messages
**Endpoint:** `GET /api/conversations/{conversation_id}`

**Response:**
```json
{
  "messages": [
    {"role": "user", "content": "What is this?"},
    {"role": "assistant", "content": "It's a document...", "sources": [...]}
  ]
}
```

---

### 8. Update Conversation Title
**Endpoint:** `PUT /api/conversations/{conversation_id}`

**Request Body:**
```json
{
  "title": "New Title"
}
```

**Response:**
```json
{
  "status": "success",
  "id": "uuid-string",
  "title": "New Title"
}
```

---

### 9. Delete Conversation
**Endpoint:** `DELETE /api/conversations/{conversation_id}?user_id={user_id}`

**Response:**
```json
{
  "status": "success",
  "id": "uuid-string"
}
```

---

## Data Models (for Flutter)

### Document
```dart
class Document {
  final String id;
  final String filename;
  final String fileType;
  final int fileSizeBytes;
  final DateTime? uploadedAt;
}
```

### Message
```dart
class Message {
  final String role; // "user" or "assistant"
  final String content;
  final List<Source>? sources;
}
```

### Source
```dart
class Source {
  final String filename;
  final String contentPreview;
  final double score;
  final double similarity;
}
```

### Conversation
```dart
class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
}
```

### QueryRequest
```dart
class QueryRequest {
  final String query;
  final String userId;
  final String? conversationId;
  final int topK;
  final List<String>? documentIds; // For document selection
}
```

---

## Required Flutter Packages

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0           # HTTP client with multipart support
  flutter_bloc: ^8.1.3  # State management
  equatable: ^2.0.5     # Value equality for Bloc
  get_it: ^7.6.7        # Dependency injection
  flutter_secure_storage: ^9.0.0  # Store user_id securely
  intl: ^0.19.0         # Date formatting
  path_provider: ^2.1.2 # File handling
  file_picker: ^6.1.1   # Document selection
```

---

## Implementation Guidelines

### 1. Document Management

- **Upload:** Use Dio's `FormData` to upload files
- **List:** Fetch and display in a ListView with file icons by type
- **Delete:** Show confirmation dialog before delete

### 2. Document Selection (Select/Deselect)

- Maintain a `Set<String>` of selected document IDs in your state
- Pass `document_ids` in QueryRequest to filter search to selected docs
- UI: Checkbox next to each document in the list
- "Select All" / "Deselect All" buttons

### 3. Chat Features

- **Non-streaming:** Use for quick answers
- **Streaming:** Use for better UX - handle SSE events
- Store `conversation_id` to continue conversations
- Display sources below assistant messages (expandable)

### 4. Chat History

- Fetch conversation list on app start
- Store conversation locally for offline access
- Load full message history when opening a conversation

### 5. Answer References (Sources)

- Display sources in an expandable section below AI response
- Show filename, preview text, and relevance score
- Tap to view full source chunk

### 6. User ID Management

- Simple string-based (no authentication)
- Generate UUID on first app launch
- Store securely using flutter_secure_storage
- Pass as query param in all requests

---

## Error Handling

All endpoints may return:
```json
{
  "detail": "Error message"
}
```

Handle these in Flutter:
- 400: Bad request - show user-friendly message
- 413: File too large - show file size limit warning
- 500: Server error - show retry option

---

## Environment Variables (Backend)

The backend uses these (already configured):
- `DB_PASSWORD` - PostgreSQL password
- `GROQ_API_KEY` - Groq API key for LLM
- `OLLAMA_BASE_URL` - Ollama server (default: http://localhost:11434)

---

## Testing the API

Test with curl:
```bash
# Upload document
curl -X POST http://localhost:8000/api/ingest \
  -F "file=@document.pdf" \
  -F "user_id=user123"

# List documents
curl "http://localhost:8000/api/documents?user_id=user123"

# Query
curl -X POST http://localhost:8000/api/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What is this?", "user_id": "user123"}'
```

---

## Summary for AI Code Generation

Use this document to build a complete Flutter mobile app that:

1. **Document Management**
   - Upload PDF, TXT, MD files (max 10MB)
   - List all user documents with metadata
   - Delete documents

2. **Document Selection**
   - Multi-select documents for targeted queries
   - Select all / deselect all functionality

3. **Chat Interface**
   - Send queries to AI with streaming responses
   - Continue conversations with history
   - Create new conversations

4. **Chat History**
   - List all conversations
   - View full message history
   - Rename conversations
   - Delete conversations

5. **Answer References**
   - Display sources with each AI response
   - Show relevance scores
   - Expandable source previews