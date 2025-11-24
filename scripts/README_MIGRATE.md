# Firestore migration (Node.js)

This folder contains a simple Node.js script that uploads a static list of movies to your Firestore `movies` collection using the Firebase Admin SDK.

Steps

1. Create a Firebase service account JSON
   - In Firebase Console: Project Settings > Service accounts > Generate new private key
   - Save the JSON somewhere safe, e.g. `~/keys/legend-cinema-sa.json`

2. Install dependencies

```bash
cd scripts
npm install
```

3. Run the migration

You can either set the env var or pass the path as an argument:

```bash
# Option A: use env var
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/legend-cinema-sa.json"
npm run migrate

# Option B: pass the path explicitly
node migrate_movies.js /path/to/legend-cinema-sa.json
```

Notes
- The script will create documents in the `movies` collection. It will not delete existing documents.
- Timestamps are stored as Firestore timestamps because JS Date objects are automatically converted by the Admin SDK.
