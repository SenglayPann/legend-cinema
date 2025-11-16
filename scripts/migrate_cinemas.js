/**
 * Node.js script to migrate all Legend Cinema branches to Firestore using firebase-admin.
 *
 * Usage:
 * 1. Create a Firebase service account JSON in the Firebase Console (Project Settings > Service accounts).
 * 2. Download the JSON and either set the GOOGLE_APPLICATION_CREDENTIALS env var to its path
 *    or pass the path as the first argument: node migrate_cinemas_all.js /path/to/serviceAccountKey.json
 * 3. npm install
 * 4. npm run migrate:cinemas
 */

const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");

function loadServiceAccount() {
  const argPath = process.argv[2];
  if (argPath) return argPath;
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) return process.env.GOOGLE_APPLICATION_CREDENTIALS;
  console.error("Error: service account JSON path not provided. Pass it as an argument or set GOOGLE_APPLICATION_CREDENTIALS.");
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
const collection = db.collection("cinemas");

const cinemas = [
  {
    name: "Legend Cinema – Noro Mall",
    location: new admin.firestore.GeoPoint(11.5501, 104.9342),
    address: "5th floor, Chip Mong Noro Mall, Preah Norodom Blvd (41), Phnom Penh",
    city: "Phnom Penh",
    openHour: "09:30",
    closeHour: "22:30",
    facilities: ["Regular", "Gold Class"],
    hallCount: 3,
  },
  {
    name: "Legend Cinema – 271 Mega Mall",
    location: new admin.firestore.GeoPoint(11.5223, 104.9300),
    address: "3rd Floor, Chip Mong Mega Mall, St 271, Phum Prek Ta Nu, Sangkat Chak Angrae Leu, Khan Mean Chey, Phnom Penh",
    city: "Phnom Penh",
    openHour: "09:30",
    closeHour: "22:30",
    facilities: ["Regular", "Gold Class"],
    hallCount: 2,
  },
  {
    name: "Legend Cinema – Sihanoukville",
    location: new admin.firestore.GeoPoint(10.6200, 103.5220),
    address: "PGB-5-021, 4th Floor of Prince, Sihanoukville, Cambodia",
    city: "Sihanoukville",
    openHour: "09:30",
    closeHour: "22:30",
    facilities: ["Giant Screen", "Gold Class", "Regular"],
    hallCount: 3,
  },
  {
    name: "Legend Cinema – City Mall",
    location: new admin.firestore.GeoPoint(11.5545, 104.9127),
    address: "Level 3, City Mall, Monireth Boulevard (St 217), Sangkat Vealvong, Khan 7 Makara, Phnom Penh",
    city: "Phnom Penh",
    openHour: "09:30",
    closeHour: "22:30",
    facilities: ["Regular", "Gold Class"],
    hallCount: 3,
  },
  {
    name: "Legend Cinema – Eden Garden",
    location: new admin.firestore.GeoPoint(11.5577, 104.9134),
    address: "City Center Boulevard, Sangkat Srah Chak, Khan Daun Penh, Phnom Penh",
    city: "Phnom Penh",
    openHour: "09:30",
    closeHour: "22:30",
    facilities: ["Regular", "Gold Class", "Coca-Cola Hall"],
    hallCount: 3,
  },
  {
    name: "Legend Cinema – K Mall",
    location: new admin.firestore.GeoPoint(11.5865, 104.8272),
    address: "2nd Floor, K Mall, Veng Sreng Blvd, Phnom Penh",
    city: "Phnom Penh",
    openHour: "09:30",
    closeHour: "22:30",
    facilities: ["Giant Screen", "Gold Class", "Regular"],
    hallCount: 3,
  },
  {
    name: "Legend Cinema – Meanchey",
    location: new admin.firestore.GeoPoint(11.5370, 104.8600),
    address: "3rd Floor, New Steung Mean Chey Market, Veng Sreng Blvd, Sangkat Steung Mean Chey, Khan Mean Chey, Phnom Penh",
    city: "Phnom Penh",
    openHour: "09:30",
    closeHour: "22:30",
    facilities: ["Regular"],
    hallCount: 1,
  },
  {
    name: "Legend Cinema – Midtown Mall",
    location: new admin.firestore.GeoPoint(11.5670, 104.9010),
    address: "1st Floor, Midtown Mall, St 2004 Corner 13B, Phnom Penh",
    city: "Phnom Penh",
    openHour: "09:30",
    closeHour: "22:30",
    facilities: ["Regular", "Gold Class"],
    hallCount: 2,
  },
  {
    name: "Legend Cinema – Olympia Mall",
    location: new admin.firestore.GeoPoint(11.5538, 104.9191),
    address: "6th Floor, Olympia Mall, Monireth Blvd (217), Sangkat Veal Vong, Khan 7 Makara, Phnom Penh",
    city: "Phnom Penh",
    openHour: "09:30",
    closeHour: "22:30",
    facilities: ["Regular", "Gold Class", "Kids Hall"],
    hallCount: 3,
  },
  {
    name: "Legend Premium Cinema – Exchange Square",
    location: new admin.firestore.GeoPoint(11.5740, 104.9120),
    address: "Street 106, Corner of Street 61, Sangkat Wat Phnom, Phnom Penh",
    city: "Phnom Penh",
    openHour: "09:30",
    closeHour: "22:30",
    facilities: ["Diamond Class", "Premium Hall"],
    hallCount: 2,
  },
  {
    name: "Legend Cinema – SenSok",
    location: new admin.firestore.GeoPoint(11.5880, 104.8610),
    address: "4th Floor, Chip Mong SenSok Mall, Okhna Mong Reththey Street, Khan Sen Sok, Phnom Penh",
    city: "Phnom Penh",
    openHour: "09:30",
    closeHour: "22:30",
    facilities: ["Regular", "Gold Class", "Kids Hall"],
    hallCount: 3,
  },
  {
    name: "Legend Cinema – Siem Reap",
    location: new admin.firestore.GeoPoint(13.3630, 103.8570),
    address: "Level 3, The Heritage Walk, Corner of National Road 6 & Oum Chhay St, Svay Dongkoum, Krong Siem Reap, Cambodia",
    city: "Siem Reap",
    openHour: "09:30",
    closeHour: "22:30",
    facilities: ["Regular", "Gold Class"],
    hallCount: 5,
  },
  {
    name: "Legend Cinema – Toul Kork",
    location: new admin.firestore.GeoPoint(11.5755, 104.8660),
    address: "TK Avenue Mall, Street 315, Sangkat Beongkok 1, Khan Toul Kork, Phnom Penh",
    city: "Phnom Penh",
    openHour: "09:30",
    closeHour: "22:30",
    facilities: ["Regular"],
    hallCount: 3,
  },
];

async function run() {
  console.log("🚀 Starting migration of all Legend Cinemas...");
  for (const cinema of cinemas) {
    try {
      await collection.add(cinema);
      console.log(`✅ Uploaded: ${cinema.name}`);
    } catch (e) {
      console.error(`❌ Failed to upload ${cinema.name}:`, e);
    }
  }
  console.log("🎉 All cinemas migration complete!");
  process.exit(0);
}

run().catch((err) => {
  console.error("Migration failed:", err);
  process.exit(1);
});
