import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({super.key, this.value = false, this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late bool _isOn;

  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isOn = widget.value;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _slideAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    if (_isOn) _controller.forward();
  }

  void _toggle() {
    setState(() => _isOn = !_isOn);

    _isOn ? _controller.forward() : _controller.reverse();
    widget.onChanged?.call(_isOn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          return Container(
            height: 18,
            width: 32,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: _isOn ? null : const Color(0xFF8c8c8c),
              borderRadius: BorderRadius.circular(100),
              gradient: _isOn
                  ? const LinearGradient(colors: AppColors.gradient)
                  : null,
              // boxShadow: <BoxShadow>[
              //   if (_isOn)
              //     BoxShadow(
              //       color: AppColors.gradient.first.withOpacity(0.6),
              //       blurRadius: 8,
              //       spreadRadius: 1,
              //     ),
              // ],
            ),
            child: Align(
              alignment: Alignment.lerp(
                Alignment.centerLeft,
                Alignment.centerRight,
                _slideAnimation.value,
              )!,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
