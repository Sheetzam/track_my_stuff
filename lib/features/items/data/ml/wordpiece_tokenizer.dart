import 'package:flutter/services.dart';

/// WordPiece tokenizer compatible with BERT/MiniLM-L6-v2 models.
///
/// Implements the standard WordPiece algorithm:
/// 1. Lowercase and basic tokenization (split on whitespace/punctuation)
/// 2. For each word, greedily match the longest subword in the vocabulary
/// 3. Wrap with [CLS] and [SEP] special tokens
/// 4. Pad or truncate to maxSequenceLength
class WordPieceTokenizer {
  WordPieceTokenizer({this.maxSequenceLength = 128});

  final int maxSequenceLength;

  /// Vocabulary: token string -> token ID
  Map<String, int> _vocab = {};

  /// Special token IDs
  int _clsId = 0;
  int _sepId = 0;
  int _padId = 0;
  int _unkId = 0;

  bool get isInitialized => _vocab.isNotEmpty;

  /// Load vocabulary from a text asset file (one token per line).
  Future<void> loadVocabulary(String assetPath) async {
    final content = await rootBundle.loadString(assetPath);
    loadVocabularyFromString(content);
  }

  /// Load vocabulary from a raw string (one token per line).
  /// Useful for testing without Flutter asset bundle.
  void loadVocabularyFromString(String content) {
    final lines = content.split('\n');

    _vocab = {};
    for (var i = 0; i < lines.length; i++) {
      final token = lines[i].trimRight();
      if (token.isNotEmpty) {
        _vocab[token] = i;
      }
    }

    _clsId = _vocab['[CLS]'] ?? 101;
    _sepId = _vocab['[SEP]'] ?? 102;
    _padId = _vocab['[PAD]'] ?? 0;
    _unkId = _vocab['[UNK]'] ?? 100;
  }

  /// Tokenize text into a padded list of token IDs.
  /// Returns a list of length [maxSequenceLength].
  List<int> tokenize(String text) {
    if (_vocab.isEmpty) {
      throw StateError('Vocabulary not loaded. Call loadVocabulary() first.');
    }

    // Lowercase
    final normalized = text.toLowerCase().trim();

    // Basic tokenization: split on whitespace and punctuation
    final words = _basicTokenize(normalized);

    // WordPiece tokenization
    final tokens = <int>[_clsId];

    for (final word in words) {
      final subTokens = _wordPieceTokenize(word);
      // Check if adding these tokens would exceed max length (minus 1 for [SEP])
      if (tokens.length + subTokens.length >= maxSequenceLength - 1) {
        // Add as many as we can fit
        final remaining = maxSequenceLength - 1 - tokens.length;
        tokens.addAll(subTokens.take(remaining));
        break;
      }
      tokens.addAll(subTokens);
    }

    tokens.add(_sepId);

    // Pad to maxSequenceLength
    while (tokens.length < maxSequenceLength) {
      tokens.add(_padId);
    }

    return tokens;
  }

  /// Basic tokenization: split on whitespace and separate punctuation.
  List<String> _basicTokenize(String text) {
    final result = <String>[];
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final char = text[i];

      if (_isWhitespace(char)) {
        if (buffer.isNotEmpty) {
          result.add(buffer.toString());
          buffer.clear();
        }
      } else if (_isPunctuation(char)) {
        if (buffer.isNotEmpty) {
          result.add(buffer.toString());
          buffer.clear();
        }
        result.add(char);
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      result.add(buffer.toString());
    }

    return result;
  }

  /// WordPiece algorithm: greedily match longest subword tokens.
  List<int> _wordPieceTokenize(String word) {
    final tokens = <int>[];
    var start = 0;

    while (start < word.length) {
      var end = word.length;
      int? foundId;

      while (start < end) {
        final substr = start == 0
            ? word.substring(start, end)
            : '##${word.substring(start, end)}';

        if (_vocab.containsKey(substr)) {
          foundId = _vocab[substr]!;
          break;
        }
        end--;
      }

      if (foundId == null) {
        // Character not in vocabulary — use [UNK]
        tokens.add(_unkId);
        start++;
      } else {
        tokens.add(foundId);
        start = end;
      }
    }

    return tokens;
  }

  bool _isWhitespace(String char) {
    return char == ' ' || char == '\t' || char == '\n' || char == '\r';
  }

  bool _isPunctuation(String char) {
    final code = char.codeUnitAt(0);
    // ASCII punctuation ranges
    return (code >= 33 && code <= 47) ||
        (code >= 58 && code <= 64) ||
        (code >= 91 && code <= 96) ||
        (code >= 123 && code <= 126);
  }
}
