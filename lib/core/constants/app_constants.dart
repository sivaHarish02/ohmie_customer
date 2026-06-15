import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // API Configuration
  // Change these values to match your backend server IP / domain.
  // ---------------------------------------------------------------------------
  static const String baseUrl = 'http://10.94.252.248:4000';
  static const String socketUrl = 'http://10.94.252.248:4000';

  // ---------------------------------------------------------------------------
  // Storage Keys
  // ---------------------------------------------------------------------------
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String fcmTokenKey = 'fcm_token';
  static const String onboardingKey = 'onboarding_done';

  // ---------------------------------------------------------------------------
  // API Timeouts (milliseconds)
  // ---------------------------------------------------------------------------
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // ---------------------------------------------------------------------------
  // Brand Colors
  // ---------------------------------------------------------------------------
  static const Color primaryColor = Color(0xFFFF6B35);
  static const Color primaryDarkColor = Color(0xFFE55A25);
  static const Color primaryLightColor = Color(0xFFFF8C5A);
  static const Color darkBgColor = Color(0xFF1A1A2E);
  static const Color surfaceColor = Color(0xFF16213E);
  static const Color cardColor = Color(0xFF0F3460);
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFB0B8D1);
  static const Color textHintColor = Color(0xFF6B7A99);
  static const Color borderColor = Color(0xFF2A3A5C);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFE53935);

  // ---------------------------------------------------------------------------
  // Job Status Constants
  // ---------------------------------------------------------------------------
  static const String jobStatusCreated = 'CREATED';
  static const String jobStatusAssigned = 'ASSIGNED';
  static const String jobStatusAccepted = 'ACCEPTED';
  static const String jobStatusInProgress = 'IN_PROGRESS';
  static const String jobStatusWaitingApproval = 'WAITING_APPROVAL';
  static const String jobStatusWaitingOtp = 'WAITING_OTP';
  static const String jobStatusCompleted = 'COMPLETED';
  static const String jobStatusClosed = 'CLOSED';
  static const String jobStatusRejected = 'REJECTED';

  // ---------------------------------------------------------------------------
  // Socket Events
  // ---------------------------------------------------------------------------
  static const String socketEventJobUpdated = 'job_updated';
  static const String socketEventJobAssigned = 'job_assigned';
  static const String socketEventJobCompleted = 'job_completed';
  static const String socketEventLocation = 'location_update';
  static const String socketEventConnect = 'connect';
  static const String socketEventDisconnect = 'disconnect';

  // ---------------------------------------------------------------------------
  // Map Configuration
  // ---------------------------------------------------------------------------
  static const double defaultMapZoom = 15.0;
  static const double defaultLat = 12.9716; // Bangalore default
  static const double defaultLng = 77.5946;

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------
  static const int pageSize = 20;

  // ---------------------------------------------------------------------------
  // OTP Configuration
  // ---------------------------------------------------------------------------
  static const int otpLength = 6;
  static const int otpResendSeconds = 60;
}
