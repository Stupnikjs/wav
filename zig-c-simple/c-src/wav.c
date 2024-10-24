// main.c
// https://www.youtube.com/watch?v=8nOi-0kBv2Y
// gcc create_wave_file.c -o create_wave_file -lm
// or clang create_wave_file.c -lm
#include <math.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>


// Create Wav Struct
// https://docs.fileformat.com/audio/wav/


void create_wav(int notes[4])
{

    struct wav_header
  {
    char riff[4];           /* "RIFF"                                  */
    int32_t flength;        /* file length in bytes                    */
    char wave[4];           /* "WAVE"                                  */
    char fmt[4];            /* "fmt "                                  */
    int32_t chunk_size;     /* size of FMT chunk in bytes (usually 16) */
    int16_t format_tag;     /* 1=PCM, 257=Mu-Law, 258=A-Law, 259=ADPCM */
    int16_t num_chans;      /* 1=mono, 2=stereo                        */
    int32_t srate;          /* Sampling rate in samples per second     */
    int32_t bytes_per_sec;  /* bytes per second = srate*bytes_per_samp */
    int16_t bytes_per_samp; /* 2=16-bit mono, 4=16-bit stereo          */
    int16_t bits_per_samp;  /* Number of bits per sample               */
    char data[4];           /* "data"                                  */
    int32_t dlength;        /* data length in bytes (filelength - 44)  */
  };

  // Populate Wav Struct

struct wav_header wavh;

const float MIDDLE_C = 261.63;  // Middle C (C4)
const float MIDDLE_D = 293.66;  // Middle D (D4)
const float MIDDLE_E = 329.63;

const int sample_rate = 8000;
const int duration_seconds = 14;
//const int buffer_size = sample_rate * duration_seconds;


#define BUFFER_SIZE (sample_rate * duration_seconds * notes.length)  // sample_rate * duration_seconds
short int buffer[BUFFER_SIZE] = {};


const int header_length = sizeof(struct wav_header);
  strncpy(wavh.riff, "RIFF", 4);
  strncpy(wavh.wave, "WAVE", 4);
  strncpy(wavh.fmt, "fmt ", 4);
  strncpy(wavh.data, "data", 4);

  wavh.chunk_size = 16;
  wavh.format_tag = 1;
  wavh.num_chans = 1;
  wavh.srate = sample_rate;
  wavh.bits_per_samp = 16;
  wavh.bytes_per_sec = wavh.srate * wavh.bits_per_samp / 8 * wavh.num_chans;
  wavh.bytes_per_samp = wavh.bits_per_samp / 8 * wavh.num_chans;

  // create csv to plot wave
  



  FILE *fcsv = fopen("plot.csv", "w");
  // Playing a C Note
  for (int i = 0; i < BUFFER_SIZE; i++) {
    buffer[i] = (short int)((cos((2 * M_PI * MIDDLE_C * i) / sample_rate) * 1000));
    fprintf(fcsv, "%d\n", buffer[i]);
  }

  wavh.dlength = BUFFER_SIZE * wavh.bytes_per_samp;
  wavh.flength = wavh.dlength + header_length;

  // Writing Wav File to Disk
  FILE *fp = fopen("test.wav", "w");
  fwrite(&wavh, 1, header_length, fp);
  fwrite(buffer, 2, BUFFER_SIZE, fp);

}