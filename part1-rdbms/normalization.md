# **##Anomaly Analysis**

### **##Insert Anomaly**

**Example from dataset:**  
Suppose the company stocks a new product — say, "Wireless Keyboard" (P009) at ₹1,500 — but it has not been ordered yet. There is no way to insert this product's information (`product\\\_id`, `product\\\_name`, `category`, `unit\\\_price`) into `orders\\\_flat.csv` without also fabricating a fake order (`order\\\_id`, `customer\\\_id`, etc.). The table has no mechanism to record product data independently of an order.
---

##### Similarly, if a new sales representative joins the company (e.g., SR04 — Meena Pillai), their details cannot be stored until they handle at least one order.

##### **Columns affected:** `product\\\_id`, `product\\\_name`, `category`, `unit\\\_price`, `sales\\\_rep\\\_id`, `sales\\\_rep\\\_name`, `sales\\\_rep\\\_email`, `office\\\_address`

##### \---

### **##Update Anomaly**

**Example from dataset:**  
Sales representative Deepak Joshi (`sales\\\_rep\\\_id = SR01`) has his `office\\\_address` recorded as `"Mumbai HQ, Nariman Point, Mumbai - 400021"` in most rows. However, in 15 rows (e.g., `ORD1180`, `ORD1173`, `ORD1170`, `ORD1183`, `ORD1181`, `ORD1184`, `ORD1172`, `ORD1182`, `ORD1177`, `ORD1178`, `ORD1174`, `ORD1179`, `ORD1171`, `ORD1175`, `ORD1176`), the same address is stored as `"Mumbai HQ, Nariman Pt, Mumbai - 400021"` — an abbreviated and inconsistent variant.
---

##### This is a direct consequence of the update anomaly: because `office\\\_address` is repeated across every order row for a sales rep, even a minor edit (or a typo during a past update) propagates inconsistency across the table. If the office relocates, all \~80 rows for SR01 must be updated — and any missed row leaves corrupted data.

##### **Columns affected:** `sales\\\_rep\\\_id`, `office\\\_address` (rows: ORD1180, ORD1173, ORD1170, ORD1183, ORD1181, ORD1184, ORD1172, ORD1182, ORD1177, ORD1178, ORD1174, ORD1179, ORD1171, ORD1175, ORD1176)

##### \---

### **##Delete Anomaly**

**Example from dataset:**  
Customer `C007` (Arjun Nair, arjun@gmail.com, Bangalore) appears in 25 rows. If, hypothetically, all orders placed by Arjun Nair were cancelled and deleted from the table, all knowledge of Arjun Nair as a customer — his name, email address, and city — would be permanently lost. There is no separate customer registry; customer data only exists embedded within order rows.
---

##### Concretely, if orders `ORD1098`, `ORD1093`, `ORD1163`, `ORD1148`, `ORD1049` (and all others for C007) were deleted, the company would lose the fact that C007 = Arjun Nair from Bangalore entirely.

##### **Columns affected:** `customer\\\_id`, `customer\\\_name`, `customer\\\_email`, `customer\\\_city` (rows: all rows where `customer\\\_id = C007`)

##### \---

### **##Normalization Justification**

##### A manager might reasonably argue that keeping all data in one table — `orders\\\_flat.csv` — is simpler: no joins, no foreign key constraints, and a developer can query everything with a plain `SELECT \\\*`. At first glance this seems pragmatic. But the dataset itself disproves this position clearly.

##### Consider the `office\\\_address` column for sales rep Deepak Joshi (SR01). His address appears in over 80 rows. In 15 of those rows, the address is recorded as "Nariman Pt" while all others say "Nariman Point." This is not a hypothetical risk — it is an actual inconsistency already present in the data, introduced because the same fact was stored redundantly. In a normalized schema, SR01's address would exist in exactly one row of a `SalesReps` table. Changing it would require updating one cell. In the flat file, you must hunt down and update 80+ rows, and as the data shows, that process has already failed.

##### The same logic applies to products. If a new product like "Wireless Keyboard" needs to be added to the catalogue before any orders come in, the flat file offers no home for it. You either invent a fake order or lose the data entirely. A normalized `Products` table has no such constraint.

##### The delete anomaly makes the argument even clearer: deleting Arjun Nair's orders erases Arjun Nair as a customer. It is a silent, irreversible data loss that no amount of careful querying can protect against.

##### Normalization is not over-engineering. It is the minimum structural discipline required to ensure that facts about the real world (a customer's email, a product's price, etc.) are stored exactly once and remain trustworthy. The flat file approach trades short-term convenience for long-term inconsistency, loss, and maintenance overhead.

