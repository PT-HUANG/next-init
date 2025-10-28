#!/bin/bash

CONFIG_PATH="next.config.ts"

cat > "$CONFIG_PATH" << 'EOF'
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
  basePath: process.env.NEXT_PUBLIC_BASE_PATH,
  env: {},
};

export default nextConfig;
EOF
