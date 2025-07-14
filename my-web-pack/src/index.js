const { initAioha, KeyTypes, Providers, Asset } = require("@aioha/aioha");
const { PlaintextKeyProvider } = require("@aioha/aioha/build/providers/custom/plaintext.js");
var Buffer = require('buffer/').Buffer
const dhive = require('@hiveio/dhive');
let dhiveClient = new dhive.Client(["https://api.hive.blog"]);
window.dhiveClient = dhiveClient;
window.dhiveUtils = dhive.utils;

const aioha = initAioha({
  hiveauth: {
    name: "Hive Flutter Kit",
    description: "Hive Flutter Kit based flutter-apps",
  },
});

aioha.on("hiveauth_challenge_request", (payload, evt, cancel) => {
  qrString = payload;
});
aioha.on("hiveauth_sign_request", (payload, evt, cancel) => {
  qrString = payload;
});

let qrString = "";

async function getChainProperties() {
  const props = await dhiveClient.database.getChainProperties();
  return JSON.stringify(props);
}
window.getChainProperties = getChainProperties;

async function getDiscussions(
  by,
  limit = 20,
  tag = "",
  startAuthor = null,
  startPermlink = null,
  observer = null
) {
  const query = {
    sort: by,
    tag: tag,
    limit: limit,
    start_author: startAuthor,
    start_permlink: startPermlink,
  };

  if (observer) query.observer = observer;
  const discussions = await dhiveClient.call(
    "bridge",
    "get_ranked_posts",
    query
  );
  return JSON.stringify(discussions);
}
window.getDiscussions = getDiscussions;

async function getListOfCommunities(
  last,
  limit = 20,
  query = "",
  observer = null
) {
  const params = {
    limit: limit,
  };

  if (last && last.trim() !== "") {
    params.last = last;
  }

  if (query && query.trim() !== "") {
    params.query = query;
  }

  if (observer !== null && observer !== undefined) {
    params.observer = observer;
  }

  try {
    const listOfCommunities = await dhiveClient.call(
      "bridge",
      "list_communities",
      params
    );
    return JSON.stringify(listOfCommunities);
  } catch (error) {
    console.error("Error calling list_communities:", error);
    return JSON.stringify([]);
  }
}
window.getListOfCommunities = getListOfCommunities;

async function getCommentsList(author, permlink) {
  const params = {
    author: author,
    permlink: permlink,
  };

  const discussion = await dhiveClient.call("bridge", "get_discussion", params);
  return JSON.stringify(discussion);
}
window.getCommentsList = getCommentsList;

async function getAccounts(usernames) {
  const accounts = await dhiveClient.database.getAccounts(usernames);
  return JSON.stringify(accounts);
}
window.getAccounts = getAccounts;

async function getVotingPowerData(username) {
  const downVotingPower = (account) => {
    const HIVE_VOTING_MANA_REGENERATION_SECONDS = 5 * 60 * 60 * 24; // 5 days
    const totalShares =
      parseFloat(account.vesting_shares) +
      parseFloat(account.received_vesting_shares) -
      parseFloat(account.delegated_vesting_shares) -
      parseFloat(account.vesting_withdraw_rate);
    const elapsed =
      Math.floor(Date.now() / 1000) - account.downvote_manabar.last_update_time;
    const maxMana = (totalShares * 1000000) / 4;

    let currentMana =
      parseFloat(account.downvote_manabar.current_mana.toString()) +
      (elapsed * maxMana) / HIVE_VOTING_MANA_REGENERATION_SECONDS;

    if (currentMana > maxMana) {
      currentMana = maxMana;
    }
    const currentManaPerc = (currentMana * 100) / maxMana;
    if (isNaN(currentManaPerc)) {
      return 0;
    }
    if (currentManaPerc > 100) {
      return 100;
    }
    return currentManaPerc;
  };

  const accounts = await dhiveClient.database.getAccounts([username]);
  if (accounts.length === 0)
    return JSON.stringify({ error: "Account not found!" });
  const account = accounts[0];
  const calc = dhiveClient.rc.calculateVPMana(account);
  const dv = downVotingPower(account);
  var upvotepower = (calc.percentage / 100).toFixed(2);
  var downvote = dv.toFixed(2);

  const result = { upvotepower, downvote };
  return JSON.stringify(result);
}
window.getVotingPowerData = getVotingPowerData;

async function getResourceCreditsPercentage(username) {
  const [manabar] = await dhiveClient.rc.findRCAccounts([username]);
  const currentMana = parseFloat(manabar.rc_manabar.current_mana);
  const maxRC = parseFloat(manabar.max_rc);
  const rcPercentage = (currentMana / maxRC) * 100;
  return rcPercentage;
}
window.getResourceCreditsPercentage = getResourceCreditsPercentage;

async function getAccountPosts(
  username,
  by,
  limit = 20,
  startAuthor = null,
  startPermlink = null,
  observer = null
) {
  const query = {
    account: username,
    sort: by,
    limit: limit,
    start_author: startAuthor,
    start_permlink: startPermlink,
  };

  if (observer) query.observer = observer;
  const discussions = await dhiveClient.call(
    "bridge",
    "get_account_posts",
    query
  );
  return JSON.stringify(discussions);
}
window.getAccountPosts = getAccountPosts;

async function loginWithKeychain(username, proof) {
  qrString = "";
  if (proof === undefined || proof === null || proof === "") {
    proof = parseInt(new Date().getTime() / 1000);
  }
  const login = await aioha.login(Providers.Keychain, username, {
    msg: `${proof}`,
    keyType: KeyTypes.Posting,
  });
  if (login.error && login.error !== "Already logged in") {
    qrString = "";
    throw new Error("Login Error " + login.error);
  } else if (login.error === "Already logged in") {
    aioha.switchUser(username);
    const signedResult = await aioha.signMessage(`${proof}`, KeyTypes.Posting);
    if (signedResult.error) {
      qrString = "";
      throw new Error("Signing Error " + signedResult.error);
    }
    qrString = "";
    return JSON.stringify({
      ...signedResult,
      proof: `${proof}`,
      username: username,
    });
  }
  qrString = "";
  return JSON.stringify({ ...login, proof: `${proof}` });
}
window.loginWithKeychain = loginWithKeychain; // Expose the function to Dart

async function loginWithHiveAuth(username, proof) {
  qrString = "";
  if (proof === undefined || proof === null || proof === "") {
    proof = parseInt(new Date().getTime() / 1000);
  }
  const login = await aioha.login(Providers.HiveAuth, username, {
    msg: `${proof}`,
    keyType: KeyTypes.Posting,
    hiveauth: {
      cbWait: (payload, evt) => {
        qrString = payload;
      },
    },
  });
  if (login.error && login.error !== "Already logged in") {
    qrString = "";
    throw new Error("Login Error " + login.error);
  } else if (login.error === "Already logged in") {
    aioha.switchUser(username);
    const signedResult = await aioha.signMessage(`${proof}`, KeyTypes.Posting);
    if (signedResult.error) {
      qrString = "";
      throw new Error("Signing Error " + signedResult.error);
    }
    qrString = "";
    return JSON.stringify({
      ...signedResult,
      proof: `${proof}`,
      username: username,
    });
  }
  qrString = "";
  return JSON.stringify({
    ...login,
    proof: `${proof}`,
    username: username,
  });
}
window.loginWithHiveAuth = loginWithHiveAuth;

async function loginWithPlaintextKey(username, postingKey, proof) {
  qrString = "";
  if (proof === undefined || proof === null || proof === "") {
    proof = parseInt(new Date().getTime() / 1000);
  }
  aioha.registerCustomProvider(new PlaintextKeyProvider(postingKey));
  const login = await aioha.login(Providers.Custom, username, {
    msg: `${proof}`,
    keyType: KeyTypes.Posting,
  });

  if (login.error && login.error !== "Already logged in") {
    qrString = "";
    throw new Error("Login Error " + login.error);
  } else if (login.error === "Already logged in") {
    aioha.switchUser(username);
    const signedResult = await aioha.signMessage(`${proof}`, KeyTypes.Posting);
    if (signedResult.error) {
      qrString = "";
      throw new Error("Signing Error " + signedResult.error);
    }
    qrString = "";
    return JSON.stringify({
      ...signedResult,
      proof: `${proof}`,
      username: username,
    });
  }

  qrString = "";
  return JSON.stringify({
    ...login,
    proof: `${proof}`,
    username: username,
  });
}
window.loginWithPlaintextKey = loginWithPlaintextKey; // Expose the function to Dart

async function getQrString() {
  return qrString;
}
window.getQrString = getQrString; // Expose the function to Dart

async function getCurrentUser() {
  try {
    const currentUser = aioha.getCurrentUser();
    if (currentUser) {
      return JSON.stringify(currentUser);
    } else {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}
window.getCurrentUser = getCurrentUser;

async function logoutUser() {
  try {
    const currentUser = aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify("No user is currently logged in");
    }
    const logoutResult = await aioha.logout();
    return JSON.stringify(logoutResult);
  } catch (error) {
    return JSON.stringify(error.toString());
  }
}
window.logoutUser = logoutUser; // Expose the function to Dart

async function singleVote(author, permlink, weight) {
  try {
    const currentUser = aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
    const result = await aioha.vote(author, permlink, weight);
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}
window.singleVote = singleVote; // Expose the function to Dart

async function comment(
  parentAuthor,
  parentPermlink,
  permlink,
  title,
  body,
  jsonMetadata
) {
  try {
    const currentUser = aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
    const result = await aioha.comment(
      parentAuthor,
      parentPermlink,
      permlink,
      title,
      body,
      jsonMetadata
    );
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}
window.comment = comment; // Expose the function to Dart

async function commentWithOptions(
  parentAuthor,
  parentPermlink,
  permlink,
  title,
  body,
  jsonMetadata,
  options
) {
  try {
    const currentUser = aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
    const result = await aioha.comment(
      parentAuthor,
      parentPermlink,
      permlink,
      title,
      body,
      JSON.parse(jsonMetadata),
      JSON.parse(options)
    );
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}
window.commentWithOptions = commentWithOptions; // Expose the function to Dart

async function deleteComment(permlink) {
  try {
    const currentUser = aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
    const result = await aioha.deleteComment(permlink);
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}
window.deleteComment = deleteComment; // Expose the function to Dart

async function reblog(author, permlink, reblogFlag) {
  try {
    const currentUser = aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
    const result = await aioha.reblog(author, permlink, reblogFlag);
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}
window.reblog = reblog; // Expose the function to Dart

async function follow(author, followFlag) {
  try {
    const currentUser = aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
    const result = await aioha.follow(author, followFlag);
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}
window.follow = follow; // Expose the function to Dart

async function claimRewards() {
  try {
    const currentUser = aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
    const result = await aioha.claimRewards();
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}
window.claimRewards = claimRewards; // Expose the function to Dart

async function signMessage(message, keyType) {
  try {
    const currentUser = aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
    let keytypeForSignMessage = KeyTypes.Posting;
    if (keyType === "active") {
      keytypeForSignMessage = KeyTypes.Active;
    } else if (keyType === "memo") {
      keytypeForSignMessage = KeyTypes.Memo;
    } else {
      keytypeForSignMessage = KeyTypes.Posting;
    }
    const result = await aioha.signMessage(message, keytypeForSignMessage);
    return JSON.stringify({ ...result, username: aioha.getCurrentUser() });
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}
window.signMessage = signMessage; // Expose the function to Dart

async function getOtherLogins() {
  try {
    const logins = aioha.getOtherLogins();
    const userIds = Object.keys(logins);
    return userIds;
  } catch (e) {
    console.error("Failed to fetch other logged-in users", e);
    return [];
  }
}
window.getOtherLogins = getOtherLogins; // Expose the function to Dart

async function switchUser(userId) {
  try {
    const otherLogins = await getOtherLogins();
    console.log("Available users to switch:", otherLogins);

    if (!otherLogins.includes(userId)) {
      console.error("User not found in the list of logged-in users");
      return false;
    }

    const result = await aioha.switchUser(userId);
    console.log("Switch user result:", result);
    console.log("Switched to username:", userId); // Print switched username
    return result || false; // Ensure a valid boolean is returned
  } catch (e) {
    console.error("Switch failed", e);
    return false;
  }
}
window.switchUser = switchUser; // Expose the function to Dart

async function removeOtherLogin(userId) {
  try {
    const otherLogins = await getOtherLogins();
    if (!otherLogins.includes(userId)) {
      return JSON.stringify({ error: "User does not exist" });
    }
    const result = aioha.removeOtherLogin(userId);
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}
window.removeOtherLogin = removeOtherLogin; // Expose the function to Dart

async function addAccountAuthority(account, keyType, weight) {
  try {
    const result = await aioha.addAccountAuthority(account, keyType, weight);
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}
window.addAccountAuthority = addAccountAuthority;

async function removeAccountAuthority(account, keyType) {
  try {
    const result = await aioha.removeAccountAuthority(account, keyType);
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}
window.removeAccountAuthority = removeAccountAuthority;

async function transfer(recipient, amount, assetSymbol, memo) {
  try {
    const currentUser = aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }

    let assetEnum;
    if (assetSymbol === 'HIVE') {
      assetEnum = Asset.HIVE;
    } else if (assetSymbol === 'HBD') {
      assetEnum = Asset.HBD;
    } else {
      return JSON.stringify({ error: "Invalid asset type. Must be HIVE or HBD." });
    }

    const numericAmount = parseFloat(amount);
    if (isNaN(numericAmount) || numericAmount <= 0) {
      return JSON.stringify({ error: "Invalid amount. Amount must be a positive number." });
    }

    let result;
    if (memo && memo.trim() !== '') {
      result = await aioha.transfer(recipient, numericAmount, assetEnum, memo);
    } else {
      result = await aioha.transfer(recipient, numericAmount, assetEnum);
    }
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.message || error.toString() });
  }
}
window.transfer = transfer;

async function signAndBroadcastTx(operations, keyType) {
  try {
    operations = JSON.parse(operations);
    if (!Array.isArray(operations) || operations.length === 0) {
      return JSON.stringify({
        success: false,
        error: "Operations array is required",
      });
    }

    let keytypeForTx;
    if (keyType === "active" || keyType === KeyTypes.Active) {
      keytypeForTx = KeyTypes.Active;
    } else if (keyType === "posting" || keyType === KeyTypes.Posting) {
      keytypeForTx = KeyTypes.Posting;
    } else {
      return JSON.stringify({
        success: false,
        error: "KeyType must be 'posting' or 'active'",
      });
    }

    const result = await aioha.signAndBroadcastTx(operations, keytypeForTx);

    // Assuming `result` is already a JSON-compatible object
    return JSON.stringify({ success: true, result });
  } catch (error) {
    return JSON.stringify({
      success: false,
      error: error?.message || error.toString(),
    });
  }
}

window.signAndBroadcastTx = signAndBroadcastTx;

async function getCommunitySubscribers(community, limit = 100, last = null) {
  const params = {
    community,
    limit,
    last,
  };
  try {
    const result = await dhiveClient.call(
      "bridge",
      "list_subscribers",
      params
    );
    // result is an array of arrays, return as JSON string
    return JSON.stringify(result);
  } catch (error) {
    console.error("Error calling list_subscribers:", error);
    return JSON.stringify([]);
  }
}
window.getCommunitySubscribers = getCommunitySubscribers;

async function getActiveVotes(author, permlink) {
  try {
    const result = await dhiveClient.call(
      "condenser_api",
      "get_active_votes",
      [author, permlink]
    );
    return JSON.stringify(result);
  } catch (error) {
    console.error("Error calling get_active_votes:", error);
    return JSON.stringify([]);
  }
}
window.getActiveVotes = getActiveVotes;

async function getFollowingsData(username, start = "", type = "blog", limit = 1000) {
  try {
    let followings = [];
    let hasMore = true;
    let lastFollowing = start;

    while (hasMore) {
      const result = await dhiveClient.call(
        'condenser_api',
        'get_following',
        [username, lastFollowing, type, limit]
      );

      followings = [...followings, ...result];

      if (result.length < limit) {
        hasMore = false;
      } else {
        lastFollowing = result[result.length - 1].following;
      }
    }

    return JSON.stringify({
      followings,
      count: followings.length
    });
  } catch (error) {
    console.error('Error fetching followings:', error);
    return JSON.stringify({ error: error.message });
  }
}

window.getFollowingsData = getFollowingsData;


async function getFollowersData(username, start = "", type = "blog", limit = 1000) {
  try {
    let followers = [];
    let hasMore = true;
    let lastFollower = start;

    while (hasMore) {
      const result = await dhiveClient.call(
        'condenser_api',
        'get_followers',
        [username, lastFollower, type, limit]
      );

      followers = [...followers, ...result];

      if (result.length < limit) {
        hasMore = false;
      } else {
        lastFollower = result[result.length - 1].follower;
      }
    }

    const data = {
      followers: followers,
      count: followers.length
    };
    return JSON.stringify(data);
  } catch (error) {
    console.error('Error fetching followers:', error);
    return JSON.stringify({ error: error.message });
  }
}

window.getFollowersData = getFollowersData;


async function getWitnessVotesData(username) {
  try {
    const accounts = await dhiveClient.database.getAccounts([username]);
    if (accounts && accounts.length > 0) {
      const data = {
        "witness_votes": accounts[0].witness_votes || [],
        "witnesses_voted_for": accounts[0].witnesses_voted_for || 0
      };
      return JSON.stringify(data);
    }
    return JSON.stringify({ "witness_votes": [], "witnesses_voted_for": 0 });
  } catch (error) {
    console.error("Error fetching witness votes:", error);
    return JSON.stringify({ "witness_votes": [], "witnesses_voted_for": 0 });
  }
}
window.getWitnessVotesData = getWitnessVotesData;

async function isHiveKeychainAvailable() {
  try {
    return aioha.isProviderEnabled(Providers.Keychain);
  } catch (error) {
    return false;
  }
}
window.isHiveKeychainAvailable = isHiveKeychainAvailable;

async function getAccountHistory(account, index = -1, limit = 1000, start = null, stop = null) {
  const params = [account, index, limit];

  if (start !== null && stop !== null) {
    params.push(start, stop);
  }

  try {
    const result = await dhiveClient.call(
      "condenser_api",
      "get_account_history",
      params
    );
    return JSON.stringify(result);
  } catch (error) {
    console.error("Error calling get_account_history:", error);
    return JSON.stringify([]);
  }
}
window.getAccountHistory = getAccountHistory;

async function subscribeUnsubscribeToCommunity(community, subscribe) {
  try {
    const result = await aioha.customJSON(KeyTypes.Posting, 'community', [subscribe ? 'subscribe': 'unsubscribe', {community: community}], 'Display Title')
    var dataToReturn = JSON.stringify(result);
    return dataToReturn;
  } catch (error) {
    console.error("Error calling get_active_votes:", error);
    throw error;
  }
}
window.subscribeUnsubscribeToCommunity = subscribeUnsubscribeToCommunity;

async function getWalletDataDetail(username) {
  try {
    const accounts = await dhiveClient.database.getAccounts([username]);
    if (!accounts || accounts.length === 0) {
      throw new Error('Account not found');
    }
    return JSON.stringify(accounts[0]);
  } catch (error) {
    console.error('Error:', error);
    return JSON.stringify({ error: error.message });
  }
}
window.getWalletDataDetail = getWalletDataDetail;

async function convertVestingSharesToHiveData(vestingShares) {
  try {
    const props = await dhiveClient.database.getDynamicGlobalProperties();
    const vestingSharesFloat = parseFloat(vestingShares.split(' ')[0]);
    const totalVestingShares = parseFloat(props.total_vesting_shares.split(' ')[0]);
    const totalVestingFundHive = parseFloat(props.total_vesting_fund_hive.split(' ')[0]);
    const hiveValue = (vestingSharesFloat * totalVestingFundHive / totalVestingShares).toFixed(3);
    return hiveValue;
  } catch (error) {
    console.error('Error:', error);
    return '0';
  }
}
window.convertVestingSharesToHiveData = convertVestingSharesToHiveData;

async function convertHivetoUSDData(hiveAmount) {
  try {
    const feedHistory = await dhiveClient.database.call('get_feed_history', []);
    const currentMedian = feedHistory.current_median_history;
    const baseAmount = parseFloat(currentMedian.base.split(' ')[0]);
    const hiveAmountFloat = parseFloat(hiveAmount);
    const usdValue = (baseAmount * hiveAmountFloat).toFixed(2);
    return usdValue;
  } catch (error) {
    console.error('Error:', error);
    return '0';
  }
}
window.convertHivetoUSDData = convertHivetoUSDData;

async function getFullWalletData(username) {
  try {
    const accountJson = await window.getWalletDataDetail(username);
    const account = JSON.parse(accountJson);

    if (!account || account.error) {
      throw new Error(account?.error || 'Account not found');
    }

    const vestingShares = account.vesting_shares || "0.000000 VESTS";
    const balance = account.balance || "0.000 HIVE";
    const hbdBalance = account.hbd_balance || "0.000 HBD";
    const savingsBalance = account.savings_balance || "0.000 HIVE";
    const savingsHbdBalance = account.savings_hbd_balance || "0.000 HBD";

    // Convert vesting shares to Hive Power
    const hivePower = await window.convertVestingSharesToHiveData(vestingShares);

    // Parse numbers for liquid and staked hive
    const liquidHive = parseFloat(balance.split(' ')[0] || "0") || 0;
    const stakedHive = parseFloat(hivePower) || 0;
    const totalHive = (liquidHive + stakedHive).toFixed(3);

    // Convert total hive to USD
    const estimatedHiveUSD = await window.convertHivetoUSDData(totalHive);

    // Construct final object
    const walletData = {
      balance: balance,
      hbd_balance: hbdBalance,
      savings_balance: savingsBalance,
      savings_hbd_balance: savingsHbdBalance,
      hive_power: `${hivePower} HP`,
      estimated_value: `$${estimatedHiveUSD}`
    };

    return JSON.stringify(walletData);
  } catch (error) {
    console.error('Error in getFullWalletData:', error);
    return JSON.stringify({
      balance: "0.000 HIVE",
      hbd_balance: "0.000 HBD",
      savings_balance: "0.000 HIVE",
      savings_hbd_balance: "0.000 HBD",
      hive_power: "0 HP",
      estimated_value: "$0.00",
      error: error.message
    });
  }
}
window.getFullWalletData = getFullWalletData;
async function getWitnessesByVote(startAt = "", limit = 60) {
  try {
    const witnesses = await dhiveClient.call(
      "condenser_api",
      "get_witnesses_by_vote",
      [startAt, limit]
    );

    const usernames = witnesses.map(w => w.owner);

    const accounts = await dhiveClient.call(
      "condenser_api",
      "get_accounts",
      [usernames]
    );

    return JSON.stringify(accounts);
  } catch (error) {
    console.error("Error calling getWitnessesByVote:", error);
    return JSON.stringify([]);
  }
}
window.getWitnessesByVote = getWitnessesByVote;
async function listProposals(
  start = [-1],
  limit = 500,
  order = "by_total_votes",
  order_direction = "descending",
  status = "votable"
) {
  const params = {
    start,
    limit,
    order,
    order_direction,
    status,
  };

  try {
    const result = await dhiveClient.call(
      "database_api",
      "list_proposals",
      params
    );
    return JSON.stringify(result);
  } catch (error) {
    console.error("Error calling list_proposals:", error);
    return JSON.stringify([]);
  }
}
window.listProposals = listProposals;

async function getContent(author, permlink) {
  try {
    const result = await dhiveClient.call('condenser_api', 'get_content', [author, permlink]);
    return JSON.stringify(result);
  } catch (error) {
    console.error('Error fetching content:', error);
  }
}
window.getContent = getContent;