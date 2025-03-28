import type { NextConfig } from "next";
import "dotenv/config";

const nextConfig: NextConfig = {
  /* config options here */
  env: {
    DB_FILE_NAME: process.env.DB_FILE_NAME,
  },
  output: 'standalone',
  compiler: {
    removeConsole: false,
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

export default nextConfig;
