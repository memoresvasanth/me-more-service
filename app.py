from fastapi import FastAPI

app = FastAPI()

@app.get("/title-of-the-page")
def title():
    return {"message": "ResMed"}