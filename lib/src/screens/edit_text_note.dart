import 'package:MobileSystems/src/code/code.dart';
import 'package:MobileSystems/src/options/db_options.dart';
import 'package:MobileSystems/src/options/user_options.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:MobileSystems/src/note/note.dart';

class EditTextNote extends StatefulWidget {
  final int noteParent;
  final String noteTitle;
  EditTextNote({Key key, @required this.noteParent, @required this.noteTitle})
      : super(key: key);

  @override
  _EditTextNoteState createState() => _EditTextNoteState();
}

class _EditTextNoteState extends State<EditTextNote> {
  DBOptions opt = DBOptions();
  TextNote textNote;


  @override
  Widget build(BuildContext context) {
    textNote = Hive.box<TextNote>(opt.textNotesDB)
        .values
        .singleWhere((value) => value.noteParent == widget.noteParent);
    _textController.text = textNote.text;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Expanded(
                child: text(),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          saveTextNote(context);
        },
      ),
    );
  }

  final TextEditingController _textController = TextEditingController();

  text() {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: 999,//hope that's enough lines!
      controller: _textController,
      style: TextStyle(fontSize: 18),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
          hintText: "Write your Note",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
    );
  }

  saveTextNote(BuildContext context) async {
    textNote.text = _textController.text;
    Box<TextNote> tNotes = Hive.box<TextNote>(opt.textNotesDB);
    await tNotes.put(textNote.key, textNote);
    changeUpdatedDate(widget.noteParent);
    Navigator.of(context).pop();
  }
}
