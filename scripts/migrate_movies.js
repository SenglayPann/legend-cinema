/**
 * Node.js script to migrate movie data to Firestore using firebase-admin.
 *
 * Usage:
 * 1. Create a Firebase service account JSON in the Firebase Console (Project Settings > Service accounts).
 * 2. Download the JSON and either set the GOOGLE_APPLICATION_CREDENTIALS env var to its path
 *    or pass the path as the first argument: node migrate_movies.js /path/to/serviceAccountKey.json
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
const collection = db.collection("movies");

const movies = [
  {
    title: "Avatar: Fire and Ash",
    genres: ["Sci-Fi", "Adventure"],
    duration: 180,
    rating: "PG-13",
    language: "English",
    subtitles: ["English", "Spanish", "French"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1Vy5_U9OX0HleTQv3d8YYAJuEDmN2WWnE&export=view&authuser=0",
    backdropUrl: "",
    trailerUrl: "https://www.youtube.com/watch?v=nb_fFj_0rq8",
    description:
      "The conflict on Pandora escalates as Jake and Neytiri's family encounter a new, aggressive Na'vi tribe.",
    releaseDate: new Date("2025-12-19"),
    status: "showing",
    popularity: 98,
  },
  {
    title: "Fast & Furious X",
    genres: ["Action"],
    duration: 140,
    rating: "PG-13",
    language: "English",
    subtitles: ["English"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=152tpg2E3B5JXMO2mK22UxD9L1iaFIA1q",
    backdropUrl: "",
    trailerUrl: "https://www.youtube.com/watch?v=32RAq6JzY-w",
    description:
      "Over many missions and against impossible odds, Dom Toretto and his family have outsmarted and outdriven every foe in their path. Now, they must confront the most lethal opponent they've ever faced. Fueled by revenge, a terrifying threat emerges from the shadows of the past to shatter Dom's world and destroy everything -- and everyone -- he loves.",
    releaseDate: new Date("2025-04-04"),
    status: "showing",
    popularity: 89,
  },
  {
    title: "Flow",
    genres: ["Animation", "Family"],
    duration: 120,
    rating: "PG",
    language: "English",
    subtitles: ["English", "Spanish"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1VhQxEeTTtKYY4RwaEtdiYpaDQSnlAXjp",
    backdropUrl: "",
    trailerUrl: "https://www.youtube.com/watch?v=82WW9dVbglI",
    description:
      "Cat is a solitary animal, but as its home is devastated by a great flood, he finds refuge on a boat populated by various species, and will have to team up with them despite their differences.",
    releaseDate: new Date("2025-12-26"),
    status: "showing",
    popularity: 87,
  },
  {
    title: "Minecraft: The Movie",
    genres: ["Adventure", "Fantasy"],
    duration: 125,
    rating: "PG",
    language: "English",
    subtitles: ["English"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1ztoZ6bbMpDJktu1TbzKr2VCx0pDVyDKJ",
    backdropUrl: "",
    trailerUrl: "https://www.youtube.com/watch?v=wJO_vIDZn-I",
    description:
      "A mysterious portal pulls four misfits into the Overworld, a bizarre, cubic wonderland that thrives on imagination. To get back home, they'll have to master the terrain while embarking on a magical quest with an unexpected crafter named Steve.",
    releaseDate: new Date("2025-04-04"),
    status: "showing",
    popularity: 88,
  },
  {
    title: "Mission: Impossible – Dead Reckoning",
    genres: ["Action", "Thriller"],
    duration: 160,
    rating: "PG-13",
    language: "English",
    subtitles: ["English", "Japanese"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1IyGEUp7E2EUXRfjskd2koCc5gSuY-fkT",
    backdropUrl: "",
    trailerUrl: "https://www.youtube.com/watch?v=avz06PDqDbM",
    description:
      "Ethan Hunt and the IMF team must track down a terrifying new weapon that threatens all of humanity if it falls into the wrong hands. With control of the future and the fate of the world at stake, a deadly race around the globe begins. Confronted by a mysterious, all-powerful enemy, Ethan is forced to consider that nothing can matter more than the mission -- not even the lives of those he cares about most.",
    releaseDate: new Date("2025-05-23"),
    status: "showing",
    popularity: 94,
  },
  {
    title: "Sonic the Hedgehog 3",
    genres: ["Action", "Family"],
    duration: 130,
    rating: "PG",
    language: "English",
    subtitles: ["English"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1COV9Skff636oRdfwloS7hHU03ptZN5YO",
    backdropUrl: "",
    trailerUrl: "",
    description:
      "Sonic, Knuckles, and Tails are back for their most epic adventure yet. The team reunite to face a new formidable foe, Shadow, a mysterious hedgehog with powers unlike anything they've seen. Keanu Reeves joins the All-Star cast as the voice of Shadow.",
    releaseDate: new Date("2025-12-19"),
    status: "showing",
    popularity: 90,
  },
  {
    title: "Spider-Man: Beyond the Spider-Verse",
    genres: ["Animation", "Superhero"],
    duration: 130,
    rating: "PG-13",
    language: "English",
    subtitles: ["English"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=G0KplSV-R_5kE3YW3-O0OEIKxSCM3Za8",
    backdropUrl: "",
    trailerUrl: "",
    description:
      "Spider-Man: Beyond the Spider-Verse is an upcoming American animated superhero film based on Marvel Comics featuring the character Miles Morales / Spider-Man.",
    releaseDate: new Date("2025-10-10"),
    status: "showing",
    popularity: 85,
  },
  {
    title: "Superman",
    genres: ["Action", "Superhero"],
    duration: 150,
    rating: "PG-13",
    language: "English",
    subtitles: ["English"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=12NMWqbh1TUoKuIbP9e3Btk8cki8ovTqf",
    backdropUrl: "",
    trailerUrl: "https://www.youtube.com/watch?v=Ox8ZLF6cGM0",
    description:
      "When Superman gets drawn into conflicts at home and abroad, his actions are questioned, giving tech billionaire Lex Luthor the opportunity to get the Man of Steel out of the way for good. Will intrepid reporter Lois Lane and Superman's four-legged companion, Krypto, be able to help him before it's too late?",
    releaseDate: new Date("2025-07-11"),
    status: "showing",
    popularity: 92,
  },
  {
    title: "The Batman",
    genres: ["Action", "Crime"],
    duration: 165,
    rating: "PG-13",
    language: "English",
    subtitles: ["English"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1GTTOzrqghgHGPUYQob_ld2wX046NWEFp",
    backdropUrl: "",
    trailerUrl: "https://www.youtube.com/watch?v=mqqft2x_Aa4",
    description:
      "Batman is called to intervene when the mayor of Gotham City is murdered. Soon, his investigation leads him to uncover a web of corruption, linked to his own dark past.",
    releaseDate: new Date("2025-10-03"),
    status: "showing",
    popularity: 96,
  },
  {
    title: "The Wild Robot",
    genres: ["Animation", "Musical"],
    duration: 130,
    rating: "PG",
    language: "English",
    subtitles: ["English"],
    posterUrl:
      "https://drive.usercontent.google.com/download?id=1fCO-7BzwYKEdJ8_ZB1XfbqP5HuGRVVoT",
    backdropUrl: "",
    trailerUrl: "https://www.youtube.com/watch?v=67vbA5ZJdKQ",
    description:
      "After a shipwreck, an intelligent robot is stranded on an uninhabited island. To survive the harsh surroundings, she bonds with the native animals and cares for an orphaned baby goose. The film was nominated for 3 Oscars.",
    releaseDate: new Date("2025-11-27"),
    status: "showing",
    popularity: 99,
  },
];

async function run() {
  console.log("🚀 Starting migration...");
  for (const movie of movies) {
    // Firestore will store JS Date as timestamp automatically
    try {
      await collection.add(movie);
      console.log(`✅ Uploaded: ${movie.title}`);
    } catch (e) {
      console.error(`❌ Failed to upload ${movie.title}:`, e);
    }
  }
  console.log("🎉 Migration complete!");
  process.exit(0);
}

run().catch((err) => {
  console.error("Migration failed:", err);
  process.exit(1);
});
