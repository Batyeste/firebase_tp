import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


class FirebaseService {

  // get Collection name codes
  CollectionReference codes = FirebaseFirestore.instance.collection('codes');
  
  // create new document in the collection
  Future<DocumentReference> createCode(String code) async {

    final DocumentReference documentReference = codes.doc();

    await codes.add({
      'code': code
    });

    return documentReference;
  }

  // get all the document in the collection
  Stream<QuerySnapshot> getCodes() {
    final getCodes = codes.snapshots();

    return getCodes;
  }

  // delete a document in the collection
  Future<void> deleteCode(String id) async {
    await codes.doc(id).delete();
  }

  // update a document in the collection
  Future<void> updateCode(String id, String code) async {
    await codes.doc(id).update({
      'code': code
    });
  }


}