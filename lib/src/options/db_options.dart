import 'package:shared_preferences/shared_preferences.dart';

class DBOptions {
  static final String NOTES_KEY = "notes_db";
  static final String TEXT_NOTES_KEY = "text_notes_db";
  static final String CHECK_LIST_KEY = "checklist_notes_db";
  static String _notes_db = "Notes0";
  static String _text_notes_db = "TextNotes0";
  static String _checklist_notes_db = "CheckList0";
  static int _version = 0;
  static bool _init = false;
  static SharedPreferences _prefs;

  DBOptions() {
    if (!_init) {
      init();
      _init = true;
    }
  }

  String get notesDB => _notes_db;
  String get textNotesDB => _text_notes_db;
  String get checkListDB => _checklist_notes_db;

  init() async {
    _prefs = await SharedPreferences.getInstance();

    //If not initialized then create the settings of the DB
    if (!_prefs.containsKey(NOTES_KEY)) {
      await _prefs.setString(NOTES_KEY, "Notes0");
      await _prefs.setString(TEXT_NOTES_KEY, "TextNotes0");
      await _prefs.setString(CHECK_LIST_KEY, "CheckList0");
    }

    //Get the values of the DB
    _notes_db = _prefs.getString(NOTES_KEY);
    _text_notes_db = _prefs.getString(TEXT_NOTES_KEY);
    _checklist_notes_db = _prefs.getString(CHECK_LIST_KEY);
  }

  Future<void> updateNames() async {
    _version = (_version + 1) % 10; //Set a max of versions
    //Update the variables
    _notes_db =
        _notes_db.substring(0, _notes_db.length - 1) + _version.toString();
    _text_notes_db = _text_notes_db.substring(0, _text_notes_db.length - 1) +
        _version.toString();
    _checklist_notes_db =
        _checklist_notes_db.substring(0, _checklist_notes_db.length - 1) +
            _version.toString();
    //Store the new values
    await _prefs.setString(NOTES_KEY, _notes_db);
    await _prefs.setString(TEXT_NOTES_KEY, _text_notes_db);
    await _prefs.setString(CHECK_LIST_KEY, _checklist_notes_db);
  }
}
