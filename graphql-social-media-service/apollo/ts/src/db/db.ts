import config from 'config';
import mysql from 'mysql2';
import { Post } from '../types/post';
import { User } from '../types/user';

interface DB_CONFIG {
    host: string;
    port: number;
    user: string;
    password: string;
    database: string;
}

const dbConfig: DB_CONFIG = config.get('db');

const dbClient = mysql.createPool({
    host: dbConfig.host,
    port: dbConfig.port,
    user: dbConfig.user,
    password: dbConfig.password,
    database: dbConfig.database
});

export const getUser = async (id: string): Promise<User> => {
    if (dbClient) {
        const query = `SELECT * FROM user WHERE id = "${id}"`;
        const [rows] = await dbClient.promise().query(query);
        if (rows[0]) {
            return rows[0];
        }
    }
}

export const getUsers = async (): Promise<User[]> => {
    if (dbClient) {
        const [rows] = await dbClient.promise().query(`SELECT * FROM user`);
        return rows.map((row: User) => {
            return {
                id: row.id,
                name: row.name,
                age: row.age
            };
        });
    }
}

export const createUser = async (id: string, name: string, age: number) => {
    if (dbClient) {
        const query = `INSERT INTO user (id, name, age) VALUES ("${id}", "${name}", "${age}")`;
        const [rows] = await dbClient.promise().query(query);
        return rows.insertId;
    }
}

export const deleteUser = async (id: string) => {
    if (dbClient) {
        const query = `DELETE FROM user WHERE id = "${id}"`;
        const [rows] = await dbClient.promise().query(query);
        if (rows.affectedRows > 0) {
            return true;
        }
    }
}

export const getPosts = async (id: string): Promise<Post[]> => {
    let query: string;
    if (id) {
        query = `SELECT * FROM post WHERE user_id = "${id}"`;
    } else {
        query = `SELECT * FROM post`;
    }
    const [rows] = await dbClient.promise().query(query);
    return rows.map(async (row: Post) => {
        return {
            id: row.id,
            title: row.title,
            content: row.content,
            user_id: row.user_id
        };
    });
}

export const getPost = async (id: string): Promise<Post> => {
    if (dbClient) {
        const query = `SELECT * FROM post WHERE id = "${id}"`;
        const [rows] = await dbClient.promise().query(query);
        if (rows[0]) {
            return {
                id: rows[0].id,
                title: rows[0].title,
                content: rows[0].content,
                user_id: rows[0].user_id
            };
        }
    }
}

export const createPost = async (id: string, user_id: string, title: string, content: string) => {
    if (dbClient) {
        const query = `INSERT INTO post (id, title, content, user_id) VALUES ("${id}", "${title}", "${content}", "${user_id}")`;
        const [rows] = await dbClient.promise().query(query);
        if (rows) {
            return id;
        }
    }
}

export const deletePost = async (id: string) => {
    if (dbClient) {
        const deleteQuery = `DELETE FROM post WHERE id = "${id}"`;
        const [deletedRows] = await dbClient.promise().query(deleteQuery);
        if (deletedRows.affectedRows > 0) {
            return deletedRows.affectedRows;
        }
    }
}
