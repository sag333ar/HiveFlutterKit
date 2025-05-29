const { initAioha, KeyTypes, Providers } = require("@aioha/aioha");
const { PlaintextKeyProvider } = require("@aioha/aioha/build/providers/custom/plaintext.js");
const dhive = require('@hiveio/dhive');

let dhiveClient = new dhive.Client(["https://api.hive.blog"]);
const aioha = initAioha({
  hiveauth: {
    name: "AiohaExperiments",
    description: "Testing aioha login - keychain & hiveauth methods",
  },
});

aioha.on("hiveauth_challenge_request", (payload, evt, cancel) => {
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
  tag = '',
  startAuthor = null,
  startPermlink = null,
  observer = null,
) {
  const query = {
    sort: by,
    tag: tag,
    limit: limit,
    start_author: startAuthor,
    start_permlink: startPermlink,
  };

  if (observer) query.observer = observer;
  const discussions = await dhiveClient.call('bridge', 'get_ranked_posts', query);
  return JSON.stringify(discussions);
}
window.getDiscussions = getDiscussions;

async function getListOfCommunities(last, limit = 20, query = '', observer = null) {
  const params = {
    limit: limit,
  };

  if (last && last.trim() !== '') {
    params.last = last;
  }

  if (query && query.trim() !== '') {
    params.query = query;
  }

  if (observer !== null && observer !== undefined) {
    params.observer = observer;
  }

  try {
    const listOfCommunities = await dhiveClient.call('bridge', 'list_communities', params);
    return JSON.stringify(listOfCommunities);
  } catch (error) {
    console.error('Error calling list_communities:', error);
    return JSON.stringify([]);
  }
}
window.getListOfCommunities = getListOfCommunities;

async function getCommentsList(author, permlink) {
  const params = {
    author: author,
    permlink: permlink,
  };

  const discussion = await dhiveClient.call('bridge', 'get_discussion', params);
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
  observer = null,
) {
  const query = {
    account: username,
    sort: by,
    limit: limit,
    start_author: startAuthor,
    start_permlink: startPermlink,
  };

  if (observer) query.observer = observer;
  const discussions = await dhiveClient.call('bridge', 'get_account_posts', query);
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
window.getCurrentUser = getCurrentUser; // Expose the function to Dart

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
    return JSON.stringify(result);
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