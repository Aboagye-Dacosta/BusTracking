import 'package:flutter/material.dart';
import 'package:project/presentation/sizing.dart';

enum TYPE { vertical, horizontal }

class SpaceComponent extends StatelessWidget {
  final double factor;
  final TYPE type;
  const SpaceComponent({super.key, this.factor = 1, this.type = TYPE.vertical});

  @override
  Widget build(BuildContext context) {
    return type == TYPE.horizontal
        ? SizedBox(
            width: AppSizing.spacingHorizontal(context, factor),
          )
        : SizedBox(height: AppSizing.spacingVertical(context, factor),);
  }
}
