from fastapi import FastAPI

app = FastAPI()

@app.get("/title")
def title():
    return {"message": "ResMed"}