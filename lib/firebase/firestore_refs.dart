import 'package:beat_the_beetroot/models/collection_walk.dart';
import 'package:beat_the_beetroot/models/field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final fieldsRef = FirebaseFirestore.instance
    .collection('apps_data')
    .doc('beat_the_beetroot')
    .collection('fields')
    .withConverter<Field>(
  fromFirestore: (snapshot, _) {
    return Field.fromJson(snapshot.id, snapshot.data()!);
  },
  toFirestore: (field, _) {
    return field.toJson();
  },
);

CollectionReference<CollectionWalk> collectionWalksRef(String fieldId) {
  return fieldsRef
      .doc(fieldId)
      .collection('collection_walks')
      .withConverter<CollectionWalk>(
    fromFirestore: (snapshot, _) {
      return CollectionWalk.fromJson(snapshot.id, snapshot.data()!);
    },
    toFirestore: (path, _) {
      return path.toJson();
    },
  );
}
