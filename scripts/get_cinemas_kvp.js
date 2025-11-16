/**
 * Node.js script to fetch cinema ID–Name key-value pairs
 * and save them into cinema_pairs.json
 *
 * Usage:
 * node get_cinema_pairs.js /path/to/serviceAccountKey.json
 */

const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

// Load Google service account path
function loadServiceAccount() {
  const argPath = process.argv[2];
  if (argPath) return argPath;

  if (process.env.GOOGLE_APPLICATION_CREDENTIALS)
    return process.env.GOOGLE_APPLICATION_CREDENTIALS;

  console.error("❌ Error: service account JSON path not provided.");
  process.exit(1);
}

const serviceAccountPath = loadServiceAccount();
if (!fs.existsSync(serviceAccountPath)) {
  console.error(`❌ Service account file not found: ${serviceAccountPath}`);
  process.exit(1);
}

const serviceAccount = require(path.resolve(serviceAccountPath));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const collection = db.collection("cinemas");

async function run() {
  console.log("📥 Fetching cinema ID–Name pairs...");

  try {
    const snapshot = await collection.get();
    const pairs = [];

    snapshot.forEach((doc) => {
      const data = doc.data();
      const pair = {
        id: doc.id, cinema: data.name || '',
      }

      pairs.push(pair);
    });

    const outputPath = path.resolve(__dirname, "data/cinema_pairs.json");
    fs.writeFileSync(outputPath, JSON.stringify(pairs, null, 2));

    console.log(`✅ data/cinema_pairs.json created at: ${outputPath}`);
    console.log(`📦 Total entries: ${Object.keys(pairs).length}`);

    process.exit(0);
  } catch (error) {
    console.error("❌ Failed retrieving key-value pairs:", error);
    process.exit(1);
  }
}

run();
