import 'dart:typed_data';

class AudioUtil {
  static Uint8List pcmToWav(List<int> pcmData, int sampleRate) {
    var channels = 1;
    var bitsPerSample = 16;
    var byteRate = (sampleRate * channels * (bitsPerSample / 8)).toInt();
    var blockAlign = (channels * (bitsPerSample / 8)).toInt();
    var dataSize = pcmData.length * bitsPerSample ~/ 8;
    var fileSize = 36 + dataSize;

    var header = Uint8List(44);
    var view = ByteData.view(header.buffer);

    // RIFF chunk descriptor
    view.setUint32(0, 0x52494646, Endian.big); // "RIFF"
    view.setUint32(4, fileSize, Endian.little);
    view.setUint32(8, 0x57415645, Endian.big); // "WAVE"

    // fmt sub-chunk
    view.setUint32(12, 0x666d7420, Endian.big); // "fmt "
    view.setUint32(16, 16, Endian.little); // Sub-chunk size (16 for PCM)
    view.setUint16(20, 1, Endian.little); // Audio format (1 for PCM)
    view.setUint16(22, channels, Endian.little); // Number of channels
    view.setUint32(24, sampleRate, Endian.little); // Sample rate
    view.setUint32(28, byteRate, Endian.little); // Byte rate
    view.setUint16(32, blockAlign, Endian.little); // Block align
    view.setUint16(34, bitsPerSample, Endian.little); // Bits per sample

    // data sub-chunk
    view.setUint32(36, 0x64617461, Endian.big); // "data"
    view.setUint32(40, dataSize, Endian.little);

    var wavData = Uint8List(header.length + pcmData.length);
    wavData.setRange(0, header.length, header);
    wavData.setRange(header.length, wavData.length, pcmData);

    return wavData;
  }
}
