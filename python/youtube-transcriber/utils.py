import re
from dotenv import load_dotenv
import os

def identify_platform(url):
    if 'youtube.com' in url or 'youtu.be' in url:
        return 'youtube'
    else:
        return None

def get_youtube_video_id(youtube_url):
    match = re.search(r'(?:v=|\/)([0-9A-Za-z_-]{11})', youtube_url)
    return match.group(1) if match else None

# Load environment variables from the .env file
def load_env_variables():
    # Load environment variables from the .env file
    load_dotenv()  # This will automatically load variables from a .env file into the environment
    # You can access any environment variable like this:
    # api_key = os.getenv("GROQ_API_KEY")
