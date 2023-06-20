export const getHttpContext = async function ({ req }) {
    const token = req.headers.authorization || "";
    return {
        token,
    };
};
