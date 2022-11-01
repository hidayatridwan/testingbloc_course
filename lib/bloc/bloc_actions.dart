import 'package:flutter/foundation.dart' show immutable;
import 'package:testingbloc_course/bloc/person.dart';

// enum PersonUrl { person1, person2 }
//
// extension UrlString on PersonUrl {
//   String get urlString {
//     switch (this) {
//       case PersonUrl.person1:
//         return 'http://192.168.1.7:5500/persons1.json';
//       case PersonUrl.person2:
//         return 'http://192.168.1.7:5500/persons2.json';
//     }
//   }
// }

const persons1Url = 'http://192.168.1.7:5500/persons1.json';
const persons2Url = 'http://192.168.1.7:5500/persons2.json';

typedef PersonsLoader = Future<Iterable<Person>> Function(String url);

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonAction implements LoadAction {
  final String url;
  final PersonsLoader loader;

  const LoadPersonAction({required this.url, required this.loader}) : super();
}
