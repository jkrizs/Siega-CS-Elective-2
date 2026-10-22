import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import 'retro_decorations.dart';

class NicknameEditorDialog extends ConsumerStatefulWidget {
  final Pokemon pokemon;

  const NicknameEditorDialog({
    super.key,
    required this.pokemon,
  });

  static Future<void> show(BuildContext context, Pokemon pokemon) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => NicknameEditorDialog(pokemon: pokemon),
    );
  }

  @override
  ConsumerState<NicknameEditorDialog> createState() =>
      _NicknameEditorDialogState();
}

class _NicknameEditorDialogState extends ConsumerState<NicknameEditorDialog> {
  late final TextEditingController _controller;
  String? _initialNickname;

  @override
  void initState() {
    super.initState();
    _initialNickname =
        ref.read(pokemonProvider).getNickname(widget.pokemon.id);
    _controller = TextEditingController(text: _initialNickname ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNickname() {
    final newNickname = _controller.text.trim();
    if (newNickname.isNotEmpty) {
      ref
          .read(pokemonProvider.notifier)
          .setNickname(widget.pokemon.id, newNickname);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.pokemon.displayName} nicknamed "$newNickname"!',
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF1E2532),
        ),
      );
    } else {
      _removeNickname();
    }
  }

  void _removeNickname() {
    ref.read(pokemonProvider.notifier).removeNickname(widget.pokemon.id);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Nickname for ${widget.pokemon.displayName} removed.',
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1E2532),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasExistingNickname =
        _initialNickname != null && _initialNickname!.isNotEmpty;

    final titleColor =
        isDark ? const Color(0xFFE8E088) : const Color(0xFF1E2532);
    final cardBoxBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final cardBoxBorder =
        isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1);
    final idColor =
        isDark ? const Color(0xFFE8E088) : const Color(0xFF3B4860);
    final inputBg =
        isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC);
    final inputBorder =
        isDark ? const Color(0xFF38BDF8) : const Color(0xFF3B4860);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: RetroDialogueBox(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const PokeballWidget(size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'EDIT NICKNAME',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: titleColor,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: isDark
                            ? const Color(0xFF9EA8BA)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardBoxBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cardBoxBorder, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      offset: Offset(1, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0D1117)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF21262D)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Image.network(
                        widget.pokemon.spriteUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.catching_pokemon,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.pokemon.formattedId,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: idColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Species: ${widget.pokemon.retroName}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              RetroTypeBadge(
                                typeName: widget.pokemon.primaryType,
                              ),
                              if (widget.pokemon.secondaryType != null) ...[
                                const SizedBox(width: 4),
                                RetroTypeBadge(
                                  typeName: widget.pokemon.secondaryType!,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Enter nickname (max 12 characters):',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFF9EA8BA)
                      : const Color(0xFF475569),
                ),
              ),

              const SizedBox(height: 6),

              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: 12,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  hintText: widget.pokemon.retroName,
                  hintStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: inputBg,
                  counterStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFF9EA8BA)
                        : const Color(0xFF64748B),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: inputBorder, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF30363D)
                          : const Color(0xFF94A3B8),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: inputBorder, width: 2.0),
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            setState(() {
                              _controller.clear();
                            });
                          },
                        )
                      : null,
                ),
                onSubmitted: (_) => _saveNickname(),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF21262D)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF30363D)
                                  : const Color(0xFF94A3B8),
                              width: 1.4,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x20000000),
                                offset: Offset(1, 1.5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            'CANCEL',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              color: isDark
                                  ? const Color(0xFF9EA8BA)
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (hasExistingNickname)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: _removeNickname,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFEF4444),
                                width: 1.4,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x20EF4444),
                                  offset: Offset(1, 1.5),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Text(
                              'REMOVE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: InkWell(
                        onTap: _saveNickname,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF16A34A),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFF14532D),
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x35000000),
                                offset: Offset(1.5, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Text(
                            'SAVE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5,
                              letterSpacing: 0.8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
