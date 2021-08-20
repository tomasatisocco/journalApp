import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journal/models/journal.dart';
import 'db_firestore_api.dart';

class DbFirestoreService implements DbApi{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionJournals = 'journals';

  Stream<List<Journal>> getJournalList(String uid){
   return _firestore
    .collection(_collectionJournals)
    .where('uid', isEqualTo: uid)
    .snapshots()
    .map((QuerySnapshot snapshot){
      List<Journal> _journalDocs = snapshot.docs.map((doc) => Journal.fromDoc(doc)).toList();
      _journalDocs.sort((comp1, comp2) => comp2.date.compareTo(comp1.date));
      return _journalDocs;
    });
  }

  Future<bool> addJournal(Journal journal) async{
    DocumentReference _documentReference = 
    await _firestore.collection(_collectionJournals).add({
      'date' : journal.date,
      'mood' : journal.mood,
      'note' : journal.note,
      'uid' : journal.uid,
    });
    // ignore: unnecessary_null_comparison
    return _documentReference.id != null;
  }

  void updateJournal(Journal journal) async{
    await _firestore
    .collection(_collectionJournals)
    .doc(journal.documentID)
    .update({
      'date' : journal.date,
      'mood' : journal.mood,
      'note' : journal.note,
    })
    .catchError((error) => print('Error updating: $error'));
  }

  void deleteJournal(Journal journal) async{
    await _firestore
    .collection(_collectionJournals)
    .doc(journal.documentID)
    .delete()
    .catchError((error) => print('Error deleting: erre'));
  }

  @override
  Future<Journal> getJournal(String documentID) {
    // TODO: implement getJournal
    throw UnimplementedError();
  }

  @override
  void updateJournalWithTransaction(Journal journal) {
    // TODO: implement updateJournalWithTransaction
  }
}  