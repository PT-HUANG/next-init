#!/bin/bash

CONFIG_PATH="next.config.ts"

cat > "$CONFIG_PATH" << 'EOF'
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
};

export default nextConfig;
EOF
