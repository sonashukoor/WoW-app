from flask import Flask, request, jsonify
import joblib
import numpy as np
import os

# Define the model path
model_path = os.path.join(os.getcwd(), "random_forest_model.pkl")

# Load the model
model = joblib.load(model_path)

app = Flask(__name__)

@app.route("/predict", methods=["POST"])
def predict():
    # Get input from Flutter
    data = request.get_json()
    input_data = np.array([[
        data["gender"],
        data["age"],
        data["occupation"],
        data["sleep_duration"],
        data["bmi_category"],
        data["heart_rate"],
        data["daily_steps"],
        data["systolic_bp"]
    ]])
    prediction = model.predict(input_data)
    return jsonify({"prediction": prediction.tolist()})

if __name__ == "__main__":
    app.run(debug=True)
