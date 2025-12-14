let tfliteModel = null;

async function loadTFLiteModel(path) {
    try {
        console.log("Loading TFLite model from:", path);
        tfliteModel = await tflite.loadTFLiteModel(path);
        console.log("Model loaded!");
        return true;
    } catch (e) {
        console.error("Failed to load model:", e);
        return false;
    }
}

async function runInference(imageData) {
    if (!tfliteModel) return null;

    try {
        // imageData is expected to be a flat Float32Array of 64*64*3 normalized pixels
        const inputTensor = tflite.tensor(imageData, [1, 64, 64, 3], 'float32');
        const outputTensor = tfliteModel.predict(inputTensor);
        const outputData = await outputTensor.data();
        
        // Find max
        let maxVal = -1;
        let maxIdx = -1;
        for (let i = 0; i < outputData.length; i++) {
            if (outputData[i] > maxVal) {
                maxVal = outputData[i];
                maxIdx = i;
            }
        }
        
        inputTensor.dispose();
        outputTensor.dispose();

        if (maxVal > 0.5) {
             // 65 is ASCII 'A'
            return String.fromCharCode(65 + maxIdx);
        }
        return null;

    } catch (e) {
        console.error("Inference failed:", e);
        return null;
    }
}

window.loadTFLiteModel = loadTFLiteModel;
window.runInference = runInference;
