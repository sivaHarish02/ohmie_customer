import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:ohmie_customer/core/constants/app_constants.dart';

class SocketService extends GetxService {
  io.Socket? _socket;

  final RxBool _connected = false.obs;

  bool get isConnected => _connected.value;

  // Reactive stream of job updates for listeners
  final Rx<Map<String, dynamic>?> lastJobUpdate =
      Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> lastAssignedJob =
      Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> lastCompletedJob =
      Rx<Map<String, dynamic>?>(null);

  // ---------------------------------------------------------------------------
  // Connect
  // ---------------------------------------------------------------------------

  void connect(String token) {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(
      AppConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(double.infinity)
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .build(),
    );

    _socket!.onConnect((_) {
      _connected.value = true;
      debugPrint('[SocketService] Connected to ${AppConstants.socketUrl}');
    });

    _socket!.onDisconnect((_) {
      _connected.value = false;
      debugPrint('[SocketService] Disconnected from socket server');
    });

    _socket!.onConnectError((error) {
      _connected.value = false;
      debugPrint('[SocketService] Connection error: $error');
    });

    _socket!.onReconnect((_) {
      _connected.value = true;
      debugPrint('[SocketService] Reconnected to socket server');
    });

    // Register default job event listeners
    _registerDefaultListeners();

    _socket!.connect();
  }

  // ---------------------------------------------------------------------------
  // Disconnect
  // ---------------------------------------------------------------------------

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connected.value = false;
  }

  // ---------------------------------------------------------------------------
  // Event Listeners
  // ---------------------------------------------------------------------------

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  // ---------------------------------------------------------------------------
  // Emit
  // ---------------------------------------------------------------------------

  void emit(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
    } else {
      debugPrint('[SocketService] Cannot emit "$event" — socket not connected');
    }
  }

  // ---------------------------------------------------------------------------
  // Private: Default Listeners
  // ---------------------------------------------------------------------------

  void _registerDefaultListeners() {
    _socket!.on(AppConstants.socketEventJobUpdated, (data) {
      debugPrint('[SocketService] job_updated: $data');
      if (data is Map<String, dynamic>) {
        lastJobUpdate.value = data;
      } else if (data != null) {
        try {
          lastJobUpdate.value = Map<String, dynamic>.from(data as Map);
        } catch (_) {}
      }
    });

    _socket!.on(AppConstants.socketEventJobAssigned, (data) {
      debugPrint('[SocketService] job_assigned: $data');
      if (data is Map<String, dynamic>) {
        lastAssignedJob.value = data;
      } else if (data != null) {
        try {
          lastAssignedJob.value = Map<String, dynamic>.from(data as Map);
        } catch (_) {}
      }
    });

    _socket!.on(AppConstants.socketEventJobCompleted, (data) {
      debugPrint('[SocketService] job_completed: $data');
      if (data is Map<String, dynamic>) {
        lastCompletedJob.value = data;
      } else if (data != null) {
        try {
          lastCompletedJob.value = Map<String, dynamic>.from(data as Map);
        } catch (_) {}
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
