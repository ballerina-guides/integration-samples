import path from "path";
import fs from "fs";
import { UserData } from "./types";

const userStore: UserData[] = [];

export function storeUsers(users: UserData[]) {
  userStore.push(...users);
}

export function pickLatestUser(): UserData {
  return userStore[userStore.length - 1];
}

export function getAllUsers(): UserData[] {
  return userStore;
}

export function deleteExtentions(errors: JSON[]): JSON[] {
  errors.forEach((failure) => {
    delete failure["extensions"];
  });
  return errors;
}

export function pickUserExecpet(id: string): UserData {
  for (let i = 0; i < userStore.length; i++) {
    if (userStore[i].id !== id) {
      return userStore[i];
    }
  }
  throw new Error("Unable to pick a user");
}

export function getGraphQlDocumentFromFile(fileName: string): string {
  const docPath = path.join(
    __dirname,
    "resources",
    "graphql-documents",
    `${fileName}.graphql`
  );
  return fs.readFileSync(docPath).toString();
}

export function getJsonContentFromFile(fileName: string): JSON {
  const jsonPath = path.join(
    __dirname,
    "resources",
    "expected-responses",
    `${fileName}.json`
  );
  return JSON.parse(fs.readFileSync(jsonPath).toString());
}
