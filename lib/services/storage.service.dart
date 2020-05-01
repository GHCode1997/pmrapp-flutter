import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static Future<dynamic> loadImage(File file, String image) async {
    final StorageReference storageReference =
        FirebaseStorage.instance.ref().child(image);
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StreamSubscription<StorageTaskEvent> streamSubscription =
        uploadTask.events.listen((event) {
      print('EVENT ${event.type}');
    });
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    streamSubscription.cancel();
    return (await downloadUrl.ref.getDownloadURL());
  }
}
