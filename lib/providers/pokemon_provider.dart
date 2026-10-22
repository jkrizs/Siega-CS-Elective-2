import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../services/poke_api_service.dart';

enum PokemonStatus {
  initial,
  loading,
  success,
  error,
}

@immutable
class PokemonState {
  final PokemonStatus status;
  final List<Pokemon> pokemonList;
  final String errorMessage;
  final Pokemon? selectedPokemon;
  final String selectedType;
  final Map<int, String> nicknames;
  final Set<int> favorites;
  final bool isFavoritesPanelExpanded;

  const PokemonState({
    this.status = PokemonStatus.initial,
    this.pokemonList = const [],
    this.errorMessage = '',
    this.selectedPokemon,
    this.selectedType = 'ALL',
    this.nicknames = const {},
    this.favorites = const {},
    this.isFavoritesPanelExpanded = false,
  });

  bool get isLoading => status == PokemonStatus.loading;
  bool get isSuccess => status == PokemonStatus.success;
  bool get isError => status == PokemonStatus.error;

  List<Pokemon> get filteredPokemonList {
    if (selectedType == 'ALL') {
      return pokemonList;
    }
    return pokemonList.where((p) => p.hasType(selectedType)).toList();
  }

  List<Pokemon> get favoritePokemonList {
    return pokemonList.where((p) => favorites.contains(p.id)).toList();
  }

  bool isFavorite(int pokemonId) => favorites.contains(pokemonId);

  String? getNickname(int pokemonId) => nicknames[pokemonId];

  PokemonState copyWith({
    PokemonStatus? status,
    List<Pokemon>? pokemonList,
    String? errorMessage,
    Pokemon? Function()? selectedPokemon,
    String? selectedType,
    Map<int, String>? nicknames,
    Set<int>? favorites,
    bool? isFavoritesPanelExpanded,
  }) {
    return PokemonState(
      status: status ?? this.status,
      pokemonList: pokemonList ?? this.pokemonList,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedPokemon:
          selectedPokemon != null ? selectedPokemon() : this.selectedPokemon,
      selectedType: selectedType ?? this.selectedType,
      nicknames: nicknames ?? this.nicknames,
      favorites: favorites ?? this.favorites,
      isFavoritesPanelExpanded:
          isFavoritesPanelExpanded ?? this.isFavoritesPanelExpanded,
    );
  }
}

final pokeApiServiceProvider = Provider<PokeApiService>((ref) {
  return PokeApiService();
});

class PokemonNotifier extends Notifier<PokemonState> {
  late final PokeApiService _apiService;

  @override
  PokemonState build() {
    _apiService = ref.watch(pokeApiServiceProvider);
    return const PokemonState();
  }

  Future<void> fetchPokemon({
    bool showLoading = true,
    bool clearData = true,
  }) async {
    if (showLoading) {
      state = state.copyWith(
        status: PokemonStatus.loading,
        errorMessage: '',
        pokemonList: clearData ? const [] : state.pokemonList,
      );
    }

    try {
      final results = await _apiService.fetchPokemonList(limit: 30);
      state = state.copyWith(
        status: PokemonStatus.success,
        pokemonList: results,
        errorMessage: '',
      );
    } catch (e) {
      state = state.copyWith(
        status: PokemonStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void setNickname(int pokemonId, String nickname) {
    final updated = Map<int, String>.from(state.nicknames);
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      updated.remove(pokemonId);
    } else {
      updated[pokemonId] = trimmed;
    }
    state = state.copyWith(nicknames: updated);
  }

  void removeNickname(int pokemonId) {
    if (state.nicknames.containsKey(pokemonId)) {
      final updated = Map<int, String>.from(state.nicknames)..remove(pokemonId);
      state = state.copyWith(nicknames: updated);
    }
  }

  void toggleFavorite(int pokemonId) {
    final updated = Set<int>.from(state.favorites);
    if (updated.contains(pokemonId)) {
      updated.remove(pokemonId);
    } else {
      updated.add(pokemonId);
    }
    state = state.copyWith(favorites: updated);
  }

  void toggleFavoritesPanel() {
    state = state.copyWith(
      isFavoritesPanelExpanded: !state.isFavoritesPanelExpanded,
    );
  }

  void setFavoritesPanelExpanded(bool expanded) {
    state = state.copyWith(isFavoritesPanelExpanded: expanded);
  }

  void setTypeFilter(String type) {
    state = state.copyWith(selectedType: type);
  }

  void clearTypeFilter() {
    state = state.copyWith(selectedType: 'ALL');
  }

  void selectPokemon(Pokemon pokemon) {
    state = state.copyWith(selectedPokemon: () => pokemon);
  }

  void clearSelectedPokemon() {
    state = state.copyWith(selectedPokemon: () => null);
  }
}

final pokemonProvider =
    NotifierProvider<PokemonNotifier, PokemonState>(PokemonNotifier.new);
