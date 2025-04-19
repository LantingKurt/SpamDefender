from flask import Flask, request, jsonify
from transformers import DistilBertTokenizer, DistilBertForSequenceClassification
import torch

app = Flask(__name__)

# Load the tokenizer and model
tokenizer = DistilBertTokenizer.from_pretrained('distilbert-base-uncased')
model = DistilBertForSequenceClassification.from_pretrained('assets/spamdefender_ml_model/distilbert_spam_model')

@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    message = data.get('message', '')

    if not message:
        return jsonify({'error': 'No message provided'}), 400

    # Tokenize the input message
    inputs = tokenizer(message, return_tensors='pt', truncation=True, padding=True)

    # Get model predictions
    with torch.no_grad():
        outputs = model(**inputs)
        prediction = torch.argmax(outputs.logits, dim=1).item()

    is_spam = bool(prediction == 1)

    print({'is_spam': is_spam})
    return jsonify({'is_spam': is_spam})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
