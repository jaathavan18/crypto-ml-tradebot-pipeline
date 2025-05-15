#!/bin/bash
echo "Stopping all running containers..."
docker compose down

# Short pause to ensure all processes release file locks
echo "Waiting for file locks to be released..."
sleep 5

echo "Checking for lock files..."
docker run --rm -v $(pwd)/data:/data busybox ls -la /data/

echo "Attempting to remove lock files if they exist..."
docker run --rm -v $(pwd)/data:/data busybox rm -f /data/crypto.duckdb.lock /data/*.lock 2>/dev/null || true

echo "Rebuilding Docker images..."
docker compose build

echo "Starting containers fresh..."
docker compose up -d

# Ensure database is accessible before starting services that depend on it
echo "Ensuring database is ready..."
sleep 5

echo "Starting realtime data fetcher..."
docker exec -it realtime bash -c "tmux new -d -s realtime_session 'python fetch_realtime_data.py'"

echo "Starting candle maker..."
docker exec -it candle_maker bash -c "tmux new -d -s candle_session 'python candle_maker.py'"

echo "Starting predictor..."
docker exec -it predict bash -c "tmux new -d -s predict_session 'python process_candle.py'"

echo "Adding trade_bot cron job..."
docker exec -it trade_bot bash -c "(crontab -l 2>/dev/null; echo '*/5 * * * * sleep 30; /usr/local/bin/python /app/trade_bot.py >> /var/log/container.log 2>&1') | crontab -"

echo "Adding train cron job..."
docker exec -it train bash -c "(crontab -l 2>/dev/null; echo '50 * * * * sleep 30; /usr/local/bin/python /app/train.py >> /var/log/container.log 2>&1') | crontab -"

# Start Streamlit with read-only mode as a fallback
echo "Starting Streamlit app (with read-only fallback if needed)..."
docker exec -it streamlit_app bash -c "tmux new -d -s streamlit_session 'sed -i \"s/duckdb.connect(DUCKDB_FILE)/duckdb.connect(DUCKDB_FILE, read_only=True)/g\" /app/streamlit_app.py || true; streamlit run streamlit_app.py'"

echo "Everything's clean and started!"
echo "Visit your Streamlit app at http://http://159.203.173.237:8501"