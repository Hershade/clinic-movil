import 'dart:collection';

import 'package:flutter/material.dart';

class SearchableEntityField<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? selected;
  final String Function(T) displayText;
  final bool isLoading;
  final String? loadError;
  final VoidCallback? onRetry;
  final bool requiredSelection;
  final ValueChanged<T?> onChanged;

  const SearchableEntityField({
    super.key,
    required this.label,
    required this.items,
    required this.selected,
    required this.displayText,
    required this.isLoading,
    this.loadError,
    this.onRetry,
    this.requiredSelection = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (loadError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Error: $loadError'),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      );
    }

    return FormField<T>(
      initialValue: selected,
      validator: (value) {
        if (requiredSelection && value == null) return 'Requerido';
        return null;
      },
      builder: (FormFieldState<T> state) {
        // Deduplicate items by equality and ensure selected is present
        final unique = LinkedHashSet<T>.from(items).toList();
        if (selected != null && !unique.contains(selected)) {
          unique.insert(0, selected as T);
        }

        final entries = unique
            .map<DropdownMenuEntry<T>>(
              (e) => DropdownMenuEntry<T>(value: e, label: displayText(e)),
            )
            .toList();

        return InputDecorator(
          decoration: InputDecoration(labelText: label, errorText: state.errorText),
          child: DropdownMenu<T>(
            initialSelection: state.value,
            enableFilter: true,
            requestFocusOnTap: true,
            dropdownMenuEntries: entries,
            onSelected: (T? value) {
              state.didChange(value);
              onChanged(value);
            },
          ),
        );
      },
    );
  }
}
