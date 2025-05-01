let aioha = null;
let qrString = "";

function setupAioha() {
  if (aioha === null) {
    aioha = window.Aioha.initAioha({
      hiveauth: {
        name: "AiohaExperiments",
        description: "Testing aioha login - keychain & hiveauth methods",
      },
    });
  }
  aioha.on("hiveauth_challenge_request", (payload, evt, cancel) => {
    qrString = payload;
  });
}

async function loginWithKeychain(username) {
  setupAioha();
  qrString = "";
  const proof = parseInt(new Date().getTime() / 1000);
  const login = await aioha.login(window.Aioha.Providers.Keychain, username, {
    msg: `${proof}`,
    keyType: window.Aioha.KeyTypes.Posting,
  });
  if (login.error && login.error !== "Already logged in") {
    qrString = "";
    throw new Error("Login Error " + login.error);
    return;
  } else if (login.error === "Already logged in") {
    aioha.switchUser(username);
    const signedResult = await aioha.signMessage(
      `${proof}`,
      window.Aioha.KeyTypes.Posting
    );
    if (signedResult.error) {
      qrString = "";
      throw new Error("Signing Error " + signedResult.error);
      return;
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

async function loginWithHiveAuth(username, message) {
  setupAioha();
  qrString = "";
  const proof = parseInt(new Date().getTime() / 1000);
  const login = await aioha.login(window.Aioha.Providers.HiveAuth, username, {
    msg: `${proof}`,
    keyType: window.Aioha.KeyTypes.Posting,
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
      window.Aioha.KeyTypes.Posting
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


async function getQrString() {
  return qrString;
}

async function getCurrentUser() {
  try {
    setupAioha();
    if (!aioha) {
      return JSON.stringify({ error: "Aioha is not initialized" });
    }
    const currentUser = await aioha.getCurrentUser();
    if (currentUser) {
      return JSON.stringify(currentUser);
    } else {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}


async function logoutUser() {
  try {
    setupAioha();
    if (!aioha) {
      return JSON.stringify("Aioha is not initialized");
    }
    const currentUser = await aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify("No user is currently logged in");
    }
    const logoutResult = await aioha.logout();
    return JSON.stringify(logoutResult);
  } catch (error) {
    return JSON.stringify(error.toString());
  }
}

async function singleVote(author, permlink, weight) {
  try {
    setupAioha();
    if (!aioha) {
      return JSON.stringify({ error: "Aioha is not initialized" });
    }
    const currentUser = await aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
    const result = await aioha.vote(author, permlink, weight);
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}

async function comment(
  parentAuthor,
  parentPermlink,
  permlink,
  title,
  body,
  jsonMetadata
) {
  try {
    setupAioha();
    if (!aioha) {
      return JSON.stringify({ error: "Aioha is not initialized" });
    }
    const currentUser = await aioha.getCurrentUser();
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
    setupAioha();
    if (!aioha) {
      return JSON.stringify({ error: "Aioha is not initialized" });
    }
    const currentUser = await aioha.getCurrentUser();
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

async function deleteComment(permlink) {
  try {
    setupAioha();
    if (!aioha) {
      return JSON.stringify({ error: "Aioha is not initialized" });
    }
    const currentUser = await aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
    const result = await aioha.deleteComment(permlink);
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}

async function reblog(author, permlink, reblogFlag) {
  try {
    setupAioha();
    if (!aioha) {
      return JSON.stringify({ error: "Aioha is not initialized" });
    }
    const currentUser = await aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
    const result = await aioha.reblog(author, permlink, reblogFlag);
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}

async function follow(author, followFlag) {
  try {
    setupAioha();
    if (!aioha) {
      return JSON.stringify({ error: "Aioha is not initialized" });
    }
    const currentUser = await aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
    const result = await aioha.follow(author, followFlag);
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}

async function claimRewards() {
  try {
    setupAioha();
    if (!aioha) {
      return JSON.stringify({ error: "Aioha is not initialized" });
    }
    const currentUser = await aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
    const result = await aioha.claimRewards();
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}

async function signMessage(message, keyType) {
  try {
    setupAioha();
    if (!aioha) {
      return JSON.stringify({ error: "Aioha is not initialized" });
    }
    const currentUser = await aioha.getCurrentUser();
    if (!currentUser) {
      return JSON.stringify({ error: "No user is currently logged in" });
    }
    let keytypeForSignMessage = window.Aioha.KeyTypes.Posting;
    if (keyType === "active") {
      keytypeForSignMessage = window.Aioha.KeyTypes.Active;
    } else if (keyType === "memo") {
      keytypeForSignMessage = window.Aioha.KeyTypes.Memo;
    } else {
      keytypeForSignMessage = window.Aioha.KeyTypes.Posting;
    }
    const result = await aioha.signMessage(message, keytypeForSignMessage);
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}

async function getOtherLogins() {
  try {
    const logins = await aioha.getOtherLogins();
    console.log("Other logged-in users (raw):", logins);

    // Convert the object to a list of user IDs
    const userIds = Object.keys(logins);
    console.log("Other logged-in users (processed):", userIds);
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

async function removeOtherLogin(userId) {
  try {
    setupAioha();
    if (!aioha) {
      return JSON.stringify({ error: "Aioha is not initialized" });
    }
    const otherLogins = await getOtherLogins();
    if (!otherLogins.includes(userId)) {
      return JSON.stringify({ error: "User does not exist" });
    }
    const result = await aioha.removeOtherLogin(userId);
    return JSON.stringify(result);
  } catch (error) {
    return JSON.stringify({ error: error.toString() });
  }
}

document.addEventListener("DOMContentLoaded", () => {
  setupAioha();
});
