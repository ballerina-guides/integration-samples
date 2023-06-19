/** @type {import('ts-jest').JestConfigWithTsJest} */
export default {
  preset: "ts-jest",
  testEnvironment: "node",
  modulePathIgnorePatterns: [
    "dist",
    "ts/__tests__/types.ts",
    "ts/__tests__/test_utils.ts",
  ],
};
