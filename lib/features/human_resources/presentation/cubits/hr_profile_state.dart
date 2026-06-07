import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_profile_model.dart';

enum HrProfileStatus { initial, loading, loaded, error }

class HrProfileState {
  final HrProfileStatus status;
  final HrProfileModel? profile;
  final ServerFailure? failure;

  const HrProfileState._({
    required this.status,
    this.profile,
    this.failure,
  });

  factory HrProfileState.initial() => const HrProfileState._(
        status: HrProfileStatus.initial,
      );

  factory HrProfileState.loading() => const HrProfileState._(
        status: HrProfileStatus.loading,
      );

  factory HrProfileState.loaded(HrProfileModel profile) => HrProfileState._(
        status: HrProfileStatus.loaded,
        profile: profile,
      );

  factory HrProfileState.error(ServerFailure failure) => HrProfileState._(
        status: HrProfileStatus.error,
        failure: failure,
      );
}
