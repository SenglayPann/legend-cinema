/**
 * Node.js script to migrate FNB (Food & Beverage) combos to Firestore.
 *
 * Usage:
 * 1. node migrate_fnb.js /path/to/serviceAccountKey.json
 */

const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");

// Load service account
function loadServiceAccount() {
  const argPath = process.argv[2];
  if (argPath) return argPath;

  if (process.env.GOOGLE_APPLICATION_CREDENTIALS)
    return process.env.GOOGLE_APPLICATION_CREDENTIALS;

  console.error(
    "Error: service account JSON path not provided. Pass it as an argument or set GOOGLE_APPLICATION_CREDENTIALS."
  );
  process.exit(1);
}

const serviceAccountPath = loadServiceAccount();
if (!fs.existsSync(serviceAccountPath)) {
  console.error(`Service account file not found at ${serviceAccountPath}`);
  process.exit(1);
}

const serviceAccount = require(path.resolve(serviceAccountPath));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const collection = db.collection("fnb");

// ------------------------
// FNB Combo Data
// ------------------------

const fnbList = [
  {
    name: "Combo 1",
    price: 3.50,
    imageUrl: "https://drive.usercontent.google.com/download?id=1MMY6RMlg9DEuFQKj2DSZ359B5Vzez5qy"
  },
  {
    name: "Combo 2",
    price: 4.00,
    imageUrl: "https://drive.usercontent.google.com/download?id=1-SpKGII3ipZVoD84a1r2ios-VBW0s6UN"
  },
  {
    name: "Combo 3",
    price: 4.50,
    imageUrl: "https://drive.usercontent.google.com/download?id=1Oqf-07Iui297l-diBf9unwcGaaaj-V98"
  },
  {
    name: "Combo 4",
    price: 5.00,
    imageUrl: "https://drive.usercontent.google.com/download?id=1iFfT61oi2v1JD6THbgSA2yEXb1rqwCHL"
  },
  {
    name: "Combo 5",
    price: 5.50,
    imageUrl: "https://drive.usercontent.google.com/download?id=1dS3l3d5key7gNQEeY6RX1PDCgInh1vot"
  },
  {
    name: "Combo 6",
    price: 6.00,
    imageUrl: "https://drive.usercontent.google.com/download?id=1DGgEB7xgsitB8NpaGw2t02IGgJHkDcNE"
  },
  {
    name: "Combo 7",
    price: 6.50,
    imageUrl: "https://drive.usercontent.google.com/download?id=1w1TeQ-2EqCcPJMOClmkDJ3BE3zvF0XeS"
  },
];

// ------------------------
// Migration Function
// ------------------------


async function run() {
  console.log("🚀 Starting FNB migration...");

  for (const item of fnbList) {
    try {
      await collection.add(item);
      console.log(`✅ Uploaded: ${item.name}`);
    } catch (err) {
      console.error(`❌ Failed to upload ${item.name}:`, err);
    }
  }

  console.log("🎉 FNB Migration complete!");
  process.exit(0);
}

run().catch((err) => {
  console.error("Migration failed:", err);
  process.exit(1);
});