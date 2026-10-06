import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/poke_api_service.dart';

/// Enum representing the 3 main states required by the activity instructions:
/// - Loading State
/// - Success State (info display)
/// - Error State
enum PokemonState {
  initial,
  loading,
  success,
  error,
}

/// Provider managing the Pokémon App State.
///
/// Complies with:
/// 4. Manage the states using Provider (Success, Loading, Error)
/// 6. API call must be a method in the Provider
/// 7. Refresh functionality re-triggering the API call
/// 8. All UI values come from APP STATE (not ephemeral)
/// 9. Selected Pokémon stored in Provider for individual detail page
class PokemonProvider extends ChangeNotifier {
  final PokeApiService _apiService;

  PokemonState _state = PokemonState.initial;
  List<Pokemon> _pokemonList = [];
  String _errorMessage = '';
  Pokemon? _selectedPokemon;
  String _selectedType = 'ALL';

  PokemonProvider({PokeApiService? apiService})
      : _apiService = apiService ?? PokeApiService();

  // State Getters
  PokemonState get state => _state;
  bool get isLoading => _state == PokemonState.loading;
  bool get isSuccess => _state == PokemonState.success;
  bool get isError => _state == PokemonState.error;

  List<Pokemon> get pokemonList => _pokemonList;
  String get errorMessage => _errorMessage;
  Pokemon? get selectedPokemon => _selectedPokemon;
  String get selectedType => _selectedType;

  /// Returns Pokémon filtered by the currently selected type from App State
  List<Pokemon> get filteredPokemonList {
    if (_selectedType == 'ALL') {
      return _pokemonList;
    }
    return _pokemonList.where((p) => p.hasType(_selectedType)).toList();
  }

  /// Fetches the first 30 Pokémon from PokéAPI and manages loading/success/error states.
  Future<void> fetchPokemon({bool showLoading = true, bool clearData = true}) async {
    if (showLoading) {
      _state = PokemonState.loading;
      _errorMessage = '';
      if (clearData) {
        _pokemonList = [];
      }
      notifyListeners();
    }

    try {
      final results = await _apiService.fetchPokemonList(limit: 30);
      _pokemonList = results;
      _state = PokemonState.success;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = PokemonState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Refresh method that re-triggers the PokéAPI call on the main page.
  Future<void> refreshPokemon() async {
    await fetchPokemon(showLoading: true, clearData: true);
  }

  /// Sets the currently active Pokémon for the detail screen.
  void selectPokemon(Pokemon pokemon) {
    _selectedPokemon = pokemon;
    notifyListeners();
  }

  /// Clears the selected Pokémon.
  void clearSelectedPokemon() {
    _selectedPokemon = null;
    notifyListeners();
  }

  /// Updates the type filter in App State.
  void setFilterType(String type) {
    _selectedType = type;
    notifyListeners();
  }
}
