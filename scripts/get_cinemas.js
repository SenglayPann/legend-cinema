/**
 * Node.js script to fetch all cinemas from Firestore and save them into cinemas.json
 *
 * Usage:
 * node get_cinemas.js /path/to/serviceAccountKey.json
 */

const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

function loadServiceAccount() {
  const argPath = process.argv[2];
  if (argPath) return argPath;
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) return process.env.GOOGLE_APPLICATION_CREDENTIALS;
  console.error("❌ Error: service account JSON path not provided.");
  process.exit(1);
}

const serviceAccountPath = loadServiceAccount();
if (!fs.existsSync(serviceAccountPath)) {
  console.error(`❌ Service account file not found at: ${serviceAccountPath}`);
  process.exit(1);
}

const serviceAccount = require(path.resolve(serviceAccountPath));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const collection = db.collection("cinemas");

async function run() {
  console.log("📥 Fetching cinemas from Firestore...");

  try {
    const snapshot = await collection.get();
    const cinemas = [];

    snapshot.forEach((doc) => {
      const data = doc.data();
      cinemas.push({
        id: doc.id,
        name: data.name,
        address: data.address,
        city: data.city,
        openHour: data.openHour,
        closeHour: data.closeHour,
        facilities: data.facilities || [],
        hallCount: data.hallCount || 0,
        imageUrl: data.imageUrl,
        location: {
          lat: data.location._latitude,
          lng: data.location._longitude,
        },
      });
    });

    const filePath = path.resolve(__dirname, "data/cinemas.json");
    fs.writeFileSync(filePath, JSON.stringify(cinemas, null, 2));

    console.log(`✅ cinemas.json has been created at: ${filePath}`);
    console.log(`📦 Total cinemas exported: ${cinemas.length}`);

    process.exit(0);
  } catch (error) {
    console.error("❌ Failed to retrieve cinemas:", error);
    process.exit(1);
  }
}

run();
