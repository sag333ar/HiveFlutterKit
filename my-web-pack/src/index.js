const { Aioha, initAioha, KeyTypes, Providers } = require('@aioha/aioha')
const { PlaintextKeyProvider } = require('@aioha/aioha/build/providers/custom/plaintext.js')

const aioha = initAioha({
  hiveauth: {
    name: 'AiohaExperiments',
    description: 'Testing aioha login - keychain & hiveauth methods'
  },
})

aioha.on("hiveauth_challenge_request", (payload, evt, cancel) => {
  qrString = payload;
});

let qrString = "";

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
    const signedResult = await aioha.signMessage(
      `${proof}`,
      KeyTypes.Posting
    );
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
    const signedResult = await aioha.signMessage(
      `${proof}`,
      KeyTypes.Posting
    );
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

window.loginWithHiveAuth = loginWithHiveAuth; // Expose the function to Dart

async function loginWithPlaintextKey(username, postingKey, proof) {
  if (proof === undefined || proof === null || proof === "") {
    proof = parseInt(new Date().getTime() / 1000);
  }
  try {
    const aioha = new Aioha();
    aioha.registerCustomProvider(new PlaintextKeyProvider.PlaintextKeyProvider(postingKey));
    const login = await aioha.login(Providers.Custom, username, {
      msg: proof,
      keyType: "posting",
    });

    if (login?.error) {
      throw new Error("Login Error: " + login.error);
    }

    return JSON.stringify({
      ...login,
      username,
      proof,
      method: "PlaintextKey",
    });

  } catch (error) {
    console.error("PlaintextKey login failed:", error.message);
    throw error;
  }
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
      jsonMetadata,
      options
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

    const result = aioha.switchUser(userId);
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