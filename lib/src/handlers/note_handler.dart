import 'package:MobileSystems/src/note/note.dart';
import 'package:MobileSystems/src/options/db_options.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NoteHandler{ 

 static init(HiveAesCipher cipher) async {
    //Initialize the Hive DB
      await Hive.initFlutter();//waits to initialize path on flutter with the default path
      await DBOptions.init();
      DBOptions options = new DBOptions();

    try{
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(NoteTypeAdapter());
    Hive.registerAdapter(CheckListNoteAdapter());
    Hive.registerAdapter(TextNoteAdapter());
    }catch(e){
      print("DB already init");
    }
    print(options.notesDB);
    print(cipher);
    await Hive.openBox<Note>(options.notesDB, encryptionCipher: cipher);//if it's the first time running, it will also create the "Box", else it will just open
    await Hive.openBox<TextNote>(options.textNotesDB, encryptionCipher: cipher);//this box will be used later for the Text Type entries
    await Hive.openBox<CheckListNote>(options.checkListDB, encryptionCipher: cipher);//this box will be used later for the Check List Type entries
  }
 
 static resetPass(HiveAesCipher cipher) async {
   //Get the options
   DBOptions options = new DBOptions();
   await DBOptions.init();
   //Get the old boxes
   Box<Note> notes = Hive.box(options.notesDB);
   Box<TextNote> textnotes = Hive.box(options.textNotesDB);
   Box<CheckListNote> checklist = Hive.box(options.checkListDB);
   //Get the contents
   List<Note> notesList =[];
   if (notes.isNotEmpty) {
     notes.keys.forEach((key) { 
       notesList.add(notes.get(key));
     });
   }
   List<TextNote> textNotesList =[];
   if (textnotes.isNotEmpty) {
     textnotes.keys.forEach((key) { 
       textNotesList.add(textnotes.get(key));
     });
   }
   List<CheckListNote> notescheckList =[];
   if (checklist.isNotEmpty) {
     checklist.keys.forEach((key) { 
       notescheckList.add(checklist.get(key));
     });
   }
   
   //Delete the boxes
   notes.deleteFromDisk();
   textnotes.deleteFromDisk();
   checklist.deleteFromDisk();

   //Create the new boxes
   await options.updateNames();
   print(options.notesDB);
   await Hive.openBox<Note>(options.notesDB, encryptionCipher: cipher);//if it's the first time running, it will also create the "Box", else it will just open
   await Hive.openBox<TextNote>(options.textNotesDB, encryptionCipher: cipher);//this box will be used later for the Text Type entries
   await Hive.openBox<CheckListNote>(options.checkListDB, encryptionCipher: cipher);//this box will be used later for the Check List Type entries
   Box<Note> notes2 = Hive.box(options.notesDB);
   Box<TextNote> textnotes2 = Hive.box(options.textNotesDB);
   Box<CheckListNote> checklist2 = Hive.box(options.checkListDB);
   //Copy all the contents
   if (notesList.isNotEmpty) {
     notesList.forEach((element) { 
       Note newNote = Note(element.dateCreated,element.title,
       element.description,element.dateUpdated,element.noteType,element.position);
       notes2.add(newNote);
     });
   }
   if (textNotesList.isNotEmpty) {
     textNotesList.forEach((element) { 
        TextNote newNote = TextNote(element.text, element.noteParent);
        textnotes2.add(newNote);
     });
   }
   if (notescheckList.isNotEmpty) {
     notescheckList.forEach((element) { 
        CheckListNote newNote = CheckListNote(element.text, element.done, element.position, element.noteParent);
        checklist2.add(newNote);
     });
   }

 }

 }