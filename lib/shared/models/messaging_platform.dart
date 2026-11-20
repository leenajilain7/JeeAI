enum MessagingPlatform {
  whatsapp('WhatsApp'),
  instagram('Instagram'),
  facebookMessenger('Facebook Messenger');

  const MessagingPlatform(this.displayName);

  final String displayName;
}
