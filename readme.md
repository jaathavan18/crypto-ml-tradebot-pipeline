# 📈 Cryptocurrency ML Trading Pipeline

A complete multi-container Dockerized cryptocurrency trading pipeline powered by real-time data ingestion, candle formation, model predictions, and strategy-driven trade simulations. Visualized with a Streamlit dashboard.

---

## 🐳 Setup: Docker Build & Run

### Build base image:
```bash
docker build -t ml-trading-service ./services/base
```

### Start the system:
```bash
docker-compose up -d
```

### Common Docker Commands:
```bash
# Build a Docker image
docker build -t image_name .
# Build services defined in docker-compose.yml
docker-compose build
# Start services in detached mode
docker-compose up -d
# List running services
docker-compose ps
# View logs for a specific service
docker-compose logs service_name
```

---

## 🔧 Fix Entry Permissions

Ensure all entrypoint scripts are executable:

```bash
chmod +x backfill/entrypoint.sh
chmod +x candle_maker/entrypoint.sh
chmod +x dev_box/entrypoint.sh
chmod +x predict/entrypoint.sh
chmod +x realtime/entrypoint.sh
chmod +x streamlit_app/entrypoint.sh
chmod +x trade_bot/entrypoint.sh
chmod +x train/entrypoint.sh
```

Then restart:

```bash
docker-compose down
docker-compose up -d
```

---

## 📦 Fetch Historical Data

1️⃣ Enter backfill container:

```bash
docker exec -it backfill bash
```

2️⃣ Run historical data fetch:

* **Update `fetch_historical_trade_data.py`** → set `start_timestamp = [your last known timestamp]`
* Example:

  ```python
  start_timestamp = 1746577459
  ```

3️⃣ Execute:

```bash
time python fetch_historical_trade_data.py
```

4️⃣ Update `load_historical_data_as_candles.py` with new file paths:

```python
CSV_FILES = [
  "/data/historical/kraken_trades_since_1746577459.csv",
  ...
]
```

5️⃣ Load as candles:

```bash
time python load_historical_data_as_candles.py
```

---

## 📡 Run Real-Time Data Fetch

```bash
docker exec -it realtime bash
tmux
python fetch_realtime_data.py
# (Detach tmux: Ctrl + b, then d)
```

---

## 📊 Candle Maker Service

```bash
docker exec -it candle_maker bash
tmux
python candle_maker.py
```

---

## 🧠 Prediction Service

```bash
docker exec -it predict bash
tmux
python process_candle.py
```

### Check tmux sessions:

```bash
tmux ls
tmux a -t 0  # (or whatever session number)
```

### Common Tmux Commands:
```bash
# Create a new named tmux session
tmux new -s session_name
# List all tmux sessions
tmux ls
# Attach to a named tmux session
tmux attach -t session_name
# Detach from current tmux session
tmux detach
# Kill a named tmux session
tmux kill-session -t session_name
```

---

## ⚙️ Run Trade Bot

```bash
docker exec -it trade_bot bash
python trade_bot.py
```

## 📝 Set Cron Job for Trade Bot

### Common Crontab Commands:
```bash
# Edit crontab file
crontab -e
# List crontab entries
crontab -l
# Remove crontab entries
crontab -r
# Edit crontab for a specific user
crontab -u user_name
```

Edit crontab:

```bash
crontab -e
```

Add:

```
*/5 * * * * sleep 30; /usr/local/bin/python /app/trade_bot.py >> /var/log/container.log 2>&1
```

Save and exit.

---

## 📊 Run Streamlit App

```bash
docker exec -it streamlit_app bash
tmux
streamlit run streamlit_app.py
```

Access via: `http://your-ip:8501`

---

## 📈 Update New Gap Data

1️⃣ Update `fetch_historical_trade_data.py` with the latest timestamp from your last historical file (e.g., `1747066775`)

2️⃣ Run:

```bash
time python fetch_historical_trade_data.py
```

3️⃣ Update `load_gap_data_as_candles.py` with the new CSV file path.

4️⃣ Load the new gap data:

```bash
python load_gap_data_as_candles.py
```

---

## ✅ Health Check Script

Create `status_check.sh`:

```bash
#!/bin/bash

echo "Active Containers:"
docker ps

echo "Tmux sessions:"
docker exec -it predict tmux ls
docker exec -it realtime tmux ls
docker exec -it candle_maker tmux ls

echo "Streamlit health:"
curl -Is http://localhost:8501 | head -1

echo "Cron jobs:"
crontab -l
```

Make executable:

```bash
chmod +x status_check.sh
```

Run:

```bash
./status_check.sh
```

---

## 📌 Notes

* All services are networked via `trading_network`
* Data stored in `/data/`
* Models in `/data/models/`
* Database in `/data/crypto.duckdb`
* Logs to `/var/log/`

---

## 📑 Project Structure

```
services/
  ├── base/
  ├── backfill/
  ├── candle_maker/
  ├── dev_box/
  ├── predict/
  ├── realtime/
  ├── streamlit_app/
  ├── trade_bot/
  ├── train/
data/
  ├── historical/
  ├── models/
  └── crypto.duckdb
docker-compose.yml
.gitignore
status_check.sh
README.md
```