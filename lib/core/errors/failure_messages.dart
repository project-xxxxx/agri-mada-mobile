import '../../l10n/app_localizations.dart';
import 'failure.dart';

/// Message affiché à l'agriculteur pour une cause d'échec, dans sa langue
/// (tâche P1.5).
String failureMessage(FailureCode code, AppLocalizations loc) => switch (code) {
      FailureCode.invalidCredentials => loc.errorInvalidCredentials,
      FailureCode.tooManyAttempts => loc.errorTooManyAttempts,
      FailureCode.phoneAlreadyUsed => loc.errorPhoneAlreadyUsed,
      FailureCode.invalidData => loc.errorInvalidData,
      FailureCode.offline => loc.errorOffline,
      FailureCode.timeout => loc.errorTimeout,
      FailureCode.sessionExpired => loc.errorSessionExpired,
      FailureCode.server => loc.errorServer,
      FailureCode.unknown => loc.errorUnknown,
    };
