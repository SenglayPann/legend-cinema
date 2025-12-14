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

// 2. Load Local Data
const cinemasData = require("./data/cinemas.json");
const cinemasMap = {};
cinemasData.forEach((c) => {
  cinemasMap[c.id] = c;
});

async function run() {
  console.log("🚀 Starting Showtimes Migration...");

  // 3. Fetch Dependencies
  console.log("Fetching existing movies...");
  const moviesSnapshot = await db.collection("movies").get();
  const movies = moviesSnapshot.docs.map((d) => ({ id: d.id, ...d.data() }));

  console.log("Fetching existing halls...");
  const hallsSnapshot = await db.collection("halls").get();
  const halls = hallsSnapshot.docs.map((d) => ({ id: d.id, ...d.data() }));

  if (movies.length === 0) {
    console.error(
      "❌ No movies found in Firestore. Please run migrate_movies.js first."
    );
    return;
  }
  if (halls.length === 0) {
    console.error(
      "❌ No halls found in Firestore. Please run migrate_halls.js first."
    );
    return;
  }

  // 4. Group Halls by Cinema to assign Hall Numbers
  const hallsByCinema = {};
  halls.forEach((hall) => {
    if (!hallsByCinema[hall.cinemaId]) {
      hallsByCinema[hall.cinemaId] = [];
    }
    hallsByCinema[hall.cinemaId].push(hall);
  });

  const showtimesBatch = [];

  // 5. Generate Showtimes
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const DAYS_TO_GENERATE = 7;

  for (let d = 0; d < DAYS_TO_GENERATE; d++) {
    const date = new Date(today);
    date.setDate(date.getDate() + d);
    const dateStr = date.toISOString().split("T")[0];

    console.log(`Generating schedule for ${dateStr}...`);

    for (const [cinemaId, cinemaHalls] of Object.entries(hallsByCinema)) {
      const cinema = cinemasMap[cinemaId];
      if (!cinema) {
        // Determine name if not in json map, though we expect it to be there
        continue;
      }

      // Iterate halls in this cinema
      cinemaHalls.forEach((hall, index) => {
        const hallNumber = index + 1; // Assign simple 1-based index

        // Randomly perform 3-5 shows
        const numShows = 3 + Math.floor(Math.random() * 3);
        let currentHour = 10; // First show starts around 10am

        for (let s = 0; s < numShows; s++) {
          // Pick a random movie
          const movie = movies[Math.floor(Math.random() * movies.length)];

          // Helper to format HH:mm
          const formatTime = (dateObj) => {
            const h = dateObj.getHours().toString().padStart(2, "0");
            const m = dateObj.getMinutes().toString().padStart(2, "0");
            return `${h}:${m}`;
          };

          // Start Time: currentHour + some random minutes (0, 15, 30, 45)
          const startMinutes = [0, 15, 30, 45][Math.floor(Math.random() * 4)];
          const showDateTime = new Date(date);
          showDateTime.setHours(currentHour, startMinutes, 0, 0);

          // End Time
          const durationMinutes = movie.duration || 120;
          const endDateTime = new Date(
            showDateTime.getTime() + durationMinutes * 60000
          );

          // Features
          // If hall.screenType is "IMAX" or "4DX", use that.
          // The model expects a list of features.
          const features = [];
          if (hall.screenType) features.push(hall.screenType);
          if (hall.screenType === "Gold") features.push("Recliner Seats");

          const showtime = {
            movieId: movie.id,
            movieTitle: movie.title,
            moviePosterUrl: movie.posterUrl || "",
            cinemaId: cinema.id,
            cinemaName: cinema.name,
            hallId: hall.id,
            hallNumber: hallNumber,
            screenType: hall.screenType || "Standard",
            showDateTime: admin.firestore.Timestamp.fromDate(showDateTime),
            showDate: dateStr,
            showTime: formatTime(showDateTime),
            endTime: formatTime(endDateTime),
            features: features,
          };

          showtimesBatch.push(showtime);

          // Advance current hour: show duration + 30 min cleaning
          const totalMinutesUsed = durationMinutes + 30;
          const hoursUsed = Math.ceil(totalMinutesUsed / 60);
          currentHour += hoursUsed;

          // Stop if too late
          if (currentHour >= 23) break;
        }
      });
    }
  }

  // 6. Write to Firestore in Batches
  console.log(
    `Generated ${showtimesBatch.length} showtimes. Writing to Firestore...`
  );
  const MAX_BATCH_SIZE = 400;
  let batch = db.batch();
  let count = 0;
  let totalWritten = 0;

  for (const docData of showtimesBatch) {
    const ref = db.collection("showtimes").doc();
    batch.set(ref, docData);
    count++;

    if (count >= MAX_BATCH_SIZE) {
      await batch.commit();
      totalWritten += count;
      console.log(`Saved ${totalWritten} documents...`);
      batch = db.batch(); // New batch
      count = 0;
    }
  }

  if (count > 0) {
    await batch.commit();
    totalWritten += count;
    console.log(`Saved ${totalWritten} documents...`);
  }

  console.log("🎉 Showtimes migration complete!");
  process.exit(0);
}

run().catch((err) => {
  console.error("Migration failed:", err);
  process.exit(1);
});
