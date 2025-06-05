---
title: Use DHive
sidebar_label: Use DHive
slug: /use-dhive
---

## Use DHive

### Database API

---

#### Get Chain Properties
`getChainProperties()`

*   **Description:** Fetches dynamic global properties of the Hive blockchain.
*   **Parameters:** None.
*   **Returns:** `Future<ChainProperties>`: A future that resolves to a `ChainProperties` object containing various blockchain parameters.

---

#### Get Discussions
`getDiscussions(String by, {required int limit, String tag = '', String? startAuthor, String? startPermlink, String? observer})`

*   **Description:** Fetches a list of discussions (posts/comments) based on various criteria (e.g., trending, hot, new).
*   **Parameters:**
    *   `by` (`String`): The sorting method (e.g., "trending", "hot", "created", "feed").
    *   `limit` (required int): The maximum number of discussions to fetch.
    *   `tag` (String, optional): Filter discussions by this tag. Defaults to empty.
    *   `startAuthor` (String?, optional): For pagination, the author of the last post from the previous fetch.
    *   `startPermlink` (String?, optional): For pagination, the permlink of the last post from the previous fetch.
    *   `observer` (String?, optional): The username of the observer, to personalize results (e.g., for muted content).
*   **Returns:** `Future<List<Discussion>>`: A future that resolves to a list of `Discussion` objects.

---

#### Get Accounts
`getAccounts(List<String> usernames)`

*   **Description:** Retrieves detailed information for a list of Hive accounts.
*   **Parameters:**
    *   `usernames` (`List<String>`): A list of usernames to fetch data for.
*   **Returns:** `Future<List<Account>>`: A future that resolves to a list of `Account` objects.

---

### Helpers & Utilities

---

#### Get Voting Power
`getVotingPower(String username)`

*   **Description:** Fetches the current voting power for a specified user.
*   **Parameters:**
    *   `username` (`String`): The Hive username.
*   **Returns:** `Future<VotingPower>`: A future that resolves to a `VotingPower` object.

---

#### Get Resource Credits
`getResourceCredits(String username)`

*   **Description:** Fetches the current resource credits (RC) for a specified user.
*   **Parameters:**
    *   `username` (`String`): The Hive username.
*   **Returns:** `Future<ResourceCredits>`: A future that resolves to a `ResourceCredits` object.

---

#### Has Threespeak In Account Auths
`hasThreespeakInAccountAuths(String username)`

*   **Description:** Checks if the 'threespeak' account has been granted posting authority by the specified user. This is relevant for integrations with the 3Speak video platform.
*   **Parameters:**
    *   `username` (`String`): The Hive username to check.
*   **Returns:** `Future<bool>`: A future that resolves to `true` if 'threespeak' has posting authority, `false` otherwise.

---

### HiveMind

---

#### Get Account Posts
`getAccountPosts(String username, String by, {required int limit, String? startAuthor, String? startPermlink, String? observer})`

*   **Description:** Fetches a list of posts made by a specific account, sorted by a chosen method.
*   **Parameters:**
    *   `username` (`String`): The username whose posts are to be fetched.
    *   `by` (`String`): The sorting criteria (e.g., "blog", "feed", "posts").
    *   `limit` (required int): The maximum number of posts to fetch.
    *   `startAuthor` (String?, optional): For pagination, the author of the last post from the previous fetch (should be the same as `username`).
    *   `startPermlink` (String?, optional): For pagination, the permlink of the last post from the previous fetch.
    *   `observer` (String?, optional): The username of the observer.
*   **Returns:** `Future<List<Discussion>>`: A future that resolves to a list of `Discussion` objects representing the account's posts.

---

#### Get List Of Communities
`getListOfCommunities(String? query, {int limit = 20, String? last, String? observer})`

*   **Description:** Fetches a list of Hive communities. Can be used to search for communities or list them.
*   **Parameters:**
    *   `query` (`String?`): A search query to filter communities by name or title. `null` or empty to list communities without a specific query.
    *   `limit` (int, optional): The maximum number of communities to fetch. Defaults to 20.
    *   `last` (String?, optional): For pagination, the name of the last community from the previous fetch.
    *   `observer` (String?, optional): The username of the observer.
*   **Returns:** `Future<List<CommunityItem>>`: A future that resolves to a list of `CommunityItem` objects.

---

### Bridge

---

#### Get Comments List
`getCommentsList(String author, String permlink)`

*   **Description:** Fetches the list of comments for a specific post.
*   **Parameters:**
    *   `author` (`String`): The author of the parent post.
    *   `permlink` (`String`): The permlink of the parent post.
*   **Returns:** `Future<List<Discussion>>`: A future that resolves to a list of `Discussion` objects representing the comments.

---
