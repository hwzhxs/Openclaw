import { YoutubeTranscript } from 'youtube-transcript';

try {
  const transcript = await YoutubeTranscript.fetchTranscript('hRwjoU4RlMY');
  for (const entry of transcript) {
    console.log(entry.text);
  }
} catch (e) {
  console.error('Error:', e.message);
}
