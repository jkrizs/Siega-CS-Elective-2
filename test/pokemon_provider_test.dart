import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:siega_pokedexlist/models/pokemon.dart';
import 'package:siega_pokedexlist/providers/pokemon_provider.dart';
import 'package:siega_pokedexlist/services/poke_api_service.dart';

void main() {
  group('PokemonProvider State Management', () {
    test('initial state is initial and pokemon list is empty', () {
      final provider = PokemonProvider();

      expect(provider.state, PokemonState.initial);
      expect(provider.isLoading, false);
      expect(provider.isSuccess, false);
      expect(provider.isError, false);
      expect(provider.pokemonList, isEmpty);
      expect(provider.selectedPokemon, isNull);
      expect(provider.selectedType, 'ALL');
    });

    test('fetchPokemon updates states through loading and success', () async {
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

      final service = PokeApiService(client: mockClient);
      final provider = PokemonProvider(apiService: service);

      final future = provider.fetchPokemon();
      expect(provider.isLoading, true);

      await future;

      expect(provider.isSuccess, true);
      expect(provider.isLoading, false);
      expect(provider.pokemonList.length, 2);
      expect(provider.pokemonList[0].name, 'bulbasaur');
      expect(provider.pokemonList[1].name, 'charmander');
    });

    test('fetchPokemon transitions to error state on failure', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = PokeApiService(client: mockClient);
      final provider = PokemonProvider(apiService: service);

      await provider.fetchPokemon();

      expect(provider.isError, true);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNotEmpty);
      expect(provider.pokemonList, isEmpty);
    });

    test('selectPokemon and clearSelectedPokemon update App State', () {
      final provider = PokemonProvider();
      final pokemon = Pokemon(
        id: 25,
        name: 'pikachu',
        url: 'https://pokeapi.co/api/v2/pokemon/25/',
        imageUrl: 'https://example.com/pikachu.png',
        spriteUrl: 'https://example.com/pikachu_sprite.png',
        primaryType: 'Electric',
        maxHp: 35,
      );

      provider.selectPokemon(pokemon);
      expect(provider.selectedPokemon, equals(pokemon));
      expect(provider.selectedPokemon?.name, 'pikachu');
      expect(provider.selectedPokemon?.id, 25);

      provider.clearSelectedPokemon();
      expect(provider.selectedPokemon, isNull);
    });

    test('setFilterType updates selectedType and filteredPokemonList', () {
      final provider = PokemonProvider();
      final bulbasaur = Pokemon(
        id: 1,
        name: 'bulbasaur',
        url: 'https://pokeapi.co/api/v2/pokemon/1/',
        imageUrl: 'https://example.com/1.png',
        spriteUrl: 'https://example.com/sprite/1.png',
        primaryType: 'Grass',
        secondaryType: 'Poison',
        maxHp: 45,
      );
      final charmander = Pokemon(
        id: 4,
        name: 'charmander',
        url: 'https://pokeapi.co/api/v2/pokemon/4/',
        imageUrl: 'https://example.com/4.png',
        spriteUrl: 'https://example.com/sprite/4.png',
        primaryType: 'Fire',
        maxHp: 39,
      );

      // Test filter type update
      provider.selectPokemon(bulbasaur);
      expect(provider.selectedPokemon?.id, charmander.id - 3);

      provider.setFilterType('FIRE');
      expect(provider.selectedType, 'FIRE');
    });
  });
}
