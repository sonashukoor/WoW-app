from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np
import os

# Define the model path
model_path = os.path.join(os.getcwd(), "random_forest_model.pkl")

# Load the model
try:
    model = joblib.load(model_path)
    print("Model loaded successfully.")
except Exception as e:
    print(f"Error loading model: {e}")
    model = None

app = Flask(__name__)
CORS(app)

@app.route("/predict", methods=["POST"])
def predict():
    try:
        # Get input from Flutter
        data = request.get_json()
        print(f"Received data: {data}")  # Debugging: print received data

        # Check if the expected data is present
        if not all(k in data for k in ["gender", "age", "occupation", "sleep_duration", "bmi_category", "heart_rate", "daily_steps", "systolic_bp"]):
            return jsonify({"error": "Missing required input fields"}), 400

        # Prepare the input data for the model
        input_data = np.array([[data["gender"],
                                data["age"],
                                data["occupation"],
                                data["sleep_duration"],
                                data["bmi_category"],
                                data["heart_rate"],
                                data["daily_steps"],
                                data["systolic_bp"]]])

        # Make prediction
        if model:
            prediction = model.predict(input_data)
            #print(f"Prediction: {prediction}")  # Debugging: print prediction result
            return jsonify({"prediction": str(prediction[0])})  # Convert prediction to string
        else:
            return jsonify({"error": "Model is not loaded properly"}), 500

    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
