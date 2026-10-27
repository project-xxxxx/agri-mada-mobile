import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/utils/client_uuid.dart';

void main() {
  final uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  test('produit un UUID v4 accepté par le serveur', () {
    for (var i = 0; i < 200; i++) {
      expect(generateClientUuid(), matches(uuidV4));
    }
  });

  test('ne produit pas deux fois le même identifiant', () {
    final generated = {for (var i = 0; i < 1000; i++) generateClientUuid()};

    expect(generated, hasLength(1000));
  });
}
