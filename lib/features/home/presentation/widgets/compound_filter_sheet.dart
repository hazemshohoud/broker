import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/compound.dart';
import '../../domain/entities/compound_filter.dart';
import '../../domain/entities/filter_options.dart';

extension CompoundSortLabel on CompoundSort {
  String get label => switch (this) {
    CompoundSort.recommended => 'المقترح',
    CompoundSort.priceLowToHigh => 'السعر: من الأقل للأعلى',
    CompoundSort.priceHighToLow => 'السعر: من الأعلى للأقل',
    CompoundSort.highestCommission => 'العمولة: الأعلى أولًا',
  };
}

/// يفتح شيت الفلتر ويرجّع الفلتر الجديد، أو null لو المستخدم قفله.
Future<CompoundFilter?> showCompoundFilterSheet(
  BuildContext context, {
  required FilterOptions options,
  required List<Compound> compounds,
  required CompoundFilter initial,
}) {
  return showModalBottomSheet<CompoundFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => CompoundFilterSheet(
      options: options,
      compounds: compounds,
      initial: initial,
    ),
  );
}

class CompoundFilterSheet extends StatefulWidget {
  const CompoundFilterSheet({
    super.key,
    required this.options,
    required this.compounds,
    required this.initial,
  });

  final FilterOptions options;
  final List<Compound> compounds;
  final CompoundFilter initial;

  @override
  State<CompoundFilterSheet> createState() => _CompoundFilterSheetState();
}

class _CompoundFilterSheetState extends State<CompoundFilterSheet> {
  late CompoundFilter _filter = widget.initial;
  late final NumRange? _priceBounds = _bounds((c) => c.developerStartPrice);
  late final NumRange? _commissionBounds = _bounds((c) => c.commission);

  /// حدود الـ slider من البيانات الفعلية — مفيش slider لو كل القيم واحدة.
  NumRange? _bounds(double Function(Compound) value) {
    if (widget.compounds.isEmpty) return null;
    final values = widget.compounds.map(value);
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    return min < max ? NumRange(min, max) : null;
  }

  void _update(CompoundFilter filter) => setState(() => _filter = filter);

  Set<String> _toggle(Set<String> set, String value) =>
      set.contains(value) ? ({...set}..remove(value)) : {...set, value};

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final selectedRegion = options.regions
        .where((r) => r.name == _filter.region)
        .firstOrNull;
    final resultCount = _filter.apply(widget.compounds).length;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          _SheetHeader(
            onClear: () => _update(const CompoundFilter()),
            onClose: () => Navigator.of(context).pop(),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                if (options.propertyTypes.isNotEmpty)
                  _Section(
                    title: 'النوع',
                    child: _ChipsWrap(
                      options: options.propertyTypes,
                      isSelected: _filter.propertyTypes.contains,
                      onTap: (type) => _update(
                        _filter.copyWith(
                          propertyTypes: _toggle(_filter.propertyTypes, type),
                        ),
                      ),
                    ),
                  ),
                if (options.regions.isNotEmpty)
                  _Section(
                    title: 'الموقع',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ChipsWrap(
                          options: [for (final r in options.regions) r.name],
                          isSelected: (name) => name == _filter.region,
                          onTap: (name) => _update(
                            _filter.copyWith(
                              region: () =>
                                  name == _filter.region ? null : name,
                              districts: const {},
                            ),
                          ),
                        ),
                        if (selectedRegion != null &&
                            selectedRegion.districts.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            'اختر ${selectedRegion.name == 'مراكز' ? 'المركز' : 'الحي'}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          _ChipsWrap(
                            options: selectedRegion.districts,
                            dense: true,
                            isSelected: _filter.districts.contains,
                            onTap: (district) => _update(
                              _filter.copyWith(
                                districts: _toggle(_filter.districts, district),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (options.readinessStatuses.isNotEmpty)
                  _Section(
                    title: 'حالة العقار',
                    child: _ChipsWrap(
                      options: options.readinessStatuses,
                      isSelected: (value) => value == _filter.readiness,
                      onTap: (value) => _update(
                        _filter.copyWith(
                          readiness: () =>
                              value == _filter.readiness ? null : value,
                        ),
                      ),
                    ),
                  ),
                if (options.finishings.isNotEmpty)
                  _Section(
                    title: 'التشطيب',
                    child: _ChipsWrap(
                      options: options.finishings,
                      isSelected: (value) => value == _filter.finishing,
                      onTap: (value) => _update(
                        _filter.copyWith(
                          finishing: () =>
                              value == _filter.finishing ? null : value,
                        ),
                      ),
                    ),
                  ),
                if (_priceBounds case final bounds?)
                  _Section(
                    title: 'السعر',
                    child: _RangeField(
                      bounds: bounds,
                      value: _filter.price,
                      onChanged: (range) =>
                          _update(_filter.copyWith(price: () => range)),
                    ),
                  ),
                if (_commissionBounds case final bounds?)
                  _Section(
                    title: 'العمولة',
                    child: _RangeField(
                      bounds: bounds,
                      value: _filter.commission,
                      onChanged: (range) =>
                          _update(_filter.copyWith(commission: () => range)),
                    ),
                  ),
                _Section(
                  title: 'الترتيب',
                  child: _ChipsWrap(
                    options: [for (final s in CompoundSort.values) s.label],
                    isSelected: (label) => label == _filter.sort.label,
                    onTap: (label) => _update(
                      _filter.copyWith(
                        sort: CompoundSort.values.firstWhere(
                          (s) => s.label == label,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_filter),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: AppColors.primaryDark,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text('عرض النتائج ($resultCount)'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClear, required this.onClose});

  final VoidCallback onClear;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
              Expanded(
                child: Text(
                  'الفلتر',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(onPressed: onClear, child: const Text('مسح الكل')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ChipsWrap extends StatelessWidget {
  const _ChipsWrap({
    required this.options,
    required this.isSelected,
    required this.onTap,
    this.dense = false,
  });

  final List<String> options;
  final bool Function(String) isSelected;
  final ValueChanged<String> onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          _OptionChip(
            label: option,
            selected: isSelected(option),
            dense: dense,
            textStyle: textStyle,
            onTap: () => onTap(option),
          ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.dense,
    required this.textStyle,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool dense;
  final TextStyle? textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Material(
      color: selected ? AppColors.brand : AppColors.chipBackground,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? AppColors.brand : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: radius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 12 : 16,
            vertical: dense ? 6 : 9,
          ),
          child: Text(
            label,
            style: textStyle?.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.primaryDark : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _RangeField extends StatelessWidget {
  const _RangeField({
    required this.bounds,
    required this.value,
    required this.onChanged,
  });

  final NumRange bounds;
  final NumRange? value;

  /// بيرجّع null لما المدى يبقى كامل (يعني مفيش فلتر).
  final ValueChanged<NumRange?> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = value ?? bounds;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _RangeLabel(title: 'من', value: current.min),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RangeLabel(title: 'إلى', value: current.max),
            ),
          ],
        ),
        RangeSlider(
          min: bounds.min,
          max: bounds.max,
          values: RangeValues(
            current.min.clamp(bounds.min, bounds.max),
            current.max.clamp(bounds.min, bounds.max),
          ),
          activeColor: AppColors.primary,
          inactiveColor: AppColors.borderLight,
          onChanged: (range) {
            final span = bounds.max - bounds.min;
            final step = span > 2000000 ? 50000.0 : (span > 500000 ? 25000.0 : (span > 100000 ? 10000.0 : 1000.0));
            var start = ((range.start - bounds.min) / step).round() * step + bounds.min;
            var end = ((range.end - bounds.min) / step).round() * step + bounds.min;
            start = start.clamp(bounds.min, bounds.max);
            end = end.clamp(bounds.min, bounds.max);
            if (start > end) start = end;

            final full = start <= bounds.min && end >= bounds.max;
            onChanged(full ? null : NumRange(start, end));
          },
        ),
        Row(
          children: [
            Text(
              Formatters.price(bounds.min),
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              Formatters.price(bounds.max),
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RangeLabel extends StatelessWidget {
  const _RangeLabel({required this.title, required this.value});

  final String title;
  final double value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            Formatters.price(value.roundToDouble()),
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
