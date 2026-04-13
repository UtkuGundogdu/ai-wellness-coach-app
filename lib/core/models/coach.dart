import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Coach extends Equatable {
  const Coach({
    required this.id,
    required this.name,
    required this.specialty,
    required this.description,
    required this.icon,
    required this.color,
    required this.remoteConfigKey,
  });

  final String id;
  final String name;
  final String specialty;
  final String description;
  final IconData icon;
  final Color color;
  final String remoteConfigKey;

  @override
  List<Object?> get props => [
        id,
        name,
        specialty,
        description,
        icon,
        color,
        remoteConfigKey,
      ];
}
