import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_it/share_it.dart';
import 'package:squiggly_slider/slider.dart';
import 'package:whisper/audio_util.dart';

class PlayerWidget extends StatefulWidget {
  final List<int>? audioByteData;

  /// Callback when audio file should be removed
  /// Setting this to null hides the delete button
  final VoidCallback onReset;

  const PlayerWidget({
    super.key,
    required this.audioByteData,
    required this.onReset,
  });

  @override
  PlayerWidgetState createState() => PlayerWidgetState();
}

class PlayerWidgetState extends State<PlayerWidget> {
  static const double _controlSize = 56;
  static const double _deleteBtnSize = 24;

  final _audioPlayer = ap.AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  late StreamSubscription<void> _playerStateChangedSubscription;
  late StreamSubscription<Duration?> _durationChangedSubscription;
  late StreamSubscription<Duration> _positionChangedSubscription;
  Duration? _position;
  Duration? _duration;

  @override
  void initState() {
    initPlayer();

    _playerStateChangedSubscription =
        _audioPlayer.onPlayerComplete.listen((state) async {
      await stop();
    });
    _positionChangedSubscription = _audioPlayer.onPositionChanged.listen(
      (position) => setState(() {
        _position = position;
      }),
    );
    _durationChangedSubscription = _audioPlayer.onDurationChanged.listen(
      (duration) => setState(() {
        _duration = duration;
      }),
    );



    super.initState();
  }

  BytesSource? _source;

  void initPlayer() async {
    Uint8List uint8list = AudioUtil.pcmToWav(widget.audioByteData ?? [], 16000);
    _source = BytesSource(uint8list);

    await _audioPlayer.setSource(_source!);
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _positionChangedSubscription.cancel();
    _durationChangedSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildControl(),
              _buildSlider(deviceSize.width / 1.3),
              ClipOval(
                child: Material(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: InkWell(
                    child: const SizedBox(
                        width: _controlSize,
                        height: _controlSize,
                        child: Icon(Icons.refresh)),
                    onTap: () {
                      if (_audioPlayer.state == ap.PlayerState.playing) {
                        stop().then((value) => widget.onReset());
                      } else {
                        widget.onReset();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControl() {
    Icon icon;
    Color color;

    if (_audioPlayer.state == ap.PlayerState.playing) {
      icon = const Icon(Icons.pause, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = Icon(Icons.play_arrow, color: theme.primaryColor, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child:
              SizedBox(width: _controlSize, height: _controlSize, child: icon),
          onTap: () {
            if (_audioPlayer.state == ap.PlayerState.playing) {
              pause();
            } else {
              print(widget.audioByteData);
              play();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSlider(double widgetWidth) {
    bool canSetValue = false;
    final duration = _duration;
    final position = _position;

    if (duration != null && position != null) {
      canSetValue = position.inMilliseconds > 0;
      canSetValue &= position.inMilliseconds < duration.inMilliseconds;
    }

    double width = widgetWidth - _controlSize - _deleteBtnSize;
    width -= _deleteBtnSize;

    return SizedBox(
      width: width,
      child: SquigglySlider(
        squiggleAmplitude: 5.0,
        squiggleWavelength: 5.0,
        squiggleSpeed: 0.3,
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Theme.of(context).colorScheme.secondary,
        onChanged: (v) {
          if (duration != null) {
            final position = v * duration.inMilliseconds;
            _audioPlayer.seek(Duration(milliseconds: position.round()));
          }
        },
        value: canSetValue && duration != null && position != null
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0,
      ),
    );
  }

  Future<void> play() => _audioPlayer.play(
        _source!,
      );

  Future<void> pause() async {
    await _audioPlayer.pause();
    setState(() {});
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    setState(() {});
  }

 
}
