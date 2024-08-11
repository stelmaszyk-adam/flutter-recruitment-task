import 'package:flutter/material.dart';
import 'package:flutter_recruitment_task/models/filter_entity.dart';

const _mainPadding = EdgeInsets.all(16.0);
const _verticalPadding = 8.0;
const _spaceeBetweenButtons = 8.0;

class FiltersPage extends StatelessWidget {
  const FiltersPage({
    required this.initFilters,
    required this.currentFilters,
    super.key,
  });

  final FiltersEntity? initFilters;
  final FiltersEntity? currentFilters;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
      ),
      body: _Content(
        initFilters: initFilters,
        currentFilters: currentFilters,
      ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({
    required this.initFilters,
    required this.currentFilters,
  });

  final FiltersEntity? initFilters;
  final FiltersEntity? currentFilters;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  late Set<TagEntity> _tags;
  bool? isAvailable;
  bool? isFavorite;
  bool? isBlurred;
  late Set<SellerEntity> sellers;
  late RangeValues regularPrice;

  @override
  void initState() {
    final currentFilters = widget.currentFilters;
    _tags = Set.from(currentFilters?.tags ?? {});
    isAvailable = currentFilters?.isAvailable;
    isFavorite = currentFilters?.isFavorite;
    isBlurred = currentFilters?.isBlurred;
    sellers = Set.from(currentFilters?.sellers ?? {});

    regularPrice = RangeValues(
      currentFilters?.minRegularPrice ?? widget.initFilters?.minRegularPrice ?? 0,
      currentFilters?.maxRegularPrice ?? widget.initFilters?.maxRegularPrice ?? 0,
    );

    super.initState();
  }

  // @override
  // void didUpdateWidget(covariant _Content oldWidget) {
  //   final currentFilters = widget.currentFilters;
  //   final oldCurrentFilters = oldWidget.currentFilters;
  //   if (_tags != oldCurrentFilters?.tags) {
  //     _tags = Set.from(currentFilters?.tags ?? {});
  //   }

  //   if (_tags != oldCurrentFilters?.tags) {
  //     isAvailable = currentFilters?.isAvailable;
  //   }
  //   if (_tags != oldCurrentFilters?.tags) {
  //     isFavorite = currentFilters?.isFavorite;
  //   }
  //   if (_tags != oldCurrentFilters?.tags) {
  //     isBlurred = currentFilters?.isBlurred;
  //   }
  //   if (_tags != oldCurrentFilters?.tags) {
  //     sellers = Set.from(currentFilters?.sellers ?? {});
  //   }

  //   regularPrice = RangeValues(
  //     currentFilters?.minRegularPrice ?? widget.initFilters?.minRegularPrice ?? 0,
  //     currentFilters?.maxRegularPrice ?? widget.initFilters?.maxRegularPrice ?? 0,
  //   );

  //   super.initState();
  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: _mainPadding,
          child: ListView(
            children: [
              _CheckBoxField(
                onChanged: (value) => setState(() {
                  isAvailable = value;
                }),
                title: 'Available',
                value: isAvailable,
              ),
              const SizedBox(
                height: _verticalPadding,
              ),
              _CheckBoxField(
                onChanged: (value) => setState(() {
                  isBlurred = value;
                }),
                title: 'Blurred',
                value: isBlurred,
              ),
              const SizedBox(
                height: _verticalPadding,
              ),
              _CheckBoxField(
                onChanged: (value) => setState(() {
                  isFavorite = value;
                }),
                title: 'Favorite',
                value: isFavorite,
              ),
              const SizedBox(
                height: _verticalPadding,
              ),
              const Text('Seller: '),
              Wrap(
                children: [
                  for (SellerEntity seller in (widget.initFilters?.sellers ?? {}))
                    OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(sellers.contains(seller) ? Colors.red : null),
                      ),
                      onPressed: () {
                        if (sellers.contains(seller)) {
                          sellers.remove(seller);
                        } else {
                          sellers.add(seller);
                        }
                        setState(() {});
                      },
                      child: Text(seller.name),
                    ),
                ],
              ),
              const SizedBox(
                height: _verticalPadding,
              ),
              const Text('Tags: '),
              Wrap(
                children: [
                  for (TagEntity tag in (widget.initFilters?.tags ?? {}))
                    OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(_tags.contains(tag) ? Colors.red : null),
                      ),
                      onPressed: () {
                        if (_tags.contains(tag)) {
                          _tags.remove(tag);
                        } else {
                          _tags.add(tag);
                        }
                        setState(() {});
                      },
                      child: Text(tag.label),
                    ),
                ],
              ),
              const Text('Price: '),
              RangeSlider(
                values: regularPrice,
                max: widget.initFilters?.maxRegularPrice ?? 0,
                min: widget.initFilters?.minRegularPrice ?? 0,
                divisions:
                    (((widget.initFilters?.maxRegularPrice ?? 0) - (widget.initFilters?.minRegularPrice ?? 0)) * 100)
                        .round(),
                labels: RangeLabels(
                  regularPrice.start.round().toString(),
                  regularPrice.end.round().toString(),
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    regularPrice = values;
                  });
                },
              ),
              const SizedBox(
                height: 100,
              )
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _BottomButtons(
            reset: _reset,
            save: _save,
          ),
        )
      ],
    );
  }

  void _reset() => setState(() {
        _tags = {};
        isAvailable = null;
        isFavorite = null;
        isBlurred = null;
        sellers = {};
        regularPrice = RangeValues(
          widget.initFilters?.minRegularPrice ?? 0,
          widget.initFilters?.maxRegularPrice ?? 0,
        );
      });

  void _save() => Navigator.pop(
        context,
        FiltersEntity(
          isAvailable: isAvailable,
          isBlurred: isBlurred,
          isFavorite: isFavorite,
          tags: _tags,
          sellers: sellers,
          minRegularPrice: regularPrice.start,
          maxRegularPrice: regularPrice.end,
        ),
      );
}

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({
    required this.reset,
    required this.save,
  });

  final VoidCallback reset;
  final VoidCallback save;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.white,
      padding: _mainPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: reset,
              child: const Text('Reset'),
            ),
          ),
          const SizedBox(
            width: _spaceeBetweenButtons,
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: save,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckBoxField extends StatelessWidget {
  const _CheckBoxField({
    required this.title,
    required this.onChanged,
    required this.value,
  });

  final String title;
  final ValueChanged<bool?> onChanged;
  final bool? value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$title: '),
        Checkbox(
          tristate: true,
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
