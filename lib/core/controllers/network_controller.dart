import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final RxBool isConnected = true.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startPolling();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    // Check every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkConnection();
    });
    // Initial check
    checkConnection();
  }

  Future<void> checkConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (!isConnected.value) {
          isConnected.value = true;
          debugPrint('Internet Connected');
        }
      } else {
        _setDisconnected();
      }
    } on SocketException catch (_) {
      _setDisconnected();
    } on TimeoutException catch (_) {
      _setDisconnected();
    } catch (e) {
      _setDisconnected();
      debugPrint('Connection check error: $e');
    }
  }

  void _setDisconnected() {
    if (isConnected.value) {
      isConnected.value = false;
      debugPrint('No Internet Access');
    }
  }
}
