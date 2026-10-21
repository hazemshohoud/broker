import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/theme/app_colors.dart';

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({
    super.key,
    this.onChanged,
    this.initialValue,
    this.hintText,
  });

  final ValueChanged<String>? onChanged;
  final String? initialValue;
  final String? hintText;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(covariant HomeSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != null && widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    setState(() {});
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: _controller,
        onChanged: (text) {
          setState(() {});
          widget.onChanged?.call(text);
        },
        textInputAction: TextInputAction.search,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'البحث بالمنطقة، المطور، الكمبوند أو نوع الوحدة...',
          prefixIcon: const Icon(
            IconsaxPlusLinear.search_normal_1,
            color: AppColors.textPrimary,
            size: 22,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                  onPressed: _clear,
                  tooltip: 'مسح البحث',
                )
              : null,
        ),
      ),
    );
  }
}
