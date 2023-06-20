import { randomUUID } from "crypto";
import { createPost, getPosts, getPost, getUser, getUsers, deletePost, deleteUser, createUser } from "../db/db.js";
import { Post } from "../types/post.js";
import { User } from "../types/user.js";
import { UserContext } from "../utils.js";
import { authenticate, authorize } from "../auth/auth.js";
import { publishPost, subscribePost } from "../kafka_utils.js";

export const resolvers = {
    Query: {
        users: async () => getUsers(),
        user: async (_parent: any, { id }) => getUser(id),
        posts: async (_parent: any, { id }) => getPosts(id)
    },

    Mutation: {
        createUser: async (_parent: any, { user: { name, age } }) => {
            const id = randomUUID();
            await createUser(id, name, age);
            return await getUser(id);
        },

        deleteUser: async (_parent: any, { id }, { token }: UserContext) => {
            await authenticate(token);
            authorize(token, id);
            const user = await getUser(token);
            if (user) {
                await deleteUser(id);
                return user;
            }
            throw new Error("User not found");
        },

        createPost: async (_parent: any, { newPost: { title, content } }, { token }: UserContext) => {
            await authenticate(token);
            const id = randomUUID();
            await createPost(id, token, title, content);
            const post = await getPost(id);
            await publishPost(post);
            return post;
        },

        deletePost: async (_parent: any, { id }, { token }: UserContext) => {
            await authenticate(token);
            const post = await getPost(id);
            if (!post) {
                throw new Error("Post not found");
            }
            authorize(token, post.user_id);
            const deleted = await deletePost(id);
            if (deleted) {
                return post;
            } else {
                throw new Error("Post not found");
            }
        }
    },

    Subscription: {
        newPosts: {
            subscribe: () => {
                // Create unique ID for the subscription
                const uuid = randomUUID()
                return subscribePost(uuid);
            }
        }
    },

    User: {
        posts: async (parent: User) => {
            return await getPosts(parent.id);
        }
    },

    Post: {
        author: async (parent: Post) => {
            const user = await getUser(parent.user_id);
            return user;
        }
    }
};
