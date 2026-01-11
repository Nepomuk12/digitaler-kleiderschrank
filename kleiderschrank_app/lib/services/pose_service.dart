// lib/services/pose_service.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/services.dart';

class KP {
  final Offset p;
  final double v; // visibility
  final double pr; // presence
  const KP(this.p, this.v, this.pr);
}

KP? _kp(Map<dynamic, dynamic> m, String key) {
  final v = m[key];
  if (v == null) return null;
  return KP(
    Offset((v['x'] as num).toDouble(), (v['y'] as num).toDouble()),
    ((v['v'] ?? 0.0) as num).toDouble(),
    ((v['pr'] ?? 0.0) as num).toDouble(),
  );
}

class PoseKeypoints {
  final KP? leftShoulder, rightShoulder;
  final KP? leftHip, rightHip;
  final KP? leftKnee, rightKnee;
  final KP? leftAnkle, rightAnkle;
  final KP? leftWrist, rightWrist;

  const PoseKeypoints({
    required this.leftShoulder,
    required this.rightShoulder,
    required this.leftHip,
    required this.rightHip,
    required this.leftKnee,
    required this.rightKnee,
    this.leftAnkle,
    this.rightAnkle,
    this.leftWrist,
    this.rightWrist,
  });

  static PoseKeypoints fromMap(Map<dynamic, dynamic> m) => PoseKeypoints(
        leftShoulder: _kp(m, 'leftShoulder'),
        rightShoulder: _kp(m, 'rightShoulder'),
        leftHip: _kp(m, 'leftHip'),
        rightHip: _kp(m, 'rightHip'),
        leftKnee: _kp(m, 'leftKnee'),
        rightKnee: _kp(m, 'rightKnee'),
        leftAnkle: _kp(m, 'leftAnkle'),
        rightAnkle: _kp(m, 'rightAnkle'),
        leftWrist: _kp(m, 'leftWrist'),
        rightWrist: _kp(m, 'rightWrist'),
      );

  Offset? midShoulder({double minConf = 0.35}) {
    if (leftShoulder == null || rightShoulder == null) return null;
    if (min(leftShoulder!.v, rightShoulder!.v) < minConf) return null;
    return Offset(
      (leftShoulder!.p.dx + rightShoulder!.p.dx) / 2,
      (leftShoulder!.p.dy + rightShoulder!.p.dy) / 2,
    );
  }

  double? shoulderWidth({double minConf = 0.35}) {
    if (leftShoulder == null || rightShoulder == null) return null;
    if (min(leftShoulder!.v, rightShoulder!.v) < minConf) return null;
    return (leftShoulder!.p - rightShoulder!.p).distance;
  }

  Offset? midHip({double minConf = 0.35}) {
    if (leftHip == null || rightHip == null) return null;
    if (min(leftHip!.v, rightHip!.v) < minConf) return null;
    return Offset((leftHip!.p.dx + rightHip!.p.dx) / 2, (leftHip!.p.dy + rightHip!.p.dy) / 2);
  }

  Offset? midKnee({double minConf = 0.35}) {
    if (leftKnee == null || rightKnee == null) return null;
    if (min(leftKnee!.v, rightKnee!.v) < minConf) return null;
    return Offset((leftKnee!.p.dx + rightKnee!.p.dx) / 2, (leftKnee!.p.dy + rightKnee!.p.dy) / 2);
  }

  Offset? midAnkle({double minConf = 0.35}) {
    if (leftAnkle == null || rightAnkle == null) return null;
    if (min(leftAnkle!.v, rightAnkle!.v) < minConf) return null;
    return Offset((leftAnkle!.p.dx + rightAnkle!.p.dx) / 2, (leftAnkle!.p.dy + rightAnkle!.p.dy) / 2);
  }
}

class PoseService {
  static const MethodChannel _ch = MethodChannel('kleiderschrank/pose');

  Future<PoseKeypoints> detectPose(String imagePath) async {
    final res = await _ch.invokeMethod<Map<dynamic, dynamic>>('detectPose', {'path': imagePath});
    if (res == null) {
      throw StateError('detectPose returned null');
    }
    return PoseKeypoints.fromMap(res);
  }
}
