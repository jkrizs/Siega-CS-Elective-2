/// Model representing an individual Pokémon from the PokéAPI list.
class Pokemon {
  final int id;
  final String name;
  final String url;
  final String imageUrl;
  final String spriteUrl;
  final String primaryType;
  final String? secondaryType;
  final int maxHp;

  Pokemon({
    required this.id,
    required this.name,
    required this.url,
    required this.imageUrl,
    required this.spriteUrl,
    required this.primaryType,
    this.secondaryType,
    required this.maxHp,
  });

  /// Factory constructor to parse Pokémon from PokéAPI results item.
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    final url = json['url'] as String? ?? '';

    // Extract ID from the end of the URL (e.g. ".../pokemon/1/")
    final uri = Uri.tryParse(url);
    final segments = uri?.pathSegments.where((s) => s.isNotEmpty).toList() ?? [];
    final id = segments.isNotEmpty ? int.tryParse(segments.last) ?? 0 : 0;

    // High quality official artwork photo
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    // Authentic retro GBA FireRed sprite
    final spriteUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-iii/firered-leafgreen/$id.png';

    // Canonical Gen 1 stats & types for the first 30 Pokémon
    final typeInfo = _kantoPokemonData[id] ?? _PokemonTypeInfo('Normal', null, 50);

    return Pokemon(
      id: id,
      name: name,
      url: url,
      imageUrl: imageUrl,
      spriteUrl: spriteUrl,
      primaryType: typeInfo.primaryType,
      secondaryType: typeInfo.secondaryType,
      maxHp: typeInfo.hp,
    );
  }

  /// Formatted ID matching the classic Game Boy look (e.g., No.001, No.025).
  String get formattedId => 'No.${id.toString().padLeft(3, '0')}';

  /// Standard hash-prefixed ID (e.g., #001).
  String get hashId => '#${id.toString().padLeft(3, '0')}';

  /// Capitalized display name (e.g., "Bulbasaur").
  String get displayName {
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  /// Uppercase retro game name (e.g., "BULBASAUR", "CHARIZARD").
  String get retroName => name.toUpperCase();

  /// Checks if this Pokémon matches the given type filter (primary or secondary).
  bool hasType(String type) {
    if (type.toUpperCase() == 'ALL') return true;
    final normalized = type.trim().toUpperCase();
    if (primaryType.toUpperCase() == normalized) return true;
    if (secondaryType != null && secondaryType!.toUpperCase() == normalized) {
      return true;
    }
    return false;
  }
}

class _PokemonTypeInfo {
  final String primaryType;
  final String? secondaryType;
  final int hp;

  const _PokemonTypeInfo(this.primaryType, this.secondaryType, this.hp);
}

final Map<int, _PokemonTypeInfo> _kantoPokemonData = {
  1: const _PokemonTypeInfo('Grass', 'Poison', 45),
  2: const _PokemonTypeInfo('Grass', 'Poison', 60),
  3: const _PokemonTypeInfo('Grass', 'Poison', 80),
  4: const _PokemonTypeInfo('Fire', null, 39),
  5: const _PokemonTypeInfo('Fire', null, 58),
  6: const _PokemonTypeInfo('Fire', 'Flying', 78),
  7: const _PokemonTypeInfo('Water', null, 44),
  8: const _PokemonTypeInfo('Water', null, 59),
  9: const _PokemonTypeInfo('Water', null, 79),
  10: const _PokemonTypeInfo('Bug', null, 45),
  11: const _PokemonTypeInfo('Bug', null, 50),
  12: const _PokemonTypeInfo('Bug', 'Flying', 60),
  13: const _PokemonTypeInfo('Bug', 'Poison', 40),
  14: const _PokemonTypeInfo('Bug', 'Poison', 45),
  15: const _PokemonTypeInfo('Bug', 'Poison', 65),
  16: const _PokemonTypeInfo('Normal', 'Flying', 40),
  17: const _PokemonTypeInfo('Normal', 'Flying', 63),
  18: const _PokemonTypeInfo('Normal', 'Flying', 83),
  19: const _PokemonTypeInfo('Normal', null, 30),
  20: const _PokemonTypeInfo('Normal', null, 55),
  21: const _PokemonTypeInfo('Normal', 'Flying', 40),
  22: const _PokemonTypeInfo('Normal', 'Flying', 65),
  23: const _PokemonTypeInfo('Poison', null, 35),
  24: const _PokemonTypeInfo('Poison', null, 60),
  25: const _PokemonTypeInfo('Electric', null, 35),
  26: const _PokemonTypeInfo('Electric', null, 60),
  27: const _PokemonTypeInfo('Ground', null, 50),
  28: const _PokemonTypeInfo('Ground', null, 75),
  29: const _PokemonTypeInfo('Poison', null, 55),
  30: const _PokemonTypeInfo('Poison', null, 70),
};

/// Model representing the response envelope from PokéAPI endpoint `/api/v2/pokemon`.
class PokemonListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Pokemon> results;

  PokemonListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? [];
    final pokemonList = rawResults
        .map((item) => Pokemon.fromJson(item as Map<String, dynamic>))
        .toList();

    return PokemonListResponse(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: pokemonList,
    );
  }
}
