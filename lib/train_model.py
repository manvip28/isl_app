import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense
import os
import json

def load_flutter_data(file_path):
    with open(file_path, 'r') as f:
        data = json.load(f)
    return data

def process_flutter_data(data):
    vitals_data = []
    for record in data:
        vitals_data.append({
            'heartRate': record['heartRate'],
            'bloodPressureSystolic': record['bloodPressureSystolic'],
            'bloodPressureDiastolic': record['bloodPressureDiastolic'],
            'temperature': record['temperature'],
            'bloodSugar': float(record['bloodSugar'])
        })
    return vitals_data

def generate_sample_data(num_samples=50):
    vitals_data = []
    labels_general_health = []
    labels_diabetes_trend = []

    for i in range(num_samples):
        heart_rate = np.random.randint(60, 120)
        blood_pressure_systolic = np.random.randint(110, 140)
        blood_pressure_diastolic = np.random.randint(70, 90)
        temperature = round(np.random.uniform(36.5, 38.5), 1)
        blood_sugar = np.random.randint(70, 180)

        vitals_data.append({
            'heartRate': heart_rate,
            'bloodPressureSystolic': blood_pressure_systolic,
            'bloodPressureDiastolic': blood_pressure_diastolic,
            'temperature': temperature,
            'bloodSugar': blood_sugar
        })

        labels_general_health.append(np.random.choice([0, 1, 2]))
        labels_diabetes_trend.append(np.random.choice([0, 1, 2]))

    return vitals_data, labels_general_health, labels_diabetes_trend

def prepare_data_for_lstm(vitals_data, labels, sequence_length=5):
    X, y = [], []

    for i in range(len(vitals_data) - sequence_length):
        sequence_data = [
            [vitals['heartRate'], vitals['bloodPressureSystolic'],
             vitals['bloodPressureDiastolic'], vitals['temperature'],
             vitals['bloodSugar']]
            for vitals in vitals_data[i:i+sequence_length]
        ]
        X.append(sequence_data)
        if labels is not None:
            y.append(labels[i + sequence_length])

    return np.array(X), np.array(y) if labels is not None else None

def create_model(input_shape):
    model = Sequential([
        # Simpler LSTM architecture that's more TFLite friendly
        LSTM(32, input_shape=input_shape, return_sequences=False),
        Dense(16, activation='relu'),
        Dense(3, activation='softmax')
    ])
    model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
    return model

def convert_to_tflite(model, model_name):
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.experimental_enable_resource_variables = True
    converter._experimental_lower_tensor_list_ops = False
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS,
        tf.lite.OpsSet.SELECT_TF_OPS
    ]
    converter.allow_custom_ops = True
    tflite_model = converter.convert()

    os.makedirs('../assets/models', exist_ok=True)
    with open(f'../assets/models/{model_name}.tflite', 'wb') as f:
        f.write(tflite_model)

def train_and_convert():
    # Generate training data
    vitals_data, labels_health, labels_diabetes = generate_sample_data(1000)

    # Prepare data
    X, y_health = prepare_data_for_lstm(vitals_data, labels_health)
    _, y_diabetes = prepare_data_for_lstm(vitals_data, labels_diabetes)

    input_shape = (X.shape[1], X.shape[2])

    # Train health model
    health_model = create_model(input_shape)
    health_model.fit(X, y_health, epochs=10, batch_size=32)

    # Train diabetes model
    diabetes_model = create_model(input_shape)
    diabetes_model.fit(X, y_diabetes, epochs=10, batch_size=32)

    # Convert and save models
    convert_to_tflite(health_model, 'health_model')
    convert_to_tflite(diabetes_model, 'diabetes_model')

if __name__ == "__main__":
    train_and_convert()
