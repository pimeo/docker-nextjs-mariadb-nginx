// @ts-check

require("dotenv/config");

/** @type {import('next').NextConfig} */
const nextConfig = {
  /* config options here */
  env: {
    DB_FILE_NAME: process.env.DB_FILE_NAME,
    MARIADB_DATABASE: process.env.MARIADB_DATABASE,
  },
  output: "standalone",
  compiler: {
    removeConsole:
      process.env.NODE_ENV === "production" ? { exclude: ["error"] } : false,
    // removeConsole: false,
    // removeConsole: process.env.NODE_ENV === 'production',
  },
  experimental: {
    turbo: {
      rules: {
        "*.svg": {
          loaders: ["@svgr/webpack"],
          as: "*.js",
        },
      },
    },
  },
};

module.exports = nextConfig;
