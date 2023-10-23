from fastapi_mlflow.applications import build_app
from mlflow.pyfunc import load_model

model = load_model("models:/modelIris/Production")
app = build_app(model)
