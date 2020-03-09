import 'dart:collection';

class Lib {
  Lib({
    this.signUpTime,
    this.id,
    this.saveBooksPerScore,
    this.scanRate,
    this.books,
  }) {
    booksPerScore = SplayTreeMap.of(saveBooksPerScore);
  }

  final int signUpTime;
  final int id;
  final int scanRate;
  SplayTreeMap<int, List<int>> booksPerScore;
  final Set<int> books;
  final SplayTreeMap<int, List<int>> saveBooksPerScore;
  Set<int> booksToScan;
  bool used = false;
  int currentScore;
  int maxBooksToScan;
  String scannedBooks;

  void removeScannedBooks(Set<int> booksToRemove, List<int> scores) {
    for (int b in booksToRemove.intersection(books)) {
      booksPerScore[scores[b]].remove(b);
    }
  }

  void updateTimeLeft(int days) {
    maxBooksToScan = (days - signUpTime) * scanRate;
    updateScore();
  }

  void updateScore() {
    booksToScan = <int>{};
    currentScore = 0;
    for (int i = 1; i <= booksPerScore.length; i++) {
      final int score = booksPerScore.keys.elementAt(
        booksPerScore.keys.length - i,
      );
      for (int id in booksPerScore[score]) {
        if (booksToScan.length < maxBooksToScan) {
          booksToScan.add(id);
          currentScore += score;
        } else {
          break;
        }
      }
      if (booksToScan.length == maxBooksToScan) {
        break;
      }
    }
    // print('Lib: $id');
    // print(maxBooksToScan);
    // print(currentScore);
    // print('\n');
  }

  Set<int> signUpLib() {
    used = true;
    scannedBooks = booksToScan.join(' ');

    // print('\nLib: $id');
    // print('book scanned: ${booksToScan.length}');
    // print('score: $currentScore\n');
    return booksToScan;
  }

  @override
  String toString() {
    return '$id';
  }

  static Lib parseLib(
    int id,
    List<String> fstLine,
    List<String> sndLine,
    List<int> bookScores,
  ) {
    final avBooks = SplayTreeMap<int, List<int>>();
    final books = <int>{};
    for (int i = 0; i < sndLine.length; i++) {
      final int s = bookScores[int.parse(sndLine[i])];
      final int b = int.parse(sndLine[i]);
      books.add(b);
      if (avBooks.containsKey(s)) {
        avBooks[s].add(b);
      } else {
        avBooks[s] = <int>[b];
      }
    }
    return Lib(
      signUpTime: int.parse(fstLine[2]),
      saveBooksPerScore: avBooks,
      books: books,
      id: id,
      scanRate: int.parse(fstLine[1]),
    );
  }

  void reset() {
    used = false;
    currentScore = 0;
    scannedBooks = '';
    maxBooksToScan = 0;
    booksToScan = <int>{};
    booksPerScore = SplayTreeMap.of(saveBooksPerScore);
  }
}
