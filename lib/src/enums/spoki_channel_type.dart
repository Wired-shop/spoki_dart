enum SpokiChannelType {
  whatsapp,
  sms,
  voice;

  static SpokiChannelType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'whatsapp':
        return SpokiChannelType.whatsapp;
      case 'sms':
        return SpokiChannelType.sms;
      case 'voice':
        return SpokiChannelType.voice;
      default:
        return SpokiChannelType.whatsapp;
    }
  }
}
