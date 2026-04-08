"""
Resume analysis service - extracts text and computes score (1-10).
"""
import re
from PyPDF2 import PdfReader


def extract_text_from_pdf(file) -> str:
    """Extract text from PDF file."""
    reader = PdfReader(file)
    text = ''
    for page in reader.pages:
        text += page.extract_text() or ''
    return text.strip()


def analyze_resume(file) -> tuple[int, str]:
    """
    Analyze resume file and return (score 1-10, feedback).
    Simple heuristic-based scoring - can be replaced with ML/NLP.
    """
    # Extract text from the uploaded file
    text = extract_text_from_pdf(file)

    score = 5  # Base score
    feedback_parts = []

    # Length
    word_count = len(text.split())
    if word_count < 100:
        score -= 2
        feedback_parts.append('Resume seems too short. Consider adding more details.')
    elif word_count > 500:
        score += 1
        feedback_parts.append('Good length with sufficient detail.')

    # Keywords
    keywords = ['experience', 'education', 'skills', 'project', 'achievement', 'certification']
    found = sum(1 for k in keywords if k.lower() in text.lower())
    if found >= 4:
        score += 2
        feedback_parts.append(f'Strong presence of key sections ({found}/6 found).')
    elif found < 2:
        score -= 1
        feedback_parts.append('Consider adding Experience, Education, and Skills sections.')

    # Contact info
    if re.search(r'[\w\.-]+@[\w\.-]+\.\w+', text):
        score += 1
        feedback_parts.append('Contact information present.')
    else:
        score -= 1
        feedback_parts.append('Add email address for contact.')

    # Clamp score 1-10
    score = max(1, min(10, score))
    feedback = ' '.join(feedback_parts) if feedback_parts else 'Resume reviewed.'
    return score, feedback