const {onRequest} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {defineSecret} = require("firebase-functions/params");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

const RIOT_API_KEY = defineSecret("RIOT_API_KEY");

/**
 * Fetches the current active act ID from the Riot API.
 *
 * @return {Promise<string>} The active act ID.
 * @throws {Error} If no active act is found.
 */
async function getCurrentActId() {
  const contentsUrl = "https://eu.api.riotgames.com/val/content/v1/contents";
  const response = await axios.get(contentsUrl, {
    headers: {"X-Riot-Token": RIOT_API_KEY.value()},
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

  function hashStringToInt(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      hash = str.charCodeAt(i) + ((hash << 5) - hash);
    }
    return Math.abs(hash);
  }
  let actId;
  try {
    actId = await getCurrentActId();
    console.log("Current active Act ID:", actId);
  } catch (error) {
    console.error("Failed to fetch current Act ID:", error);
    throw error;
  }

  for (let batchIndex = 0; batchIndex < totalBatches; batchIndex++) {
    const startFrom = batchIndex * batchSize;
    let allPlayers = [];

    const pagesPerBatch = Math.ceil(batchSize / pageSize);
    for (let page = 0; page < pagesPerBatch; page++) {
      const startIndex = startFrom + page * pageSize;
      try {
        const riotUrl = `https://eu.api.riotgames.com/val/ranked/v1/leaderboards/by-act/${actId}?startIndex=${startIndex}&size=${pageSize}`;
        const response = await axios.get(riotUrl, {
          headers: {"X-Riot-Token": RIOT_API_KEY.value()},
        });

        const playersPage = response.data.players;
        console.log(
            `Fetched page ${page} (Starting from ${startIndex}): ${playersPage.length} players`,
        );
        allPlayers = allPlayers.concat(playersPage);

        if (playersPage.length < pageSize) {
          console.log(`Reached the end of the leaderboard at page ${page}.`);
          break;
        }
      } catch (error) {
        console.error(`Error fetching page ${page}: ${error}`);
        break;
      }
    }
    allPlayers = allPlayers.map((player) => {
      const gameNameLower = (player.gameName || "").toLowerCase();
      const tagLineLower = (player.tagLine || "").toLowerCase();
      const searchKey = `${gameNameLower}#${tagLineLower}`;
      const iconIndex = hashStringToInt(searchKey) % 5; // Gives a number from 0 to 4
      return {
        ...player,
        searchKey: searchKey,
        iconIndex: iconIndex,
      };
    });
    const docRef = leaderboardRef.doc(`batch_${batchIndex}`);
    await docRef.set({players: allPlayers});
    console.log(`✅ Stored ${allPlayers.length} players in document batch_${batchIndex}`);

    if (batchIndex < totalBatches - 1) {
      console.log(`⏳ Waiting 10 seconds before fetching batch ${batchIndex + 1}...`);
      await delay(12000);
    }
  }

  console.log("✅ All leaderboard batches stored successfully!");
}

/**
 * HTTP Cloud Function that triggers the leaderboard update.
 */
exports.updateLeaderboard = onRequest(
    {
      region: "europe-west1",
      timeoutSeconds: 540,
      secrets: [RIOT_API_KEY], // Attach the secret
    },
    async (req, res) => {
      try {
        console.log("Starting leaderboard update...");
        console.log("Using Riot API Key:", RIOT_API_KEY.value());

        await storeLeaderboardInBatches();

        console.log("✅ Leaderboard updated successfully!");
        res.status(200).send("Leaderboard updated successfully!");
      } catch (error) {
        console.error("❌ Error updating leaderboard:", error);
        res.status(500).send("Failed to update leaderboard.");
      }
    },
);

/**
 * Scheduled function that runs every hour to update the leaderboard.
 */
exports.ScheduledLeaderboardUpdate = onSchedule(
    {
      schedule: "every 20 minutes", // Runs every 20m
      timeZone: "Etc/UTC",
      region: "europe-west1",
      timeoutSeconds: 540,
      secrets: [RIOT_API_KEY],
    },
    async () => {
      try {
        console.log("⏳ Running automatic leaderboard update...");
        await storeLeaderboardInBatches();
        console.log("✅ Leaderboard updated successfully!");
      } catch (error) {
        console.error("❌ Error updating leaderboard:", error);
      }
    },
);
