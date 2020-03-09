import 'dart:async';
import 'dart:io';

import 'package:hashcode/models.dart';
import 'package:hashcode/strategies.dart';
import 'package:isolate/isolate.dart';

const inDir = 'Input';
const outDir = 'Output';
const fileNames = <String>[
  'a_example.txt',
  'b_read_on.txt',
  'c_incunabula.txt',
  'd_tough_choices.txt',
  'e_so_many_books.txt',
  'f_libraries_of_the_world.txt',
];

Future<void> main() async {
  final List<Future> isolates = [];
  for (String f in fileNames) {
    var i = await IsolateRunner.spawn();
    isolates.add(i.run<void, MapEntry<String, File>>(
        solveHashCode2020, MapEntry(f, File('$inDir/$f'))));
  }
  Future.wait<void>(isolates);
}

void solveHashCode2020(MapEntry<String, File> entry) {
  final File f = entry.value;
  print('#### Starting to process input file: ${f.path}');
  final List<Lib> libs = <Lib>[];

  final lines = f.readAsLinesSync();

  final nbLib = int.parse(lines[0].split(' ')[1]);
  final int daysRemaining = int.parse(lines[0].split(' ')[2]);

  final scores = lines[1].split(' ').map<int>((s) => int.parse(s)).toList();
  final int maxScore = scores.reduce((i1, i2) => i1 + i2);
  print('Sum of scores: $maxScore');

  for (var i = 0; i < nbLib; i++) {
    final fstLine = lines[i * 2 + 2].split(' ');
    final sndLine = lines[i * 2 + 3].split(' ');
    libs.add(Lib.parseLib(i, fstLine, sndLine, scores));
  }

  final List<List<Lib> Function(int, List<Lib>, List<int>)> functionsToRun = [
    Strategies.naive,
    Strategies.minSUTFirst,
    Strategies.maxRateFirst,
    Strategies.maxScoreFirst,
    Strategies.maxBooksFirst,
    Strategies.calculateScoreEachDay,
  ];

  int bestScore = 0;

  for (var f in functionsToRun) {
    for (var i in libs) {
      i.reset();
    }
    final tmp = f(daysRemaining, libs, scores);
    final achievedScore = tmp.fold<int>(0, (i, l) => i + l.currentScore);
    final percentage = (achievedScore / maxScore) * 100;
    print('method: $f');
    print('-- $achievedScore -- ${percentage.toStringAsFixed(3)}% --');
    if (achievedScore > bestScore) {
      output(tmp, entry.key.replaceAll('.txt', ''));
      bestScore = achievedScore;
      if (percentage > 99.9) {
        break;
      }
    }
  }
  print('Final score: $bestScore');
}

void output(List<Lib> ret, String name) {
  String content = '${ret.length}\n';
  for (Lib l in ret) {
    content += '${l.id} ${l.booksToScan.length}\n';
    content += '${l.scannedBooks}\n';
  }

  final outputFile = File('$outDir/$name.out');
  outputFile.writeAsStringSync(content);
}
