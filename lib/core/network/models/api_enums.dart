/// Wire platform values returned by the backend's `Platform` enum.
enum ApiPlatform {
  whatsapp('WHATSAPP'),
  instagram('INSTAGRAM'),
  facebookMessenger('FACEBOOK_MESSENGER'),
  unknown('UNKNOWN');

  const ApiPlatform(this.wireValue);

  final String wireValue;

  static ApiPlatform fromJson(Object? value) => switch (value) {
    'WHATSAPP' => ApiPlatform.whatsapp,
    'INSTAGRAM' => ApiPlatform.instagram,
    'FACEBOOK_MESSENGER' => ApiPlatform.facebookMessenger,
    _ => ApiPlatform.unknown,
  };

  String toJson() => wireValue;
}

/// Wire values returned by the backend's `MessageDirection` enum.
enum ApiMessageDirection {
  incoming('INCOMING'),
  outgoing('OUTGOING'),
  unknown('UNKNOWN');

  const ApiMessageDirection(this.wireValue);

  final String wireValue;

  static ApiMessageDirection fromJson(Object? value) => switch (value) {
    'INCOMING' => ApiMessageDirection.incoming,
    'OUTGOING' => ApiMessageDirection.outgoing,
    _ => ApiMessageDirection.unknown,
  };

  String toJson() => wireValue;
}

/// Wire values returned by the backend's `MessageStatus` enum.
enum ApiMessageStatus {
  sending('SENDING'),
  sent('SENT'),
  delivered('DELIVERED'),
  read('READ'),
  failed('FAILED'),
  unknown('UNKNOWN');

  const ApiMessageStatus(this.wireValue);

  final String wireValue;

  static ApiMessageStatus fromJson(Object? value) => switch (value) {
    'SENDING' => ApiMessageStatus.sending,
    'SENT' => ApiMessageStatus.sent,
    'DELIVERED' => ApiMessageStatus.delivered,
    'READ' => ApiMessageStatus.read,
    'FAILED' => ApiMessageStatus.failed,
    _ => ApiMessageStatus.unknown,
  };

  String toJson() => wireValue;
}
