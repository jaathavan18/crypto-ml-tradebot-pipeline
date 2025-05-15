#!/bin/bash

echo "=========================="
echo "📦 Docker Containers Status"
echo "=========================="
docker ps --format "table {{.Names}}\t{{.Status}}"

echo
echo "=========================="
echo "🖥️ Tmux Sessions Status"
echo "=========================="

for container in streamlit_app realtime candle_maker predict trade_bot train; do
  echo "-- $container --"
  docker exec -it $container bash -c "tmux ls" 2>/dev/null || echo "No tmux session running."
  echo
done

echo "=========================="
echo "⏰ Cron Jobs in trade_bot"
echo "=========================="
docker exec -it trade_bot crontab -l 2>/dev/null || echo "No crontab set in trade_bot."

echo
echo "=========================="
echo "⏰ Cron Jobs in train"
echo "=========================="
docker exec -it train crontab -l 2>/dev/null || echo "No crontab set in train."

echo
echo "=========================="
echo "🌐 Exposed Ports Health Check"
echo "=========================="
for port in 18081 18082 19092 9644 8080 8501; do
  echo -n "Port $port: "
  if nc -z localhost $port; then
    echo "OPEN"
  else
    echo "CLOSED"
  fi
done

echo
echo "✅ All checks complete."