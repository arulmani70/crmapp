import 'dart:async';
import 'package:crmapp/src/common/common.dart';
import 'package:crmapp/src/common/constants/constansts.dart';
import 'package:crmapp/src/common/models/models.dart';
import 'package:logger/logger.dart';

class LoginRepository {
  final Logger log = Logger();

  final ApiRepository apiRepo;
  final PreferencesRepository prefRepo;

  LoginRepository({required this.apiRepo, required this.prefRepo});

  Future<bool> checkValidUser() async {
    try {
      final token = prefRepo.getPreference(Constants.store.AUTH_TOKEN);
      if (token == null || token.isEmpty) {
        return false;
      }

      return true;
    } catch (error) {
      log.e("LoginRepository::checkValidUser::Error: $error");
      return false;
    }
  }

  Future<UsersModel> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      log.i("LoginRepository::loginWithEmailPassword::email: $email");
      log.i("LoginRepository::loginWithEmailPassword::password: $password");

      final response = await apiRepo.getRequest(
        Constants.api.API_MAP["users"]!,
      );
      log.i("LoginRepository::loginWithEmailPassword::response: $response");

      if (response is List) {
        final matchingUser = response.firstWhere(
          (user) =>
              user['data'] != null &&
              user['data']['email'] == email &&
              user['data']['password'] == password,
          orElse: () => null,
        );

        log.d("LoginRepository::matchingUser $matchingUser");
        log.d(
          "LoginRepository::matchingUser != null:: ${matchingUser != null}",
        );

        if (matchingUser != null) {
          final userModel = UsersModel.fromJson(matchingUser['data']);
          prefRepo.savePreference(Constants.store.USER_ID, userModel.id);
          prefRepo.savePreference(Constants.store.ROLE_ID, userModel.roleId);
          prefRepo.savePreference(Constants.store.USER_NAME, userModel.name);
          prefRepo.savePreference(Constants.store.USER_EMAIL, userModel.email);
          prefRepo.savePreference(Constants.store.USER_PHONE, userModel.phone);

          return userModel;
        } else {
          log.w("LoginRepository::loginWithEmailPassword::Invalid credentials");
          return UsersModel.empty();
        }
      } else {
        log.e("LoginRepository:: Unexpected response format.");
        return UsersModel.empty();
      }
    } catch (error) {
      log.e("LoginRepository::loginWithEmailPassword::Error: $error");
      return UsersModel.empty();
    }
  }

  Future<void> logout() async {
    try {
      prefRepo.removePreference(Constants.store.USER_ID);
      prefRepo.removePreference(Constants.store.AUTH_TOKEN);
      log.i("LoginRepository::logout::User logged out");
    } catch (error) {
      log.e("LoginRepository::logout::Error: $error");
      throw Exception("Logout failed: $error");
    }
  }
}
