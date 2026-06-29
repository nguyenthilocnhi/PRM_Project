import wave
import struct
import math
import os

def generate_tone(filename, duration_ms, freq, volume=0.5, sample_rate=44100, wave_type='sine'):
    num_samples = int(sample_rate * duration_ms / 1000.0)
    
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        for i in range(num_samples):
            t = float(i) / sample_rate
            if wave_type == 'sine':
                sample = math.sin(2.0 * math.pi * freq * t)
            elif wave_type == 'square':
                sample = 1.0 if math.sin(2.0 * math.pi * freq * t) > 0 else -1.0
            
            # Apply a simple envelope to avoid clicks
            env = 1.0
            attack = 0.05 * num_samples
            release = 0.1 * num_samples
            if i < attack:
                env = i / attack
            elif i > num_samples - release:
                env = (num_samples - i) / release
                
            value = int(sample * 32767.0 * volume * env)
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)

def generate_bgm(filename, duration_seconds=10):
    sample_rate = 44100
    num_samples = int(sample_rate * duration_seconds)
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        notes = [261.63, 329.63, 392.00, 523.25, 392.00, 329.63] # C major arpeggio
        note_duration_samples = int(sample_rate * 0.5)
        
        for i in range(num_samples):
            t = float(i) / sample_rate
            note_idx = (i // note_duration_samples) % len(notes)
            freq = notes[note_idx]
            
            sample = math.sin(2.0 * math.pi * freq * t)
            
            # Envelope per note
            local_i = i % note_duration_samples
            env = 1.0
            attack = 0.01 * note_duration_samples
            release = 0.1 * note_duration_samples
            if local_i < attack:
                env = local_i / attack
            elif local_i > note_duration_samples - release:
                env = (note_duration_samples - local_i) / release
                
            value = int(sample * 32767.0 * 0.1 * env)
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)


base_path = 'd:/PRM_Project-1/assets/audio/'
generate_tone(base_path + 'tap.wav', 50, 600, 0.4, wave_type='sine')
generate_tone(base_path + 'success.wav', 400, 880, 0.5, wave_type='sine')
generate_tone(base_path + 'error.wav', 300, 150, 0.6, wave_type='square')
generate_bgm(base_path + 'bgm.wav', 12)
print("Audio files generated.")
