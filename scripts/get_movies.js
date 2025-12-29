/**
 * Node.js script to fetch all movies with full structure from Firestore
 *
 * Usage:
 * node get_movies.js /path/to/serviceAccountKey.json
 */

const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

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

async function run() {
  console.log("📥 Fetching movies from Firestore...\n");

  try {
    const snapshot = await db.collection("movies").get();
    const movies = [];

    snapshot.forEach((doc) => {
      const data = doc.data();
      movies.push({
        title: data.title,
        genres: data.genres || [],
        duration: data.duration,
        rating: data.rating,
        language: data.language,
        subtitles: data.subtitles || [],
        posterUrl: data.posterUrl,
        backdropUrl: data.backdropUrl,
        trailerUrl: data.trailerUrl,
        description: data.description,
        releaseDate: data.releaseDate
          ? data.releaseDate.toDate().toISOString()
          : null,
        status: data.status,
        popularity: data.popularity,
      });
    });

    // Deduplicate by title - keep only first occurrence
    const seenTitles = new Set();
    const distinctMovies = movies.filter((movie) => {
      if (seenTitles.has(movie.title)) {
        return false;
      }
      seenTitles.add(movie.title);
      return true;
    });

    // Sort by title
    distinctMovies.sort((a, b) => a.title.localeCompare(b.title));

    console.log("🎬 Movies Structure:");
    console.log("─".repeat(60));
    distinctMovies.forEach((movie, index) => {
      console.log(`\n${index + 1}. ${movie.title}`);
      console.log(`   ID: ${movie.id}`);
      console.log(`   Genres: ${movie.genres.join(", ")}`);
      console.log(`   Duration: ${movie.duration} mins`);
      console.log(`   Rating: ${movie.rating}`);
      console.log(`   Language: ${movie.language}`);
      console.log(`   Subtitles: ${movie.subtitles.join(", ")}`);
      console.log(`   Status: ${movie.status}`);
      console.log(`   Popularity: ${movie.popularity}`);
      console.log(`   Release: ${movie.releaseDate}`);
    });
    console.log("\n" + "─".repeat(60));
    console.log(`\n📦 Total distinct movies: ${distinctMovies.length}`);

    // Save to JSON file
    const filePath = path.resolve(__dirname, "data/movies_list.json");
    fs.writeFileSync(filePath, JSON.stringify(distinctMovies, null, 2));

    console.log(`✅ movies_list.json has been created at: ${filePath}`);

    process.exit(0);
  } catch (error) {
    console.error("❌ Failed to retrieve movies:", error);
    process.exit(1);
  }
}

run();
