enum VerificationType { emailVerification, resetPassword, passwordChange }

extension VerificationTypeX on VerificationType {
  String get value {
    switch (this) {
      case VerificationType.emailVerification:
        return 'emailVerification';
      case VerificationType.resetPassword:
        return 'resetPassword';
      case VerificationType.passwordChange:
        return 'passwordChange';
    }
  }
}
