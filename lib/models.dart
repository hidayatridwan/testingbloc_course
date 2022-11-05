import 'package:flutter/foundation.dart' show immutable;

@immutable
class LoginHandle {
  final String token;

  const LoginHandle({required this.token});

  const LoginHandle.fooBar() : token = 'foobar';

  @override
  bool operator ==(covariant LoginHandle other) => token == other.token;

  @override
  int get hashCode => token.hashCode;

  @override
  String toString() => 'LoginHandle (token = $token)';
}

enum LoginErrors { invalidHandle }

@immutable
class Note {
  final String note;

  const Note({required this.note});

  @override
  String toString() => 'Note (note = $note)';
}

final mockNotes = Iterable.generate(3, (i) => Note(note: 'Note ${i++}'));
