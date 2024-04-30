from fastapi import FastAPI
from inference_onnx import ColaONNXPredictor

app = FastAPI(title="MLOps Basics App")

# HACK
root_dir = "outputs/2024-04-28/07-11-42"
model_path = f"{root_dir}/models/model.onnx"
predictor = ColaONNXPredictor(model_path)


@app.get("/")
async def home_page():
    return "<h2>Sample prediction API</h2>"


@app.get("/predict")
async def get_prediction(text: str):
    result = predictor.predict(text)
    return result
