<div align="center">
  <h1>Hybrid Search RAG Chat</h1>
</div>

---

<table width="100%">
  <tr>
    <td width="30%" valign="top">
      <div align="center">
        <img src="https://github.com/user-attachments/assets/4756a23b-e3c3-457c-a589-759c837ac7ef" alt="rag-app-demo" width="280">
      </div>
    </td>
    <td width="70%" valign="top">
      <p>
        A full-stack AI chat application that lets you upload documents and ask questions about them. It uses <strong>Hybrid Retrieval-Augmented Generation (RAG)</strong> to find the most relevant information from your files before generating answers.
      </p>
      <h3>✨ Key Features</h3>
      <ul>
        <li><strong>Document Processing:</strong> Upload PDF, or MD files</li>
        <li><strong>Hybrid Search:</strong> Combines Vector Search (for meaning) and Keyword Search (for keyword matches) using Reciprocal Rank Fusion (RRF) for highly accurate document retrieval.</li>
        <li><strong>Source Tracking:</strong> Automatically cites the exact files and similarity scores used to generate answers.</li>
      </ul>
      <h3>🛠️ Tech Stack</h3>
      <ul>
        <li><strong>Frontend:</strong> Flutter</li>
        <li><strong>Backend:</strong> Python, FastAPI</li>
        <li><strong>Database:</strong> PostgreSQL (with <code>pgvector</code> and HNSW indexing)</li>
        <li><strong>AI & Machine Learning:</strong> Groq API (Llama 3.1 8B), custom recursive text chunker, and <code>nomic-embed-text</code> embedding models.</li>
      </ul>
    </td>
  </tr>
</table>
