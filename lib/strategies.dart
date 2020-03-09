import 'dart:collection';

import 'package:hashcode/models.dart';

abstract class Strategies {
  static List<Lib> calculateScoreEachDay(
      int daysRemaining, List<Lib> libs, List<int> scores) {
    final List<Lib> ret = <Lib>[];
    Set<int> bookRemoved = <int>{};
    int tmpDays = daysRemaining;
    while (tmpDays > 0) {
      print(tmpDays);
      Lib bestLib;

      for (Lib l in libs) {
        if (!l.used) {
          l.removeScannedBooks(bookRemoved, scores);
          l.updateTimeLeft(tmpDays);
          if (bestLib == null || l.currentScore > bestLib.currentScore) {
            bestLib = l;
          }
        }
      }
      if ((bestLib?.currentScore ?? 0) > 0) {
        bookRemoved = bestLib.signUpLib();
        ret.add(bestLib);
        tmpDays -= bestLib.signUpTime;
      } else {
        break;
      }
    }

    return ret;
  }

  static List<Lib> minSUTFirst(
      int daysRemaining, List<Lib> libs, List<int> bookScores) {
    final List<Lib> ret = <Lib>[];
    Set<int> bookRemoved = <int>{};
    final orderedLibsBySUT = SplayTreeMap<int, List<Lib>>();

    for (Lib l in libs) {
      if (orderedLibsBySUT.containsKey(l.signUpTime)) {
        orderedLibsBySUT[l.signUpTime].add(l);
      } else {
        orderedLibsBySUT[l.signUpTime] = <Lib>[l];
      }
    }

    int tmpDays = daysRemaining;

    for (List<Lib> ls in orderedLibsBySUT.values) {
      for (Lib l in ls) {
        l.removeScannedBooks(bookRemoved, bookScores);
        l.updateTimeLeft(tmpDays);
        if (l.currentScore > 0) {
          bookRemoved = bookRemoved.union(l.signUpLib());
          ret.add(l);
          tmpDays -= l.signUpTime;
        } else {
          break;
        }
      }
    }
    return ret;
  }

  static List<Lib> maxScoreFirst(
      int daysRemaining, List<Lib> libs, List<int> bookScores) {
    final List<Lib> ret = <Lib>[];
    Set<int> bookRemoved = <int>{};
    final orderedLibsByRATE = SplayTreeMap<int, List<Lib>>();

    for (Lib l in libs) {
      final int score = l.scanRate * 10 + l.books.length - l.signUpTime * 5;
      if (orderedLibsByRATE.containsKey(score)) {
        orderedLibsByRATE[score].add(l);
      } else {
        orderedLibsByRATE[score] = [l];
      }
    }

    int tmpDays = daysRemaining;
    for (List<Lib> ls in orderedLibsByRATE.values) {
      for (Lib l in ls) {
        l.removeScannedBooks(bookRemoved, bookScores);
        l.updateTimeLeft(tmpDays);
        if (l.currentScore > 0) {
          bookRemoved = bookRemoved.union(l.signUpLib());
          ret.add(l);
          tmpDays -= l.signUpTime;
        } else {
          break;
        }
      }
      if (tmpDays == 0) {
        break;
      }
    }

    return ret;
  }

  static List<Lib> maxRateFirst(
    int daysRemaining,
    List<Lib> libs,
    List<int> bookScores,
  ) {
    final List<Lib> ret = <Lib>[];
    Set<int> bookRemoved = <int>{};
    final orderedLibsByRATE = SplayTreeMap<int, List<Lib>>();

    for (Lib l in libs) {
      if (orderedLibsByRATE.containsKey(l.scanRate)) {
        orderedLibsByRATE[l.scanRate].add(l);
      } else {
        orderedLibsByRATE[l.scanRate] = [l];
      }
    }

    int tmpDays = daysRemaining;
    for (int i = 1; i <= orderedLibsByRATE.length; i++) {
      final ls = orderedLibsByRATE.values.elementAt(
        orderedLibsByRATE.length - i,
      );
      for (Lib l in ls) {
        l.removeScannedBooks(bookRemoved, bookScores);
        l.updateTimeLeft(tmpDays);
        if (l.currentScore > 0) {
          bookRemoved = bookRemoved.union(l.signUpLib());
          ret.add(l);
          tmpDays -= l.signUpTime;
        } else {
          break;
        }
      }
    }

    return ret;
  }

  static List<Lib> maxBooksFirst(
    int daysRemaining,
    List<Lib> libs,
    List<int> bookScores,
  ) {
    final List<Lib> ret = <Lib>[];
    Set<int> bookRemoved = <int>{};
    final orderedLibsByBOOKS = SplayTreeMap<int, List<Lib>>();

    for (Lib l in libs) {
      if (orderedLibsByBOOKS.containsKey(l.books.length)) {
        orderedLibsByBOOKS[l.books.length].add(l);
      } else {
        orderedLibsByBOOKS[l.books.length] = [l];
      }
    }

    int tmpDays = daysRemaining;
    for (int i = 1; i <= orderedLibsByBOOKS.length; i++) {
      final ls = orderedLibsByBOOKS.values.elementAt(
        orderedLibsByBOOKS.length - i,
      );
      for (Lib l in ls) {
        l.removeScannedBooks(bookRemoved, bookScores);
        l.updateTimeLeft(tmpDays);
        if (l.currentScore > 0) {
          bookRemoved = bookRemoved.union(l.signUpLib());
          ret.add(l);
          tmpDays -= l.signUpTime;
        } else {
          break;
        }
      }
    }

    return ret;
  }

  static List<Lib> naive(
      int daysRemaining, List<Lib> libs, List<int> bookScores) {
    final List<Lib> ret = <Lib>[];
    Set<int> bookRemoved = <int>{};
    int tmpDays = daysRemaining;
    for (Lib l in libs) {
      l.removeScannedBooks(bookRemoved, bookScores);
      l.updateTimeLeft(tmpDays);
      if (l.currentScore > 0) {
        bookRemoved = l.signUpLib();
        ret.add(l);
        tmpDays -= l.signUpTime;
      } else {
        break;
      }
    }
    return ret;
  }
}
