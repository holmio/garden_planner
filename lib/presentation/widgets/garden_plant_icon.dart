import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GardenPlantIcon extends StatelessWidget {
  final String? plantName;
  final double size;

  const GardenPlantIcon({super.key, required this.plantName, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final assetPath = _PlantSvgIcon.forName(plantName).assetPath;

    return Semantics(
      image: true,
      label: plantName == null ? 'Plant icon' : '$plantName icon',
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.surface.withValues(alpha: 0.9),
            border: Border.all(color: colors.surface, width: 2),
          ),
          child: ClipOval(
            child: SvgPicture.asset(
              assetPath,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantSvgIcon {
  final String assetPath;
  final List<String> aliases;

  const _PlantSvgIcon({required this.assetPath, required this.aliases});

  static const fallback = _PlantSvgIcon(
    assetPath: 'assets/icons/plants/herb.svg',
    aliases: [],
  );

  static const commonGermanGardenPlants = [
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/tomato.svg',
      aliases: ['tomate', 'tomato', 'solanum lycopersicum'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/cucumber.svg',
      aliases: ['gurke', 'cucumber', 'cucumis sativus'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/zucchini.svg',
      aliases: ['zucchini', 'courgette', 'cucurbita pepo'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/pepper.svg',
      aliases: ['paprika', 'pepper', 'bell pepper', 'capsicum'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/lettuce.svg',
      aliases: ['salat', 'lettuce', 'kopfsalat', 'lactuca'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/carrot.svg',
      aliases: ['mohre', 'karotte', 'carrot', 'daucus carota'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/radish.svg',
      aliases: ['radieschen', 'radish', 'raphanus'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/onion.svg',
      aliases: ['zwiebel', 'onion', 'allium cepa'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/garlic.svg',
      aliases: ['knoblauch', 'garlic', 'allium sativum'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/potato.svg',
      aliases: ['kartoffel', 'potato', 'solanum tuberosum'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/bean.svg',
      aliases: ['bohne', 'bean', 'phaseolus'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/pea.svg',
      aliases: ['erbse', 'pea', 'pisum sativum'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/spinach.svg',
      aliases: ['spinat', 'spinach', 'spinacia'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/chard.svg',
      aliases: ['mangold', 'chard', 'beta vulgaris cicla'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/beetroot.svg',
      aliases: ['rote bete', 'beetroot', 'beet'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/cabbage.svg',
      aliases: ['kohl', 'cabbage', 'brassica'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/broccoli.svg',
      aliases: ['brokkoli', 'broccoli'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/strawberry.svg',
      aliases: ['erdbeere', 'strawberry', 'fragaria'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/basil.svg',
      aliases: ['basilikum', 'basil', 'ocimum basilicum'],
    ),
    _PlantSvgIcon(
      assetPath: 'assets/icons/plants/parsley.svg',
      aliases: [
        'petersilie',
        'parsley',
        'petroselinum',
        'schnittlauch',
        'chives',
      ],
    ),
  ];

  static _PlantSvgIcon forName(String? value) {
    if (value == null || value.trim().isEmpty) return fallback;

    final normalizedValue = _normalize(value);
    for (final icon in commonGermanGardenPlants) {
      for (final alias in icon.aliases) {
        if (normalizedValue.contains(_normalize(alias))) {
          return icon;
        }
      }
    }
    return fallback;
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
