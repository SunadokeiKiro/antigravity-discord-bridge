#!/bin/bash
# Bridge Startup Script for Mac mini

echo "Starting Antigravity Bridge..."
echo "Use Ctrl+C to stop."

# Prevent sleep and run the server loop
caffeinate -i /bin/bash -c '
while true; do
    echo "Starting bridge server..."
    # Try to find uv, fallback to specific path if needed
    UV_PATH="/Users/asanokaname/Library/Python/3.9/bin/uv"
    if [ -x "$UV_PATH" ]; then
        "$UV_PATH" run python main_bridge.py
    else
        echo "uv not found at $UV_PATH, trying PATH..."
        uv run python main_bridge.py
    fi
    
    echo "Server crashed or stopped. Restarting in 5 seconds..."
    sleep 5
done
'
