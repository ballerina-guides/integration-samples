import { getUser } from "../db/db.js";
export async function authenticate(token) {
    if (!token) {
        throw new Error("Not authenticated");
    }
    return await authenticateUserToken(token);
}
// TODO: Using the same DB for authentication. This can be improved by using a separate DB for authentication.
export const authenticateUserToken = async function (token) {
    const user = await getUser(token);
    if (!user) {
        throw new Error("Not authenticated");
    }
};
export function authorize(token, id) {
    if (token !== id) {
        throw new Error("Not authorized");
    }
}
