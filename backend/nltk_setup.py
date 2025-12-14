import nltk
import os

NLTK_DATA_DIR = os.path.join(os.getcwd(), "nltk_data")

os.makedirs(NLTK_DATA_DIR, exist_ok=True)

nltk.data.path.append(NLTK_DATA_DIR)

packages = [
    "punkt",
    "averaged_perceptron_tagger",
    "stopwords",
    "wordnet",
    "omw-1.4",
]

for pkg in packages:
    nltk.download(pkg, download_dir=NLTK_DATA_DIR)
