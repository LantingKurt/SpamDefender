from flask import Flask, request, jsonify
import joblib

app = Flask(__name__)

# Load the trained spam detection model
spam_model = joblib.load('assets/spam_model.pkl')

# Load the vectorizer that was used during training
vectorizer = joblib.load('assets/vectorizer.pkl')

@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    message = data.get('message', '')

    if not message:
        return jsonify({'error': 'No message provided'}), 400

    # Transform the message using the vectorizer
    message_vectorized = vectorizer.transform([message])

    # Predict if the message is spam
    prediction = spam_model.predict(message_vectorized)[0]
    is_spam = bool(prediction == 1)  # Convert to native Python bool

    return jsonify({'is_spam': is_spam})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
