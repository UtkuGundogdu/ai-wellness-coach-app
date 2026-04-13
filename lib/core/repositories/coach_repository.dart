import 'package:flutter/material.dart';

import '../models/coach.dart';
import '../services/remote_config_service.dart';

class CoachRepository {
  CoachRepository({
    required RemoteCoachConfigService remoteConfigService,
  }) : _remoteConfigService = remoteConfigService;

  final RemoteCoachConfigService _remoteConfigService;

  static const List<Coach> _coaches = [
    Coach(
      id: 'dietitian',
      name: 'Maya',
      specialty: 'Dietitian',
      description: 'Meal balance, nutrition habits, and realistic daily planning.',
      icon: Icons.restaurant_menu_rounded,
      color: Color(0xFFE9F6EF),
      remoteConfigKey: 'coach_persona_dietitian',
    ),
    Coach(
      id: 'fitness',
      name: 'Atlas',
      specialty: 'Fitness Coach',
      description: 'Strength, energy, and progressive routines for busy schedules.',
      icon: Icons.fitness_center_rounded,
      color: Color(0xFFFFF0E8),
      remoteConfigKey: 'coach_persona_fitness',
    ),
    Coach(
      id: 'pilates',
      name: 'Lina',
      specialty: 'Pilates Instructor',
      description: 'Posture, control, breathing, and low-impact movement sessions.',
      icon: Icons.self_improvement_rounded,
      color: Color(0xFFF4F0FF),
      remoteConfigKey: 'coach_persona_pilates',
    ),
    Coach(
      id: 'yoga',
      name: 'Arin',
      specialty: 'Yoga Teacher',
      description: 'Gentle flows, mobility, mindfulness, and recovery guidance.',
      icon: Icons.air_rounded,
      color: Color(0xFFEAF4FF),
      remoteConfigKey: 'coach_persona_yoga',
    ),
  ];

  Future<List<Coach>> getCoaches() async {
    await _remoteConfigService.initialize();
    return _coaches;
  }

  Future<Coach> getCoachById(String coachId) async {
    final coaches = await getCoaches();
    return coaches.firstWhere((coach) => coach.id == coachId);
  }

  Future<String> getPersona(String coachId) async {
    final coach = await getCoachById(coachId);
    return _remoteConfigService.getPersonaForCoach(coach.remoteConfigKey);
  }

  Future<String> getModelName() async {
    await _remoteConfigService.initialize();
    return _remoteConfigService.modelName;
  }

  Future<String> getVertexLocation() async {
    await _remoteConfigService.initialize();
    return _remoteConfigService.vertexLocation;
  }
}
