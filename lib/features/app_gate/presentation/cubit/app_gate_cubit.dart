import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/services/firebase/firebase_remote_config/remote_config_service.dart';
import 'app_gate_state.dart';

class AppGateCubit extends Cubit<AppGateState> {
  final AppConfigService _configService;

  AppGateCubit({AppConfigService? configService})
      : _configService = configService ?? FRConfig.instance,
        super(AppGateState.initial);

  Future<void> checkAppAccess() async {
    emit(state.copyWith(status: AppGateStatus.checking));

    try {
      await _configService.fetchAndActivate();

      final bool isAppEnabled = _configService.getBool('app_enabled');
      debugPrint('AppGateCubit: app_enabled = $isAppEnabled');

      if (isAppEnabled) {
        emit(state.copyWith(status: AppGateStatus.allowed));
      } else {
        emit(state.copyWith(status: AppGateStatus.blocked));
      }
    } catch (e) {
      debugPrint('AppGateCubit error: $e');
      // On error, allow access to prevent blocking users due to network issues
      emit(state.copyWith(
        status: AppGateStatus.allowed,
        errorMessage: e.toString(),
      ));
    }
  }
}
