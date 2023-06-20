import { expect, test } from "@jest/globals";
import { request } from "graphql-request";
import config from "config";
import {
  getGraphQlDocumentFromFile,
  getJsonContentFromFile,
  storeUsers,
  pickLatestUser,
  deleteExtentions,
  pickUserExecpet,
  getAllUsers,
} from "./test_utils";
import { UsersResponse, UserPosts, UserData } from "./types";

const { port }: { port: number } = config.get("server");
const url = `http://localhost:${port}/graphql`;

test("test createUser mutation", async () => {
  const document = getGraphQlDocumentFromFile("create-users-mutation");
  const response: JSON = await request(url, document);
  const expectedResponse = getJsonContentFromFile("create-users-mutation");
  expect(response).toEqual(expectedResponse);
});

test("test users query", async () => {
  const document = getGraphQlDocumentFromFile("users-query");
  const response: UsersResponse = await request(url, document);
  expect(response.users.length).toBeGreaterThanOrEqual(3);
  storeUsers(response.users);
});

test("test user query", async () => {
  const document = getGraphQlDocumentFromFile("user-query");
  const user = pickLatestUser();
  const variables = { id: user.id };
  const response: UsersResponse = await request(url, document, variables);
  const expectedResponse = { user: { name: user.name, age: user.age } };
  expect(response).toEqual(expectedResponse);
});

test("test createPost mutation", async () => {
  const document = getGraphQlDocumentFromFile("create-post-mutation");
  const variables = { title: "Post title", content: "Post content" };
  const user = pickLatestUser();
  const headers = { Authorization: user.id };
  const response: UsersResponse = await request(
    url,
    document,
    variables,
    headers
  );
  const expectedResponse = { createPost: { author: user, ...variables } };
  expect(response).toEqual(expectedResponse);
});

test("test post query", async () => {
  const document = getGraphQlDocumentFromFile("posts-query");
  const user = pickLatestUser();
  const variables = { id: user.id };
  const response: UsersResponse = await request(url, document, variables);
  const expectedResponse = getJsonContentFromFile("posts-query");
  expect(response).toEqual(expectedResponse);
});

test("test deletePost mutation", async () => {
  let document = getGraphQlDocumentFromFile("posts-query-with-post-id");
  const user = pickLatestUser();
  const variables = { userId: user.id };
  const response: UserPosts = await request(url, document, variables);
  expect(response.posts.length).toBeGreaterThanOrEqual(1);

  const firstPost = response.posts[0];
  document = getGraphQlDocumentFromFile("delete-post-mutation");
  const variablesForDeletePost = { postId: firstPost.id };
  const headers = { Authorization: user.id };
  const acturalResponse: JSON = await request(
    url,
    document,
    variablesForDeletePost,
    headers
  );
  const expectedResponse = { deletePost: firstPost };
  expect(acturalResponse).toEqual(expectedResponse);
});

test("test authentication failure", async () => {
  try {
    const document = getGraphQlDocumentFromFile("create-post-mutation");
    const variables = { title: "Post title", content: "Post content" };
    await request(url, document, variables);
  } catch (error) {
    const actualFailure: JSON[] = deleteExtentions(error.response.errors);
    const expectedFailure: JSON = getJsonContentFromFile(
      "authentication-failure-create-post-mutation"
    );
    expect(actualFailure).toEqual(expectedFailure);
  }

  try {
    const document = getGraphQlDocumentFromFile("delete-user-mutation");
    const user = pickLatestUser();
    const variables = { id: user.id };
    await request(url, document, variables);
  } catch (error) {
    const actualFailure: JSON[] = deleteExtentions(error.response.errors);
    const expectedFailure: JSON = getJsonContentFromFile(
      "authentication-failure-delete-user-mutation"
    );
    expect(actualFailure).toEqual(expectedFailure);
  }

  try {
    const document = getGraphQlDocumentFromFile("delete-post-mutation");
    const headers = { Authorization: "" };
    const variables = { postId: "" };
    await request(url, document, variables, headers);
  } catch (error) {
    const actualFailure: JSON[] = deleteExtentions(error.response.errors);
    const expectedFailure: JSON = getJsonContentFromFile(
      "authentication-failure-delete-post-mutation"
    );
    expect(actualFailure).toEqual(expectedFailure);
  }
});

test("test authorization failure", async () => {
  try {
    const document = getGraphQlDocumentFromFile("delete-user-mutation");
    const user = pickLatestUser();
    const variables = { id: user.id };
    const differentUser = pickUserExecpet(user.id);
    const headers = { Authorization: differentUser.id };
    await request(url, document, variables, headers);
  } catch (error) {
    const actualFailure: JSON[] = deleteExtentions(error.response.errors);
    const expectedFailure = getJsonContentFromFile(
      "authorization-failure-delete-user-mutation"
    );
    expect(actualFailure).toEqual(expectedFailure);
  }
});

test("test deleteUser Mutation", async () => {
  const document = getGraphQlDocumentFromFile("delete-user-mutation");
  const users: UserData[] = getAllUsers();
  users.forEach(async (user) => {
    const variables = { id: user.id };
    const headers = { Authorization: user.id };
    const response: JSON = await request(url, document, variables, headers);
    const expectedResponse = { deleteUser: user };
    expect(response).toEqual(expectedResponse);
  });
});
