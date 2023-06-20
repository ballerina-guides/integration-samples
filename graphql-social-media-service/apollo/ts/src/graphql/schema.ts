import { readFileSync } from 'fs';

export const typeDefs = readFileSync('./ts/src/graphql/schema.graphql', { encoding: 'utf-8' });
