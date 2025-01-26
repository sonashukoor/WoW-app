from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np
import os
import firebase_admin
from firebase_admin import credentials, firestore
import uuid  # Importing uuid module for unique ID generation

# Initialize Firebase
firebase_key_path = os.path.join(os.getcwd(), "firebase_key.json")
try:
    cred = credentials.Certificate(firebase_key_path)
    firebase_admin.initialize_app(cred)
    db = firestore.client()  # Initialize Firestore
    print("Firebase initialized successfully.")
except Exception as e:
    print(f"Error initializing Firebase: {e}")
    db = None

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
        required_fields = ["gender", "age", "occupation", "sleep_duration", "bmi_category", "heart_rate", "daily_steps", "systolic_bp"]
        if not all(k in data for k in required_fields):
            return jsonify({"error": "Missing required input fields"}), 400

        # Generate a unique ID for this prediction request
        request_id = str(uuid.uuid4())  # This creates a unique identifier

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
            prediction = model.predict(input_data)[0]
            print(f"Prediction: {prediction}")  # Debugging: print prediction result

            # Save prediction to Firestore with unique request_id
            if db:
                db.collection("predictions").document(request_id).set({
                    "input_data": data,
                    "prediction": str(prediction),
                    "request_id": request_id  # Store the unique request ID
                })
                print("Prediction saved to Firestore.")

            # Return the prediction and request_id to the client
            return jsonify({"request_id": request_id, "prediction": str(prediction)})  # Include the request_id in the response
        else:
            return jsonify({"error": "Model is not loaded properly"}), 500

    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
