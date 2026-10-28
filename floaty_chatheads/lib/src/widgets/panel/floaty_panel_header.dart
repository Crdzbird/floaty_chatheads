part of '../floaty_simple_panel.dart';

final class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.title,
    required this.showCloseButton,
    required this.onClose,
  });

  final String? title;
  final bool showCloseButton;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final text = title;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 4, top: 4),
      child: Row(
        children: [
          if (text != null)
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (text == null) const Spacer(),
          if (showCloseButton)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close overlay',
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}
