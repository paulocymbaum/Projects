from youtube_transcript_api import YouTubeTranscriptApi
from utils import get_youtube_video_id

def fetch_youtube_subtitles(video_id):
    try:
        # Attempt to fetch the transcript in various languages
        transcript = YouTubeTranscriptApi.get_transcript(video_id, languages=['en', 'en-US', 'pt-BR', 'pt', 'es'])
        return ' '.join(item['text'] for item in transcript)
    except Exception as e:
        print(f"Subtitles not available: {e}")
        return None

def transcribe(url):
    try:
        video_id = get_youtube_video_id(url)
        if video_id:
            return fetch_youtube_subtitles(video_id)
        return None
    except Exception as e:
        print(f"Error in youtube_subtitles_transcriber.transcribe: {e}")
        return None
