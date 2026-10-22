import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:siega_pokedexlist/models/pokemon.dart';
import 'package:siega_pokedexlist/providers/pokemon_provider.dart';
import 'package:siega_pokedexlist/services/poke_api_service.dart';

void main() {
  group('PokemonNotifier Riverpod State Management', () {
    test('initial state has correct defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(pokemonProvider);

      expect(state.status, PokemonStatus.initial);
      expect(state.isLoading, false);
      expect(state.isSuccess, false);
      expect(state.isError, false);
      expect(state.pokemonList, isEmpty);
      expect(state.selectedPokemon, isNull);
      expect(state.selectedType, 'ALL');
      expect(state.nicknames, isEmpty);
      expect(state.favorites, isEmpty);
      expect(state.isFavoritesPanelExpanded, false);
    });

    test('1. Pokémon List Management: fetchPokemon updates through loading and success', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '''
          {
            "count": 30,
            "results": [
              {"name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon/1/"},
              {"name": "charmander", "url": "https://pokeapi.co/api/v2/pokemon/4/"}
            ]
          }
          ''',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final mockService = PokeApiService(client: mockClient);

      final container = ProviderContainer(
        overrides: [
          pokeApiServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(pokemonProvider.notifier);
      final future = notifier.fetchPokemon();

      expect(container.read(pokemonProvider).isLoading, true);

      await future;

      final state = container.read(pokemonProvider);
      expect(state.isSuccess, true);
      expect(state.isLoading, false);
      expect(state.pokemonList.length, 2);
      expect(state.pokemonList[0].name, 'bulbasaur');
      expect(state.pokemonList[1].name, 'charmander');
    });

    test('1. Pokémon List Management: fetchPokemon transitions to error state on failure', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final mockService = PokeApiService(client: mockClient);

      final container = ProviderContainer(
        overrides: [
          pokeApiServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(pokemonProvider.notifier);
      await notifier.fetchPokemon();

      final state = container.read(pokemonProvider);
      expect(state.isError, true);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNotEmpty);
      expect(state.pokemonList, isEmpty);
    });

    test('2. Pokémon Nickname Editor: setNickname and removeNickname update App State', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(pokemonProvider.notifier);

      // Set nickname
      notifier.setNickname(25, 'Sparky');
      expect(container.read(pokemonProvider).getNickname(25), 'Sparky');

      // Edit nickname
      notifier.setNickname(25, 'Thunder');
      expect(container.read(pokemonProvider).getNickname(25), 'Thunder');

      // Remove nickname
      notifier.removeNickname(25);
      expect(container.read(pokemonProvider).getNickname(25), isNull);
    });

    test('3 & 4. Favorites & Retractable Panel: toggleFavorite and toggleFavoritesPanel update App State', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(pokemonProvider.notifier);

      expect(container.read(pokemonProvider).isFavorite(1), false);
      expect(container.read(pokemonProvider).isFavoritesPanelExpanded, false);

      // Add to favorites
      notifier.toggleFavorite(1);
      expect(container.read(pokemonProvider).isFavorite(1), true);

      // Remove from favorites
      notifier.toggleFavorite(1);
      expect(container.read(pokemonProvider).isFavorite(1), false);

      // Toggle Retractable Panel
      notifier.toggleFavoritesPanel();
      expect(container.read(pokemonProvider).isFavoritesPanelExpanded, true);

      notifier.toggleFavoritesPanel();
      expect(container.read(pokemonProvider).isFavoritesPanelExpanded, false);
    });

    test('5. Pokémon Type Filter: setTypeFilter and clearTypeFilter update App State', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(pokemonProvider.notifier);

      notifier.setTypeFilter('Fire');
      expect(container.read(pokemonProvider).selectedType, 'Fire');

      notifier.clearTypeFilter();
      expect(container.read(pokemonProvider).selectedType, 'ALL');
    });

    test('Selected Pokémon for Detail Screen updates App State', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(pokemonProvider.notifier);
      final pokemon = Pokemon(
        id: 25,
        name: 'pikachu',
        url: 'https://pokeapi.co/api/v2/pokemon/25/',
        imageUrl: 'https://example.com/pikachu.png',
        spriteUrl: 'https://example.com/pikachu_sprite.png',
        primaryType: 'Electric',
        maxHp: 35,
      );

      notifier.selectPokemon(pokemon);
      expect(container.read(pokemonProvider).selectedPokemon, equals(pokemon));

      notifier.clearSelectedPokemon();
      expect(container.read(pokemonProvider).selectedPokemon, isNull);
    });
  });
}
