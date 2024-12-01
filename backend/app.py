import nltk
from flask import Flask, request, jsonify
from flask_cors import CORS
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
import string

# Initialize the Flask app first
app = Flask(__name__)
CORS(app)

# Initialize tools
lemmatizer = WordNetLemmatizer()
stop_words = set(stopwords.words('english'))

def english_to_isl(text):
    # Step 1: Tokenization
    tokens = word_tokenize(text)

    # Step 2: Remove punctuation and stop words
    filtered_tokens = [
        word.lower() for word in tokens
        if word.lower() not in stop_words
           and word not in string.punctuation
    ]

    # Step 3: Lemmatization
    lemmatized_tokens = [lemmatizer.lemmatize(word) for word in filtered_tokens]

    # Step 4: Grammar adjustment for ISL (SOV - Subject, Object, Verb order)
    tagged_tokens = nltk.pos_tag(lemmatized_tokens)
    subject, object_, verb, others = [], [], [], []

    for word, tag in tagged_tokens:
        if tag.startswith('NN'):  # Noun: Subject or Object
            if not subject:
                subject.append(word)
            else:
                object_.append(word)
        elif tag.startswith('VB'):  # Verb
            verb.append(word)
        else:
            others.append(word)  # Any other words can be added to a separate list

    # Step 5: Reconstruct the sentence in SOV order
    isl_sentence = subject + object_ + verb + others
    return " ".join(isl_sentence)

@app.route('/convert_to_isl', methods=['POST'])
def convert_to_isl():
    data = request.json
    text = data.get('text', '')
    print(f"Received text: {text}")  # Log the incoming request

    try:
        if not text:
            raise ValueError("No text provided")
        isl_output = english_to_isl(text)
        return jsonify({
            'original_text': text,
            'isl_text': isl_output
        })
    except Exception as e:
        print(f"Error: {str(e)}")  # Log the error
        return jsonify({
            'error': str(e)
        }), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
