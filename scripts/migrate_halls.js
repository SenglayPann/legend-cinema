/**
 * migrate_halls_realistic.js
 *
 * Node.js script to create realistic hall documents for Legend Cinema branches.
 *
 * Usage:
 *   node migrate_halls_realistic.js /path/to/serviceAccountKey.json
 *
 * Each created hall document will have fields:
 *   cinemaId, screenType,
 *   seatLayout: { numberOfRow, numberOfColumn },
 *   twinSeatLayout: { numberOfRow, numberOfColumn },
 *   vipSeatLayout: { numberOfRow, numberOfColumn },
 *   seatPrice, vipSeatPrice, twinSeatPrice
 */

const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");

function loadServiceAccount() {
  const argPath = process.argv[2];
  if (argPath) return argPath;
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS)
    return process.env.GOOGLE_APPLICATION_CREDENTIALS;
  console.error("❌ Service account JSON path not provided. Pass it as an argument or set GOOGLE_APPLICATION_CREDENTIALS.");
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
const hallCollection = db.collection("halls");

// ---------------------------
// Screen-type -> base layout
// ---------------------------
const SCREEN_LAYOUTS = {
  Regular: { numberOfRow: 12, numberOfColumn: 20 },
  Gold: { numberOfRow: 8, numberOfColumn: 14 },
  Premium: { numberOfRow: 10, numberOfColumn: 16 },
  Kids: { numberOfRow: 6, numberOfColumn: 12 },
  Giant: { numberOfRow: 16, numberOfColumn: 22 },
  Diamond: { numberOfRow: 8, numberOfColumn: 10 },
  "Coca-Cola": { numberOfRow: 10, numberOfColumn: 18 },
  "Coca-Cola Hall": { numberOfRow: 10, numberOfColumn: 18 }, // extra label support
};

// ---------------------------
// Pricing per screen type (Option 2)
// ---------------------------
const PRICE = {
  Regular: { seat: 4.5, vip: 6.0, twin: 7.0 },
  Gold: { seat: 5.0, vip: 7.0, twin: 8.0 },
  Premium: { seat: 5.5, vip: 7.5, twin: 8.5 },
  Kids: { seat: 3.5, vip: 0.0, twin: 0.0 },
  Giant: { seat: 6.0, vip: 9.0, twin: 10.0 },
  Diamond: { seat: 7.0, vip: 10.0, twin: 12.0 },
  "Coca-Cola": { seat: 5.5, vip: 7.0, twin: 8.0 },
  "Coca-Cola Hall": { seat: 5.5, vip: 7.0, twin: 8.0 },
};

// ---------------------------
// Twin/VIP layout rule functions
// ---------------------------
function deriveTwinLayout(screenType, baseLayout) {
  // returns { numberOfRow, numberOfColumn }
  const cols = baseLayout.numberOfColumn;
  switch (screenType) {
    case "Regular":
      return { numberOfRow: 2, numberOfColumn: Math.min(10, Math.max(1, Math.floor(cols / 2))) };
    case "Gold":
    case "Premium":
    case "Diamond":
      return { numberOfRow: 3, numberOfColumn: Math.max(2, cols - 2) };
    case "Giant":
    case "Coca-Cola":
    case "Coca-Cola Hall":
      return { numberOfRow: 4, numberOfColumn: Math.max(2, cols - 2) };
    case "Kids":
      return { numberOfRow: 0, numberOfColumn: 0 };
    default:
      return { numberOfRow: 0, numberOfColumn: 0 };
  }
}

function deriveVipLayout(screenType, baseLayout) {
  const cols = baseLayout.numberOfColumn;
  switch (screenType) {
    case "Regular":
      return { numberOfRow: 0, numberOfColumn: 0 }; // no VIP in regular by default
    case "Gold":
    case "Premium":
    case "Diamond":
      return { numberOfRow: 2, numberOfColumn: Math.max(2, cols - 4) };
    case "Giant":
    case "Coca-Cola":
    case "Coca-Cola Hall":
      return { numberOfRow: 2, numberOfColumn: Math.max(2, cols - 4) };
    case "Kids":
      return { numberOfRow: 0, numberOfColumn: 0 };
    default:
      return { numberOfRow: 0, numberOfColumn: 0 };
  }
}

// ---------------------------
// Cinema -> screen types mapping (based on Legend public info & earlier agreement)
// One hall record will be produced per listed screenType
// ---------------------------
const cinemaHalls = [
  { id: "2ReQah8P9OxA9shoAYSe", name: "Legend Cinema – Sihanoukville", screens: ["Regular", "Gold", "Giant"] },
  { id: "5HceqnKMAAjzvy3xncbZ", name: "Legend Cinema – Noro Mall", screens: ["Regular", "Gold"] },
  { id: "5TeOb0LcvSMBP4KA43K1", name: "Legend Cinema – Siem Reap", screens: ["Regular", "Gold"] },
  { id: "AVDkSLDhYTDYadvzQSOs", name: "Legend Cinema – K Mall", screens: ["Regular", "Gold", "Giant"] },
  { id: "AntZftXHrxw6gX6hjri4", name: "Legend Cinema – City Mall", screens: ["Regular", "Gold"] },
  { id: "BfSOTmx2YQON4whsodwe", name: "Legend Cinema – Olympia Mall", screens: ["Regular", "Gold", "Kids"] },
  { id: "Ef5YBta9AuoQtVWdvicu", name: "Legend Premium Cinema – Exchange Square", screens: ["Premium", "Diamond"] },
  { id: "R6WPvEaWYCN4mMt9nLDj", name: "Legend Cinema – Toul Kork", screens: ["Regular"] },
  { id: "bfr3rKld9EumdBPKDzS1", name: "Legend Cinema – Meanchey", screens: ["Regular"] },
  { id: "gwfGLztp8injVyHJdsJC", name: "Legend Cinema – Midtown Mall", screens: ["Regular", "Gold"] },
  { id: "kyERtx3xdh7684AC6dK0", name: "Legend Cinema – SenSok", screens: ["Regular", "Gold", "Kids"] },
  { id: "oms5ajLAY1xloqGNL60F", name: "Legend Cinema – Eden Garden", screens: ["Regular", "Gold", "Coca-Cola"] },
  { id: "x3sKzRcAYrivWHZjdrCe", name: "Legend Cinema – 271 Mega Mall", screens: ["Regular", "Gold"] },
];

// ---------------------------
// Create halls
// ---------------------------
async function run() {
  console.log("🚀 Starting realistic hall migration (one document per screen type)...");

  let totalCreated = 0;
  for (const cinema of cinemaHalls) {
    for (let i = 0; i < cinema.screens.length; i++) {
      const screenType = cinema.screens[i];

      // normalize screenType keys for templates/pricing (support small variations)
      const key = (() => {
        if (screenType.toLowerCase().includes("coca")) return "Coca-Cola";
        if (screenType.toLowerCase().includes("diamond")) return "Diamond";
        if (screenType.toLowerCase().includes("premium")) return "Premium";
        if (screenType.toLowerCase().includes("kids")) return "Kids";
        if (screenType.toLowerCase().includes("giant")) return "Giant";
        if (screenType.toLowerCase().includes("gold")) return "Gold";
        return "Regular";
      })();

      const baseLayout = SCREEN_LAYOUTS[key] || { numberOfRow: 10, numberOfColumn: 20 };
      const twin = deriveTwinLayout(key, baseLayout);
      const vip = deriveVipLayout(key, baseLayout);
      const prices = PRICE[key] || PRICE["Regular"];

      const hallDoc = {
        cinemaId: cinema.id,
        screenType: screenType,
        seatLayout: {
          numberOfRow: baseLayout.numberOfRow,
          numberOfColumn: baseLayout.numberOfColumn,
        },
        twinSeatLayout: {
          numberOfRow: twin.numberOfRow,
          numberOfColumn: twin.numberOfColumn,
        },
        vipSeatLayout: {
          numberOfRow: vip.numberOfRow,
          numberOfColumn: vip.numberOfColumn,
        },
        seatPrice: prices.seat,
        vipSeatPrice: prices.vip,
        twinSeatPrice: prices.twin,
        // optional metadata:
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        // note: you can add hallNumber or labels if needed
      };

      try {
        const res = await hallCollection.add(hallDoc);
        totalCreated++;
        console.log(`✅ Created hall (${screenType}) for cinema '${cinema.name}' => docId: ${res.id}`);
      } catch (err) {
        console.error(`❌ Failed to create hall (${screenType}) for cinema '${cinema.name}':`, err);
      }
    }
  }

  console.log(`🎉 Hall migration finished. Total halls created: ${totalCreated}`);
  process.exit(0);
}

run().catch((err) => {
  console.error("❌ Migration script failed:", err);
  process.exit(1);
});
