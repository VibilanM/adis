from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import time
import random
from datetime import datetime

app = FastAPI(title="ADIS Mock Server")

# --- Models ---
class TimerStart(BaseModel):
    duration: int

class Task(BaseModel):
    title: str
    time: str

# --- State ---
class SystemState:
    def __init__(self):
        self.screen = "HOME"
        self.status = "GOOD"
        self.message = "System Online"
        self.timer_end = 0
        self.tasks = []

state = SystemState()

# --- Helpers ---
def update_posture():
    """Simulate posture changes randomly for testing."""
    choices = [
        ("GOOD", "Excellent posture!"),
        ("GOOD", "Keep it up."),
        ("BAD", "Slouching detected!"),
        ("BAD", "Please sit straight."),
    ]
    if random.random() < 0.1: # 10% chance to change per request
        state.status, state.message = random.choice(choices)

# --- Endpoints ---

@app.get("/state")
async def get_state():
    update_posture()
    return {
        "screen": state.screen,
        "status": state.status,
        "message": state.message
    }

@app.post("/timer/start")
async def start_timer(timer_data: TimerStart):
    state.timer_end = time.time() + timer_data.duration
    state.message = f"Timer started for {timer_data.duration}s"
    print(f"Timer started: {timer_data.duration} seconds")
    return {"status": "ok"}

@app.post("/timer/stop")
async def stop_timer():
    state.timer_end = 0
    state.message = "Timer stopped"
    print("Timer stopped")
    return {"status": "ok"}

@app.post("/task")
async def add_task(task: Task):
    state.tasks.append(task.dict())
    state.message = f"Task added: {task.title}"
    print(f"New Task: {task.title} at {task.time}")
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    # In a real scenario, you'd find your local IP and use it here
    print("\n" + "="*50)
    print("ADIS MOCK SERVER")
    print("Run this to test your Flutter app!")
    print("="*50 + "\n")
    uvicorn.run(app, host="0.0.0.0", port=8000)
