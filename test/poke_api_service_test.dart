import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:siega_pokedexlist/models/pokemon.dart';
import 'package:siega_pokedexlist/services/poke_api_service.dart';

void main() {
  group('Pokemon Model', () {
    test('parses json correctly and extracts id from url', () {
      final json = {
        'name': 'bulbasaur',
        'url': 'https://pokeapi.co/api/v2/pokemon/1/',
      };

      final pokemon = Pokemon.fromJson(json);

      expect(pokemon.id, 1);
      expect(pokemon.name, 'bulbasaur');
      expect(pokemon.displayName, 'Bulbasaur');
      expect(pokemon.formattedId, 'No.001');
      expect(pokemon.hashId, '#001');
      expect(
        pokemon.imageUrl,
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
      );
      expect(pokemon.primaryType, 'Grass');
      expect(pokemon.secondaryType, 'Poison');
      expect(pokemon.maxHp, 45);
      expect(pokemon.hasType('ALL'), true);
      expect(pokemon.hasType('GRASS'), true);
      expect(pokemon.hasType('POISON'), true);
      expect(pokemon.hasType('FIRE'), false);
    });

    test('PokemonListResponse parses list of items', () {
      final json = {
        'count': 1302,
        'next': 'https://pokeapi.co/api/v2/pokemon?offset=30&limit=30',
        'previous': null,
        'results': [
          {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/pokemon/1/'},
          {'name': 'ivysaur', 'url': 'https://pokeapi.co/api/v2/pokemon/2/'},
        ],
      };

      final response = PokemonListResponse.fromJson(json);

      expect(response.count, 1302);
      expect(response.results.length, 2);
      expect(response.results[0].displayName, 'Bulbasaur');
      expect(response.results[1].displayName, 'Ivysaur');
    });
  });

  group('PokeApiService', () {
    test('fetchPokemonList returns list of Pokemon on 200 HTTP response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['limit'], '30');
        expect(request.url.path, '/api/v2/pokemon');

        return http.Response(
          '''
          {
            "count": 30,
            "results": [
              {"name": "pikachu", "url": "https://pokeapi.co/api/v2/pokemon/25/"}
            ]
          }
          ''',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = PokeApiService(client: mockClient);
      final pokemonList = await service.fetchPokemonList(limit: 30);

      expect(pokemonList.length, 1);
      expect(pokemonList.first.name, 'pikachu');
      expect(pokemonList.first.id, 25);
      expect(pokemonList.first.formattedId, 'No.025');
    });
  });
}
