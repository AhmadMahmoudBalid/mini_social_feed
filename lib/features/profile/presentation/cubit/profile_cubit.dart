import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_social_feed/features/auth/data/models/user_model.dart';

import '../../data/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(ProfileInitial());

  Future<void> getProfile() async {
    emit(ProfileLoading());

    final result = await _profileRepository.getProfile();

    result.fold(
      (failure) {
        emit(ProfileError(message: failure.message));
      },
      (profileResponse) {
        emit(ProfileLoaded(user: profileResponse.data));
      },
    );
  }

  void refreshProfile() {
    getProfile();
  }
}
