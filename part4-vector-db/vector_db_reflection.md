## Vector DB Use Case

A traditional keyword-based database search would not suffice for this use case, and the gap is fundamental rather than a matter of tuning.

Keyword search works by matching exact or stemmed terms. If a lawyer asks "What are the termination clauses?", a keyword search would scan 500 pages for occurrences of "termination" or "clause". This fails in two critical ways. First, legal contracts use varied language: the same concept might be expressed as "conditions for dissolution", "exit provisions", "grounds for ending the agreement", or "circumstances under which either party may withdraw" — none of which contain the word "termination". A keyword search misses all of these. Second, keyword results are ranked by term frequency (TF-IDF), not by semantic relevance, so a page that says "There is no termination fee" ranks highly even though it does not describe a termination clause.

A vector database solves both problems by operating on meaning rather than text. The system would first chunk the 500-page contract into paragraphs or sections, then convert each chunk into a high-dimensional embedding vector using a model like `sentence-transformers/all-MiniLM-L6-v2`. These vectors encode semantic content: sentences with similar meaning cluster nearby in vector space, regardless of the specific words used.

When a lawyer submits the plain-English query "What are the termination clauses?", the query is also embedded into the same vector space, and the database performs a nearest-neighbour search — retrieving the contract sections whose vectors are most similar to the query vector. This correctly surfaces "exit provisions" and "grounds for dissolution" even with zero keyword overlap.

The role of the vector database (e.g., Pinecone, Weaviate, or pgvector) is to store these embeddings and serve approximate nearest-neighbour queries at low latency. Combined with a large language model for answer generation, this forms a Retrieval-Augmented Generation (RAG) pipeline — the ideal architecture for legal document question-answering.
