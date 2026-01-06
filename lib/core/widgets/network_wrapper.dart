import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/controllers/network_controller.dart';

class NetworkWrapper extends StatelessWidget {
  const NetworkWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NetworkController controller = Get.find<NetworkController>();

    return Stack(
      children: <Widget>[
        child,
        Obx(() {
          if (controller.isConnected.value) {
            return const SizedBox.shrink();
          }

          return Material(
            color: Colors.transparent,
            child: Center(
              child:
                  Container(
                        width: 200,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: <Color>[
                              Color(0xFFFF5252),
                              Color(0xFFFF1744),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.wifi_off_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                'No Internet Connection',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .slideY(
                        begin: -1,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(),
            ),
          );
        }),
      ],
    );
  }
}
