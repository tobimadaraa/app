const {onRequest} = require("firebase-functions/v2/https");
const {schedule} = require("firebase-functions/v1/pubsub");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

// Hardcoded Riot API key for now (remember to secure this later)
const RIOT_API_KEY = "hidden";

/**
 * Fetches the current active act ID from the Riot API.
 *
 * @return {Promise<string>} The active act ID.
 * @throws {Error} If no active act is found.
 */
async function getCurrentActId() {
  const contentsUrl = "https://eu.api.riotgames.com/val/content/v1/contents";
  const response = await axios.get(contentsUrl, {
    headers: {"X-Riot-Token": RIOT_API_KEY},
  });
  const acts = response.data.acts;
  if (!acts || acts.length === 0) {
    throw new Error("No acts found in the contents response.");
  }
  const activeAct = acts.find((act) => act.isActive === true);
  if (!activeAct) {
    throw new Error("No active act found.");
  }
  return activeAct.id;
}

/**
 * Delays execution for a specified number of milliseconds.
 *
 * @param {number} ms - The number of milliseconds to delay.
 * @return {Promise<void>}
 */
function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Fetches the leaderboard in batches from Riot API and stores it in Firestore.
 *
 * @return {Promise<void>}
 */
async function storeLeaderboardInBatches() {
  const firestore = admin.firestore();
  const leaderboardRef = firestore.collection("LeaderboardDoc");

  const batchSize = 2000; // Each batch contains 2000 players.
  const pageSize = 200; // Riot API only allows fetching 200 at a time.
  const totalPlayers = 15000; // Maximum number of players you want to fetch.
  const totalBatches = Math.ceil(totalPlayers / batchSize);

  // Get the current active act ID dynamically.
  let actId;
  try {
    actId = await getCurrentActId();
    console.log("Current active Act ID:", actId);
  } catch (error) {
    console.error("Failed to fetch current Act ID:", error);
    throw error;
  }

  // Loop through each batch.
  for (let batchIndex = 0; batchIndex < totalBatches; batchIndex++) {
    const startFrom = batchIndex * batchSize;
    let allPlayers = [];

    // Calculate how many pages are needed for this batch.
    const pagesPerBatch = Math.ceil(batchSize / pageSize);
    for (let page = 0; page < pagesPerBatch; page++) {
      const startIndex = startFrom + page * pageSize;
      try {
        const riotUrl = `https://eu.api.riotgames.com/val/ranked/v1/leaderboards/by-act/${actId}?startIndex=${startIndex}&size=${pageSize}`;
        const response = await axios.get(riotUrl, {
          headers: {"X-Riot-Token": RIOT_API_KEY},
        });
        const playersPage = response.data.players;
        console.log(
            `Fetched page ${page} (Starting from ${startIndex}): ${playersPage.length} players`,
        );
        allPlayers = allPlayers.concat(playersPage);

        // If fewer players are returned than requested, assume it's the end.
        if (playersPage.length < pageSize) {
          console.log(`Reached the end of the leaderboard at page ${page}.`);
          break;
        }
      } catch (error) {
        console.error(`Error fetching page ${page}: ${error}`);
        break;
      }
    }

    // Store the players in Firestore in a document named "batch_X".
    const docRef = leaderboardRef.doc(`batch_${batchIndex}`);
    await docRef.set({players: allPlayers});
    console.log(`✅ Stored ${allPlayers.length} players in document batch_${batchIndex}`);

    // Wait 20 seconds before starting the next batch (if any).
    if (batchIndex < totalBatches - 1) {
      console.log(`⏳ Waiting 7 seconds before fetching batch ${batchIndex + 1}...`);
      await delay(7000);
    }
  }

  console.log("✅ All leaderboard batches stored successfully!");
}

// HTTP Cloud Function that triggers the leaderboard update.
exports.updateLeaderboard = onRequest({
  region: "europe-west1",
  timeoutSeconds: 540,
}, async (req, res) => {
  try {
    console.log("Starting leaderboard update...");
    await storeLeaderboardInBatches();
    console.log("Leaderboard updated successfully!");
    res.status(200).send("Leaderboard updated successfully!");
  } catch (error) {
    console.error("Error updating leaderboard:", error);
    res.status(500).send("Failed to update leaderboard.");
  }
});

exports.ScheduledLeaderboardUpdate = schedule({
  region: "europe-west1",
  timeoutSeconds: 540, // Increase timeout
}, async (_req, res) => {
  try {
    console.log("Starting leaderboard update...");
    await storeLeaderboardInBatches();
    console.log("Leaderboard updated successfully!");
    res.status(200).send("Leaderboard updated successfully!");
  } catch (error) {
    console.error("Error updating leaderboard:", error);
    res.status(500).send("Failed to update leaderboard.");
  }
});
