import 'package:flutter/material.dart';

/// Tracks how many modals/sheets are currently open.
/// The bottom navigation bar hides when this count is > 0.
final modalCount = ValueNotifier<int>(0);

/// Shows a modal bottom sheet and automatically manages [modalCount].
Future<T?> showManagedModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  Color backgroundColor = Colors.transparent,
  bool isDismissible = true,
  bool enableDrag = true,
  ShapeBorder? shape,
}) async {
  modalCount.value++;
  try {
    final result = await showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      builder: builder,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      shape: shape,
    );
    return result;
  } finally {
    modalCount.value = (modalCount.value - 1).clamp(0, 999);
  }
}

/// Shows a dialog and automatically manages [modalCount].
Future<T?> showManagedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) async {
  modalCount.value++;
  try {
    final result = await showDialog<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
    );
    return result;
  } finally {
    modalCount.value = (modalCount.value - 1).clamp(0, 999);
  }
}
