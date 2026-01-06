/**
 * Node.js script to migrate upcoming movie data to Firestore using firebase-admin.
 *
 * Usage:
 * 1. Create a Firebase service account JSON in the Firebase Console (Project Settings > Service accounts).
 * 2. Download the JSON and either set the GOOGLE_APPLICATION_CREDENTIALS env var to its path
 *    or pass the path as the first argument: node migrate_upcoming_movies.js /path/to/serviceAccountKey.json
 * 3. npm install
 * 4. node migrate_upcoming_movies.js <path-to-service-account>
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
const collection = db.collection("movies");

// 10 Real Upcoming Movies (2026)
const upcomingMovies = [
  {
    title: "28 Years Later: The Bone Temple",
    genres: ["Horror", "Thriller"],
    duration: 130,
    rating: "R",
    language: "English",
    subtitles: ["English"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1nNAeKRDfCg2It-W7lM2uPI_Z0wazqRzw",
    backdropUrl: "",
    trailerUrl: "https://youtu.be/EOwTdTZA8D8",
    description:
      "The second film in the new 28 Years Later trilogy. Survivors of the rage virus must confront a new horrifying evolution of the infected as they search for sanctuary in a world forever changed.",
    releaseDate: new Date("2026-01-16"),
    status: "upcoming",
    popularity: 92,
  },
  {
    title: "Scream 7",
    genres: ["Horror", "Thriller", "Mystery"],
    duration: 120,
    rating: "R",
    language: "English",
    subtitles: ["English"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=10Od0TZKNqSpGTpESqn-fiWyR1fFJyEpI",
    backdropUrl: "",
    trailerUrl: "https://youtu.be/UJrghaPJ0RY",
    description:
      "Ghostface returns in the seventh installment of the iconic slasher franchise. A new wave of terror grips as the killer targets a fresh set of victims with ties to the past.",
    releaseDate: new Date("2026-02-27"),
    status: "upcoming",
    popularity: 88,
  },
  {
    title: "Project Hail Mary",
    genres: ["Sci-Fi", "Adventure", "Drama"],
    duration: 150,
    rating: "PG-13",
    language: "English",
    subtitles: ["English"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1GNXGpxjLmEUtYphD6P9Z7L5agvUsIvFj",
    backdropUrl: "",
    trailerUrl: "https://youtu.be/m08TxIsFTRI",
    description:
      "Based on Andy Weir's bestselling novel. A lone astronaut wakes up on a spacecraft with no memory of how he got there. He must solve an impossible scientific mystery and save humanity from extinction.",
    releaseDate: new Date("2026-03-19"),
    status: "upcoming",
    popularity: 90,
  },
  {
    title: "The Super Mario Bros. Movie 2",
    genres: ["Animation", "Adventure", "Comedy"],
    duration: 100,
    rating: "PG",
    language: "English",
    subtitles: ["English", "Spanish", "Japanese"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1tuYlJMbydwRdOVDGS2eS5ulke_zGD31B",
    backdropUrl: "",
    trailerUrl: "https://youtu.be/b9cssnPD74o",
    description:
      "Mario, Luigi, and their friends return for another adventure in the Mushroom Kingdom. This time they must journey to new worlds and face an even greater threat than ever before.",
    releaseDate: new Date("2026-04-03"),
    status: "upcoming",
    popularity: 95,
  },
  {
    title: "Avengers: Doomsday",
    genres: ["Action", "Superhero", "Sci-Fi"],
    duration: 180,
    rating: "PG-13",
    language: "English",
    subtitles: ["English"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1Jn-wDUOLBfqVz9Dj9lx_ZGEF87SYVZeF",
    backdropUrl: "",
    trailerUrl: "https://youtu.be/1clWprLC5Ak",
    description:
      "The Avengers must assemble once more to face Doctor Doom, one of the most powerful and cunning villains in the Marvel Universe. The fate of the multiverse hangs in the balance.",
    releaseDate: new Date("2026-05-01"),
    status: "upcoming",
    popularity: 98,
  },
  {
    title: "Toy Story 5",
    genres: ["Animation", "Adventure", "Comedy"],
    duration: 105,
    rating: "G",
    language: "English",
    subtitles: ["English", "Spanish"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1xj10P3qKQi9XnyME2sKZEh5SsDM1HLge",
    backdropUrl: "",
    trailerUrl: "https://youtu.be/GGBgf8dcgyY",
    description:
      "Woody, Buzz, and the gang return in a new adventure that explores the changing world of play as technology evolves. The beloved toys must adapt to a new era while staying true to their core purpose: being there for their kid.",
    releaseDate: new Date("2026-06-18"),
    status: "upcoming",
    popularity: 93,
  },
  {
    title: "Supergirl: Woman of Tomorrow",
    genres: ["Action", "Superhero", "Sci-Fi"],
    duration: 140,
    rating: "PG-13",
    language: "English",
    subtitles: ["English"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1OJ6scBiiu-tGqzt7jZd8EGSArPFf9TLV",
    backdropUrl: "",
    trailerUrl: "https://youtu.be/YqdAEdkHrwo",
    description:
      "Kara Zor-El embarks on a cosmic adventure to seek justice across the galaxy. Accompanied by a young girl seeking vengeance, Supergirl must confront her own past while fighting for a better tomorrow.",
    releaseDate: new Date("2026-06-26"),
    status: "upcoming",
    popularity: 89,
  },
  {
    title: "Spider-Man: Brand New Day",
    genres: ["Action", "Superhero", "Adventure"],
    duration: 145,
    rating: "PG-13",
    language: "English",
    subtitles: ["English"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=17I1I872XhVvg1uPxKh2J76qoTXIxfdd0",
    backdropUrl: "",
    trailerUrl: "https://youtu.be/QOdF1zK4ZkY",
    description:
      "Peter Parker faces a new chapter in his life as Spider-Man. With new allies and formidable foes, he must navigate the challenges of being a hero while protecting those he loves.",
    releaseDate: new Date("2026-07-30"),
    status: "upcoming",
    popularity: 96,
  },
  {
    title: "The Hunger Games: Sunrise on the Reaping",
    genres: ["Action", "Drama", "Sci-Fi"],
    duration: 155,
    rating: "PG-13",
    language: "English",
    subtitles: ["English"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1U4DCnhBZ029VixHVRr9Um7q4hU_3_iqD",
    backdropUrl: "",
    trailerUrl: "https://youtu.be/MPjxijuBuSo",
    description:
      "Set during the 50th Hunger Games, also known as the Second Quarter Quell, this prequel explores the story of Haymitch Abernathy and the events that shaped District 12's only living victor before Katniss Everdeen.",
    releaseDate: new Date("2026-11-20"),
    status: "upcoming",
    popularity: 91,
  },
  {
    title: "Dune: Part Three",
    genres: ["Sci-Fi", "Adventure", "Drama"],
    duration: 175,
    rating: "PG-13",
    language: "English",
    subtitles: ["English", "French"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1OVbDCkepnHSDIQTmbi1wgENemtmqj1Ck",
    backdropUrl: "",
    trailerUrl: "https://youtu.be/U2Qp5pL3ovA",
    description:
      "The epic saga continues as Paul Atreides leads the Fremen in the ultimate battle for Arrakis. The conclusion to Denis Villeneuve's adaptation of Frank Herbert's legendary sci-fi novel.",
    releaseDate: new Date("2026-12-18"),
    status: "upcoming",
    popularity: 97,
  },
];

async function run() {
  console.log("🚀 Starting upcoming movies migration...");
  for (const movie of upcomingMovies) {
    // Firestore will store JS Date as timestamp automatically
    try {
      await collection.add(movie);
      console.log(`✅ Uploaded: ${movie.title}`);
    } catch (e) {
      console.error(`❌ Failed to upload ${movie.title}:`, e);
    }
  }
  console.log("🎉 Upcoming movies migration complete!");
  process.exit(0);
}

run().catch((err) => {
  console.error("Migration failed:", err);
  process.exit(1);
});
