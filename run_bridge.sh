#!/bin/bash
# Bridge Startup Script for Mac mini

echo "Starting Antigravity Bridge..."
echo "Use Ctrl+C to stop."

# Prevent sleep and run the server loop
caffeinate -i /bin/bash -c "
while true; do
    echo 'Starting bridge server...'
    /Users/asanokaname/.local/bin/uv run python main_bridge.py
    
    echo 'Server crashed or stopped. Restarting in 5 seconds...'
    sleep 5
done
"
