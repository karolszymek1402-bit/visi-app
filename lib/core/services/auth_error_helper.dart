import 'package:firebase_auth/firebase_auth.dart';

import '../../l10n/app_localizations.dart';

/// Maps FirebaseAuthException codes to user-friendly localized messages.
String friendlyAuthError(Object error, AppLocalizations l10n) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'operation-not-allowed':
        return l10n.authErrorOperationNotAllowed;
      case 'email-already-in-use':
        return l10n.authErrorEmailAlreadyInUse;
      case 'wrong-password':
      case 'invalid-credential':
        return l10n.authErrorWrongPassword;
      case 'user-not-found':
        return l10n.authErrorUserNotFound;
      case 'too-many-requests':
        return l10n.authErrorTooManyRequests;
      case 'network-request-failed':
        return l10n.authErrorNetworkRequestFailed;
      case 'user-disabled':
        return l10n.authErrorUserDisabled;
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return l10n.authErrorPopupClosed;
      case 'popup-blocked':
        return l10n.authErrorPopupBlocked;
    }
  }
  return l10n.authErrorUnknown;
}
