#!/usr/bin/env python
import sys
import pytesseract
from PIL import Image

# Set Tesseract path
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

def extract_text(image_path):
    try:
        # Open image file
        image = Image.open(image_path)
        
        # Convert to RGB if needed
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Extract text
        text = pytesseract.image_to_string(image)
        return text
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        return ""

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python extract_text.py <image_path>")
        sys.exit(1)

    image_path = sys.argv[1]
    result = extract_text(image_path)
    print(result)