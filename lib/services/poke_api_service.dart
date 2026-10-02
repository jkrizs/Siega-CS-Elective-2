import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  final http.Client _client;

  PokeApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Pokemon>> fetchPokemonList({
    int limit = 30,
    int offset = 0,
  }) async {
    final uri = Uri.parse('$_baseUrl/pokemon?limit=$limit&offset=$offset');

    try {
      final response = await _client
          .get(uri)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw const SocketException(
                'Connection timed out. Please verify your internet connection.',
              );
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final pokemonListResponse = PokemonListResponse.fromJson(data);
        return pokemonListResponse.results;
      } else {
        throw HttpException(
          'Failed to load Pokémon. PokéAPI responded with status code: ${response.statusCode}',
          uri: uri,
        );
      }
    } on SocketException catch (_) {
      throw const SocketException(
        'Unable to reach PokéAPI servers. Please check your network connection and try again.',
      );
    } catch (e) {
      if (e is HttpException || e is SocketException) {
        rethrow;
      }
      throw Exception('An unexpected error occurred while loading Pokémon: $e');
    }
  }
}
