/**
 * Node.js script to migrate offer data to Firestore using firebase-admin.
 *
 * Usage:
 * 1. Create a Firebase service account JSON in the Firebase Console (Project Settings > Service accounts).
 * 2. Download the JSON and either set the GOOGLE_APPLICATION_CREDENTIALS env var to its path
 *    or pass the path as the first argument: node migrate_offers.js /path/to/serviceAccountKey.json
 * 3. npm install
 * 4. npm run migrate
 */

const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");

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
const collection = db.collection("offers");

const offers = [
  {
    imageUrl:
      "https://lh3.googleusercontent.com/d/1LWjgVwkLrjzJ0qjHwRXBEmS60L3_uIQc",
    description: "Chocolate Popcorn Combo – New Flavor!",
  },
  {
    imageUrl:
      "https://lh3.googleusercontent.com/d/1_CFDFIEmdDw8dhUC7tGUNxUoiOUkYC8d",
    description: "Unlock Incredible Perks with Legend Membership Card!",
  },
  {
    imageUrl:
      "https://lh3.googleusercontent.com/d/1iBb3YOxLLZXzyX60Ka514KReYHDTzZeD",
    description:
      "Become a Legend Diamond Member  Unlock a world of exclusivity and premiumprivileges by becoming a Legend Diamond Member",
  },
  {
    imageUrl:
      "https://lh3.googleusercontent.com/d/1d0olAMXLZE8Wlhu0Hr7wWg3DixUOl5-f",
    description: "Let's enjoy the special price from Legend Toul Kork Cinema!",
  },
  {
    imageUrl:
      "https://lh3.googleusercontent.com/d/1w8XokFqASBsOF4cZ3jepUPQ-KpyZ-CMB",
    description:
      "Special price for students and senior citizen. Applicable on week days, weekends and public Holiday",
  },
];

async function run() {
  console.log("🚀 Starting offers migration...");
  for (const offer of offers) {
    try {
      await collection.add(offer);
      console.log(`✅ Uploaded: ${offer.description}`);
    } catch (e) {
      console.error(`❌ Failed to upload ${offer.description}:`, e);
    }
  }
  console.log("🎉 Migration complete!");
  process.exit(0);
}

run().catch((err) => {
  console.error("Migration failed:", err);
  process.exit(1);
});
