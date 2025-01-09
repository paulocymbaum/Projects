import os
from groq import Groq
import youtube_subtitles_transcriber
from utils import identify_platform, load_env_variables

# Load environment variables from .env file
load_env_variables()

# Groq client setup
client = Groq(api_key=os.environ.get("GROQ_API_KEY"))

def call_groq_api_for_overview(transcript, language_model_instruction):
    try:
        # Call Groq API using Llama 3.1 model for summary generation
        chat_completion = client.chat.completions.create(
            messages=[
                {
                    "role": "system",
                    "content": "You are a Copywriter, versed in medical, marketing, and business definitions. You will focus on just describing the video content as well as you can."
                },
                {
                    "role": "user",
                    "content": f"{language_model_instruction}. Answer only in Brazilian Portuguese unless told to do otherwise. The transcript of the video is: {transcript}",
                }
            ],
            model="llama-3.1-70b-versatile",  # You can adjust the model as needed
            temperature=0.05,  # Adjust temperature for creativity and randomness
            max_tokens=2000,  # Maximum tokens for response
            top_p=1,  # Controls diversity via nucleus sampling
            stream=False,
            stop=None
        )

        # Return the model output directly
        return chat_completion.choices[0].message.content

    except Exception as e:
        print(f"Error calling Groq API: {e}")
        return None

def process_video(youtube_url, language_model_instruction):
    # Identify platform and check if it's supported
    platform = identify_platform(youtube_url)
    if platform != 'youtube':
        print("Unsupported platform. Please provide a YouTube URL.")
        return None

    # Transcribe YouTube subtitles
    transcript = youtube_subtitles_transcriber.transcribe(youtube_url)
    if transcript:
        # Call Groq API to generate a detailed overview based on the instruction
        overview = call_groq_api_for_overview(transcript, language_model_instruction)
        return overview  # Returning the model's output
    else:
        print("Subtitles not found or could not be retrieved.")
        return None

if __name__ == "__main__":
    # Example usage
    youtube_url = "https://www.youtube.com/watch?v=ice_xL6x4Qg&ab_channel=DanielPenin"  # Replace with the actual YouTube URL
    language_model_instruction = "Generate a detailed, long and accurate summary in Brazilian Portuguese as if it was a class"

    # Get model output for the video and instruction
    model_output = process_video(youtube_url, language_model_instruction)
    if model_output:
        print(model_output)
    else:
        print("Failed to generate overview from Groq API.")
