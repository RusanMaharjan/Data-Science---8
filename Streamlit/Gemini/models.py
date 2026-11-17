# Model
import os
from google import genai

gemini_api_key = os.getenv('GEMINI_API_KEY')

client = genai.Client(api_key = gemini_api_key)

def gemini(prompt):
    interation = client.interactions.create(
        model = "gemini-3.6-flash",
        input = prompt
    )
    return interation.output_text