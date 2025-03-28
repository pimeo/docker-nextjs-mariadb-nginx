import { defineConfig } from "drizzle-kit";
import nextConfig from "./next.config";

const dbFileName = nextConfig?.env?.DB_FILE_NAME;
if (!dbFileName) {
  throw Error("Sqlite database path not set");
}

export default defineConfig({
  schema: "./src/drizzle/schema",
  out: "./src/drizzle/migrations",
  dialect: "sqlite",
  dbCredentials: {
    url: dbFileName,
  },
  verbose: true,
});
