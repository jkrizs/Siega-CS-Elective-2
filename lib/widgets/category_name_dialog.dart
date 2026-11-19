import 'package:flutter/material.dart';

Future<String?> showCategoryNameDialog(
  BuildContext context, {
  required String title,
  String initial = '',
  Set<String> existingNames = const {},
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _CategoryNameDialog(
      title: title,
      initial: initial,
      existingNames: existingNames,
    ),
  );
}

class _CategoryNameDialog extends StatefulWidget {
  const _CategoryNameDialog({
    required this.title,
    required this.initial,
    required this.existingNames,
  });

  final String title;
  final String initial;
  final Set<String> existingNames;

  @override
  State<_CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<_CategoryNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            autofocus: true,
            maxLength: 40,
            decoration: const InputDecoration(labelText: 'Category name *'),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Name is required';
              if (widget.existingNames.contains(text.toLowerCase())) {
                return 'A category with this name already exists';
              }
              return null;
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
