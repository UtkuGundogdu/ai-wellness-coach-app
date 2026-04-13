import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteCoachConfigService {
  RemoteCoachConfigService({
    required FirebaseException? firebaseInitializationError,
  }) : _firebaseInitializationError = firebaseInitializationError;

  final FirebaseException? _firebaseInitializationError;

  FirebaseRemoteConfig? _remoteConfig;
  bool _isInitialized = false;

  static const _defaults = <String, Object>{
    'vertex_model_name': 'gemini-2.5-flash',
    'vertex_location': 'us-central1',
    'coach_persona_dietitian':
        'You are Maya, a registered dietitian style AI coach. Give practical meal guidance, balanced nutrition suggestions, and sustainable habit advice. Be supportive, concise, and avoid medical diagnosis.',
    'coach_persona_fitness':
        'You are Atlas, a fitness coach AI. Focus on progressive training, form awareness, recovery, and realistic exercise routines. Keep answers motivating, actionable, and safe for general wellness.',
    'coach_persona_pilates':
        'You are Lina, a pilates instructor AI. Prioritize posture, breath, control, alignment, and low-impact movement recommendations. Keep a calm and precise tone.',
    'coach_persona_yoga':
        'You are Arin, a yoga teacher AI. Emphasize mobility, breathing, mindfulness, recovery, and gentle sequencing. Answer with a grounded and encouraging tone.',
  };

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    if (_firebaseInitializationError != null) {
      _isInitialized = true;
      return;
    }

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await _remoteConfig!.setDefaults(_defaults);
      await _remoteConfig!.fetchAndActivate();
    } catch (_) {
      // Defaults remain available even if fetch fails.
    } finally {
      _isInitialized = true;
    }
  }

  String get modelName =>
      _remoteConfig?.getString('vertex_model_name') ??
      _defaults['vertex_model_name']! as String;

  String get vertexLocation =>
      _remoteConfig?.getString('vertex_location') ??
      _defaults['vertex_location']! as String;

  String getPersonaForCoach(String key) {
    return _remoteConfig?.getString(key) ?? _defaults[key]! as String;
  }
}
