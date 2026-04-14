<div align="center">
  <h1>Hybrid Search RAG Chat</h1>
</div>

---

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Web Interface (Next.js)</b></td>
      <td align="center"><b>Mobile Interface (Flutter)</b></td>
    </tr>
    <tr>
      <td valign="bottom">
        <img src="https://github.com/user-attachments/assets/5717a489-4b29-40f3-b36b-ab52d9bdff21" width="620" alt="Web Demo">
      </td>
      <td valign="bottom">
        <img src="https://github.com/user-attachments/assets/4756a23b-e3c3-457c-a589-759c837ac7ef" width="180" alt="Mobile Demo">
      </td>
    </tr>
  </table>
</div>

---

### 📝 Description
A full-stack AI chat application that lets you upload documents and ask questions about them. It uses **Hybrid Retrieval-Augmented Generation (RAG)** to find the most relevant information from your files before generating answers.

### ✨ Key Features
* **Document Processing:** Upload PDF, or MD files.
* **Hybrid Search:** Combines Vector Search (for meaning) and Keyword Search (for keyword matches) using Reciprocal Rank Fusion (RRF) for highly accurate document retrieval.
* **Source Tracking:** Automatically cites the exact files and similarity scores used to generate answers.

### 🛠️ Tech Stack
* **Frontend:** Next.js (Web) & Flutter (Mobile)
* **Backend:** Python, FastAPI
* **Database:** PostgreSQL (with `pgvector` and HNSW indexing)
* **AI & Machine Learning:** Groq API (Llama 3.1 8B), custom recursive text chunker, and `nomic-embed-text` embedding models.
