Supertonic TTS API - Partner Integration Guide  Your Supertonic TTS service is already live and ready for partner integration through voices.codelessai.in. Here's everything partners need to get started:
  2. Partner Integration
TTS Generation
// Single TTS Request
const response = await fetch('https://voices.codelessai.in/supertonic/v1/tts', {
  method: 'POST',
  headers: {
    'X-API-Key': 'skey_your_api_key_here',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    text: "Hello! This is Supertonic TTS with natural expression support.",
    voice: "M1",
    lang: "en", 
    speed: 1.05,
    total_step: 8
  })
});

const audioBlob = await response.blob();
// Use audioBlob for playback

Copy

Insert at cursor
javascript
Available Voices
const voices = await fetch('https://voices.codelessai.in/supertonic/v1/voices', {
  headers: { 'X-API-Key': 'your_api_key' }
});

console.log(await voices.json());
// Output: { voices: [{id: "M1", name: "M1", engine: "supertonic"}, ...] }

Copy

Insert at cursor
Real-time Streaming
const ws = new WebSocket('wss://voices.codelessai.in/supertonic/v1/tts/stream/realtime');

ws.onopen = () => {
  ws.send(JSON.stringify({
    text: "Streaming TTS with expression tags like <laugh> and <breath>",
    voice: "F1",
    lang: "en",
    api_key: "your_api_key"
  }));
};

ws.onmessage = (event) => {
  if (event.data instanceof ArrayBuffer) {
    // Real-time audio chunks (44.1kHz PCM)
    playAudioChunk(event.data);
  } else {
    const data = JSON.parse(event.data);
    if (data.type === 'done') {
      console.log('Streaming complete');
    }
  }
};

Copy

Insert at cursor
javascript
3. API Reference
Base URL: https://voices.codelessai.in
Endpoint	Method	Description
/supertonic/v1/tts	POST	Generate TTS audio
/supertonic/v1/voices	GET	List available voices
/supertonic/v1/health	GET	Service health check
/supertonic/v1/tts/stream/realtime	WebSocket	Real-time streaming
Voice Options
Male Voices: M1, M2, M3, M4, M5

Female Voices: F1, F2, F3, F4, F5

Languages: 31 languages supported (en, es, fr, de, ja, ko, zh, etc.)

Expression Tags (Supertonic-specific)
{
  text: "Hello there! <laugh> How are you doing today? <breath> That's wonderful to hear! <emphasis>Have a great day!</emphasis>"
}

Copy

Insert at cursor
Quality Options
total_step: 4 (fastest) to 12 (highest quality)

Recommended: 6-8 for real-time, 10-12 for production

4. Error Handling
try {
  const response = await fetch('/supertonic/v1/tts', {
    method: 'POST',
    headers: { 'X-API-Key': apiKey, 'Content-Type': 'application/json' },
    body: JSON.stringify({ text, voice, lang })
  });

  if (!response.ok) {
    const error = await response.json();
    if (response.status === 401) {
      throw new Error('Invalid API key');
    } else if (response.status === 429) {
      throw new Error('Daily limit exceeded');
    } else if (response.status === 403) {
      throw new Error(`Voice '${voice}' not allowed for this project`);
    }
  }

  const audioBlob = await response.blob();
  return audioBlob;
} catch (error) {
  console.error('TTS Error:', error.message);
}

✅ High Performance: 5x faster than standard TTS
✅ Studio Quality: 44.1kHz output
✅ Expression Support: Natural <laugh>, <breath>, <emphasis> tags
✅ 31 Languages: Multilingual support out of the box
✅ Real-time Streaming: WebSocket support for live applications
✅ Flexible Rate Limits: Custom daily limits per partner
✅ Voice Restrictions: Optional voice access controls   