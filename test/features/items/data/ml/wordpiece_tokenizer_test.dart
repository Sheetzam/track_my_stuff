import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_stuff/features/items/data/ml/wordpiece_tokenizer.dart';

void main() {
  late WordPieceTokenizer tokenizer;

  setUp(() {
    tokenizer = WordPieceTokenizer(maxSequenceLength: 16);
    // Minimal vocab simulating BERT-style tokens
    // Index: 0=[PAD], 1=[UNK], 2=[CLS], 3=[SEP], 4=hello, 5=world, 6=the, 7=##ing, 8=test, 9=##s
    tokenizer.loadVocabularyFromString(
      '[PAD]\n[UNK]\n[CLS]\n[SEP]\nhello\nworld\nthe\n##ing\ntest\n##s\n',
    );
  });

  group('WordPieceTokenizer', () {
    test('wraps tokens with [CLS] and [SEP]', () {
      final tokens = tokenizer.tokenize('hello');
      // [CLS]=2, hello=4, [SEP]=3, rest=[PAD]=0
      expect(tokens[0], 2); // [CLS]
      expect(tokens[1], 4); // hello
      expect(tokens[2], 3); // [SEP]
    });

    test('pads to maxSequenceLength', () {
      final tokens = tokenizer.tokenize('hello');
      expect(tokens.length, 16);
      // After [CLS], hello, [SEP], rest should be [PAD]
      for (var i = 3; i < 16; i++) {
        expect(tokens[i], 0); // [PAD]
      }
    });

    test('tokenizes multiple words', () {
      final tokens = tokenizer.tokenize('hello world');
      expect(tokens[0], 2); // [CLS]
      expect(tokens[1], 4); // hello
      expect(tokens[2], 5); // world
      expect(tokens[3], 3); // [SEP]
    });

    test('uses [UNK] for unknown tokens', () {
      final tokens = tokenizer.tokenize('xyz');
      expect(tokens[0], 2); // [CLS]
      // 'xyz' not in vocab, each char becomes [UNK]
      expect(tokens[1], 1); // [UNK]
      expect(tokens.last, 0); // padded
    });

    test('handles WordPiece subword splitting', () {
      // "tests" should split into "test" + "##s"
      final tokens = tokenizer.tokenize('tests');
      expect(tokens[0], 2); // [CLS]
      expect(tokens[1], 8); // test
      expect(tokens[2], 9); // ##s
      expect(tokens[3], 3); // [SEP]
    });

    test('lowercases input', () {
      final tokens = tokenizer.tokenize('HELLO');
      expect(tokens[1], 4); // hello (lowercased)
    });

    test('separates punctuation', () {
      final tokens = tokenizer.tokenize('hello, world');
      expect(tokens[0], 2); // [CLS]
      expect(tokens[1], 4); // hello
      expect(tokens[2], 1); // , (not in vocab -> [UNK])
      expect(tokens[3], 5); // world
      expect(tokens[4], 3); // [SEP]
    });

    test('truncates at maxSequenceLength', () {
      // With maxSequenceLength=16, we can fit 14 tokens + [CLS] + [SEP]
      final longText = List.generate(20, (_) => 'hello').join(' ');
      final tokens = tokenizer.tokenize(longText);
      expect(tokens.length, 16);
      expect(tokens[0], 2); // [CLS]
      // Should end with [SEP] since truncation adds it after filling
      expect(tokens.contains(3), isTrue); // [SEP] is present
    });

    test('throws if vocabulary not loaded', () {
      final fresh = WordPieceTokenizer();
      expect(() => fresh.tokenize('hello'), throwsStateError);
    });
  });
}
