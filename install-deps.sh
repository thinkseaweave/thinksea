#!/bin/bash

# Install Supabase
pnpm add @supabase/supabase-js

# Install React Router
pnpm add react-router-dom

# Install Radix UI Label (required for shadcn/ui label component)
pnpm add @radix-ui/react-label

echo "Dependencies installed successfully!"
echo ""
echo "Next steps:"
echo "1. Copy .env.example to .env and add your Supabase credentials"
echo "2. Run 'pnpm dev' to start the development server"
