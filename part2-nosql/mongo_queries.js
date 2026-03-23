// ============================================================
// Part 2 — MongoDB Operations
// Collection: db.products
// Run in: mongosh or MongoDB Compass Shell
// ============================================================

// OP1: insertMany() — insert all 3 documents from sample_documents.json
db.products.insertMany([
  {
    "_id": "PROD_ELEC_001",
    "category": "Electronics",
    "product_name": "Sony WH-1000XM5 Wireless Headphones",
    "brand": "Sony",
    "sku": "SNY-WH1000XM5-BLK",
    "price": 29990,
    "currency": "INR",
    "in_stock": true,
    "stock_quantity": 45,
    "specifications": {
      "driver_size_mm": 30,
      "frequency_response": "4Hz - 40000Hz",
      "battery_life_hours": 30,
      "charging_time_hours": 3.5,
      "connectivity": ["Bluetooth 5.2", "3.5mm Jack", "USB-C"],
      "noise_cancellation": true,
      "voltage": "5V DC",
      "weight_grams": 250
    },
    "warranty": {
      "duration_months": 12,
      "type": "Manufacturer",
      "covers": ["Manufacturing defects", "Hardware failure"]
    },
    "ratings": { "average": 4.7, "total_reviews": 1283 },
    "tags": ["wireless", "noise-cancelling", "over-ear", "premium"],
    "added_date": "2023-06-15"
  },
  {
    "_id": "PROD_CLTH_001",
    "category": "Clothing",
    "product_name": "Men's Slim Fit Formal Shirt",
    "brand": "Arrow",
    "sku": "ARW-SHIRT-BLU-L",
    "price": 1299,
    "currency": "INR",
    "in_stock": true,
    "stock_quantity": 120,
    "specifications": {
      "fabric": "60% Cotton, 40% Polyester",
      "fit_type": "Slim Fit",
      "collar_type": "Spread Collar",
      "sleeve": "Full Sleeve",
      "care_instructions": ["Machine wash cold", "Do not bleach", "Tumble dry low"],
      "occasion": ["Formal", "Business Casual"]
    },
    "sizes_available": [
      { "size": "S", "chest_cm": 96, "stock": 25 },
      { "size": "M", "chest_cm": 101, "stock": 40 },
      { "size": "L", "chest_cm": 106, "stock": 35 },
      { "size": "XL", "chest_cm": 111, "stock": 20 }
    ],
    "colors_available": ["Light Blue", "White", "Grey", "Navy"],
    "ratings": { "average": 4.3, "total_reviews": 567 },
    "tags": ["formal", "slim-fit", "cotton-blend", "office-wear"],
    "added_date": "2023-08-01"
  },
  {
    "_id": "PROD_GROC_001",
    "category": "Groceries",
    "product_name": "Aashirvaad Atta Whole Wheat Flour 10kg",
    "brand": "Aashirvaad",
    "sku": "AASH-ATTA-10KG",
    "price": 380,
    "currency": "INR",
    "in_stock": true,
    "stock_quantity": 300,
    "specifications": {
      "weight_kg": 10,
      "grain_type": "Whole Wheat",
      "packaging": "Sealed Plastic Bag",
      "storage": "Store in cool, dry place away from moisture",
      "shelf_life_months": 6
    },
    "expiry_date": new Date("2024-08-31"),
    "manufactured_date": new Date("2024-02-15"),
    "nutritional_info_per_100g": {
      "calories_kcal": 341,
      "protein_g": 11.8,
      "carbohydrates_g": 69.4,
      "dietary_fiber_g": 1.9,
      "fat_g": 1.7,
      "sodium_mg": 2
    },
    "certifications": ["FSSAI Approved", "ISO 22000", "Non-GMO"],
    "allergens": ["Contains Gluten"],
    "ratings": { "average": 4.5, "total_reviews": 4201 },
    "tags": ["whole-wheat", "atta", "staple", "bulk-pack"],
    "added_date": "2024-02-20"
  }
]);

// OP2: find() — retrieve all Electronics products with price > 20000
db.products.find(
  {
    category: "Electronics",
    price: { $gt: 20000 }
  },
  {
    product_name: 1,
    brand: 1,
    price: 1,
    "ratings.average": 1
  }
);

// OP3: find() — retrieve all Groceries expiring before 2025-01-01
db.products.find(
  {
    category: "Groceries",
    expiry_date: { $lt: new Date("2025-01-01") }
  },
  {
    product_name: 1,
    brand: 1,
    expiry_date: 1,
    price: 1
  }
);

// OP4: updateOne() — add a "discount_percent" field to a specific product
// Adds a 10% discount to the Sony Headphones product
db.products.updateOne(
  { _id: "PROD_ELEC_001" },
  {
    $set: {
      discount_percent: 10,
      discounted_price: 26991
    }
  }
);

// OP5: createIndex() — create an index on category field and explain why
// Reason: The `category` field is used in almost every query to filter products
// by type (Electronics, Clothing, Groceries). Without an index, MongoDB performs
// a full collection scan (O(n)) for every such query. A single-field ascending
// index on `category` reduces this to O(log n) lookup time via a B-tree structure,
// dramatically improving read performance as the catalog grows to millions of
// products. This is especially important for OP2 and OP3 queries above.
db.products.createIndex(
  { category: 1 },
  {
    name: "idx_category",
    background: true
  }
);
