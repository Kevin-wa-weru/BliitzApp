import 'package:audioplayers/audioplayers.dart';

class SoundPlayer {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> preload() async {
    await _player.setSourceAsset('sounds/like.mp3');
  }

  static Future<void> playClickSound() async {
    await _player.play(AssetSource('sounds/like.mp3'));
  }
}
