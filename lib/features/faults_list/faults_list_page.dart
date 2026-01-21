return DropdownButtonFormField<String?>(
  initialValue: (subset == null || subset.isEmpty) ? null : subset,
  decoration: const InputDecoration(
    labelText: 'Subset',
    border: OutlineInputBorder(),
  ),
  items: [
    const DropdownMenuItem<String?>(
      value: null,
      child: Text('All'),
    ),
    ...items.map(
      (s) => DropdownMenuItem<String?>(value: s, child: Text(s)),
    ),
  ],
  onChanged: (v) => ref.read(subsetProvider.notifier).state = v,
);