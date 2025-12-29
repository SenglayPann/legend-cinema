/**
 * Update Showtimes Dates Script
 *
 * This script updates all showtime dates in Firebase Firestore to be relative to today.
 *
 * Logic:
 * 1. Fetch all showtimes from Firestore
 * 2. Find the minimum showDateTime across all records
 * 3. For each record, calculate its delta (days) from the minimum date
 * 4. Update each record with: new date = today + delta
 *
 * Usage: node update_showtime_dates.js [path/to/serviceAccount.json]
 */

const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");

// 1. Service Account Setup
function loadServiceAccount() {
  const argPath = process.argv[2];
  if (argPath) return argPath;
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS)
    return process.env.GOOGLE_APPLICATION_CREDENTIALS;

  // Look for common service account files in the current dir
  const currentDir = fs.readdirSync(__dirname);
  const jsonFile = currentDir.find(
    (f) => f.endsWith(".json") && f.includes("firebase-adminsdk")
  );
  if (jsonFile) return path.join(__dirname, jsonFile);

  console.error(
    "Error: Service account not found. Pass it as an argument or set GOOGLE_APPLICATION_CREDENTIALS."
  );
  process.exit(1);
}

const serviceAccountPath = loadServiceAccount();
const serviceAccount = require(path.resolve(serviceAccountPath));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

/**
 * Helper: Format a Date object to "YYYY-MM-DD" string
 */
function formatDateString(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

/**
 * Helper: Get start of day (midnight) for a date
 */
function startOfDay(date) {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  return d;
}

/**
 * Helper: Calculate difference in days between two dates
 */
function daysDifference(date1, date2) {
  const d1 = startOfDay(date1);
  const d2 = startOfDay(date2);
  const diffTime = d2.getTime() - d1.getTime();
  return Math.round(diffTime / (1000 * 60 * 60 * 24));
}

async function run() {
  console.log("🚀 Starting Showtimes Date Update...\n");

  // 2. Fetch all showtimes
  console.log("📥 Fetching all showtimes from Firestore...");
  const showtimesSnapshot = await db.collection("showtimes").get();

  if (showtimesSnapshot.empty) {
    console.error("❌ No showtimes found in Firestore.");
    process.exit(1);
  }

  const showtimes = showtimesSnapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));

  console.log(`✅ Found ${showtimes.length} showtimes.\n`);

  // 3. Find minimum showDateTime
  console.log("🔍 Finding minimum showDateTime...");
  let minDateTime = null;

  for (const showtime of showtimes) {
    if (showtime.showDateTime && showtime.showDateTime.toDate) {
      const date = showtime.showDateTime.toDate();
      if (!minDateTime || date < minDateTime) {
        minDateTime = date;
      }
    }
  }

  if (!minDateTime) {
    console.error("❌ Could not find any valid showDateTime in records.");
    process.exit(1);
  }

  const minDateOnly = startOfDay(minDateTime);
  console.log(`✅ Minimum date found: ${formatDateString(minDateOnly)}\n`);

  // 4. Calculate today's date
  const today = startOfDay(new Date());
  console.log(`📅 Today's date: ${formatDateString(today)}\n`);

  // 5. Prepare updates
  console.log("🔄 Preparing updates...");
  const updates = [];

  for (const showtime of showtimes) {
    if (!showtime.showDateTime || !showtime.showDateTime.toDate) {
      console.warn(
        `⚠️ Skipping showtime ${showtime.id} - no valid showDateTime`
      );
      continue;
    }

    const originalDateTime = showtime.showDateTime.toDate();
    const originalDateOnly = startOfDay(originalDateTime);

    // Calculate delta days from minimum date
    const deltaDays = daysDifference(minDateOnly, originalDateOnly);

    // Calculate new date: today + delta
    const newDateOnly = new Date(today);
    newDateOnly.setDate(newDateOnly.getDate() + deltaDays);

    // Preserve the original time (hours, minutes, seconds)
    const newDateTime = new Date(newDateOnly);
    newDateTime.setHours(
      originalDateTime.getHours(),
      originalDateTime.getMinutes(),
      originalDateTime.getSeconds(),
      originalDateTime.getMilliseconds()
    );

    const newShowDate = formatDateString(newDateOnly);

    updates.push({
      id: showtime.id,
      originalDate: formatDateString(originalDateOnly),
      deltaDays,
      newShowDateTime: admin.firestore.Timestamp.fromDate(newDateTime),
      newShowDate,
    });
  }

  console.log(`✅ Prepared ${updates.length} updates.\n`);

  // Show sample updates
  console.log("📋 Sample updates (first 5):");
  updates.slice(0, 5).forEach((u) => {
    console.log(
      `   ID: ${u.id.substring(0, 8)}... | Original: ${
        u.originalDate
      } | Delta: +${u.deltaDays} days | New: ${u.newShowDate}`
    );
  });
  console.log("");

  // 6. Write updates to Firestore in batches
  console.log("💾 Writing updates to Firestore...");
  const MAX_BATCH_SIZE = 400;
  let batch = db.batch();
  let count = 0;
  let totalWritten = 0;

  for (const update of updates) {
    const ref = db.collection("showtimes").doc(update.id);
    batch.update(ref, {
      showDateTime: update.newShowDateTime,
      showDate: update.newShowDate,
    });
    count++;

    if (count >= MAX_BATCH_SIZE) {
      await batch.commit();
      totalWritten += count;
      console.log(`   Saved ${totalWritten}/${updates.length} documents...`);
      batch = db.batch();
      count = 0;
    }
  }

  if (count > 0) {
    await batch.commit();
    totalWritten += count;
    console.log(`   Saved ${totalWritten}/${updates.length} documents...`);
  }

  console.log("\n🎉 Showtimes date update complete!");
  console.log(`   Total records updated: ${totalWritten}`);
  console.log(
    `   Date range: ${formatDateString(today)} to ${formatDateString(
      new Date(
        today.getTime() +
          Math.max(...updates.map((u) => u.deltaDays)) * 24 * 60 * 60 * 1000
      )
    )}`
  );

  process.exit(0);
}

run().catch((err) => {
  console.error("❌ Update failed:", err);
  process.exit(1);
});
