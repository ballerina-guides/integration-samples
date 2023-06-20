export interface UserContext {
    token?: string
}

export const getHttpContext = async function ({ req }) : Promise<UserContext> {
    const token = req.headers.authorization || "";
    return {
        token,
    };
}
