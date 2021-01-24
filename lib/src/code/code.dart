import 'package:MobileSystems/src/note/note.dart';
import 'package:MobileSystems/src/options/db_options.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart' as intl;

changeUpdatedDate(int noteKey) async {
    DBOptions opt = new DBOptions();
    Box<Note> notes = Hive.box<Note>(opt.notesDB);
    Note note = Hive.box<Note>(opt.notesDB)
        .values
        .singleWhere((value) => value.key == noteKey);
    note.dateUpdated = DateTime.now();
    await notes.put(noteKey, note);
  }
  String getDateFormated(DateTime date) {
    return intl.DateFormat('dd-MM-yyyy HH:mm:ss').format(date);
  }