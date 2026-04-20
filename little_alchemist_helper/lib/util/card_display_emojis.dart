/// Tier emoji for [AlchemyCard.rarity] keys (`common`, `uncommon`, …).
String rarityTierEmoji(String rarityKey) {
  switch (rarityKey.trim().toLowerCase()) {
    case 'common':
      return '🟤';
    case 'uncommon':
      return '⚪️';
    case 'rare':
      return '🟡';
    case 'diamond':
      return '🔵';
    case 'onyx':
      return '🟣';
    default:
      return '💎';
  }
}

/// Emoji for fusion ability line; first token matches English ability name.
String fusionAbilityEmoji(String fusionAbilityText) {
  final String trimmed = fusionAbilityText.trim();
  if (trimmed.isEmpty) {
    return '✨';
  }
  final String head = trimmed.split(RegExp(r'[\s\-–—]+')).first.toLowerCase();
  const Map<String, String> map = <String, String>{
    'orb': '🔮',
    'absorb': '💙',
    'amplify': '🌩',
    'block': '🍳',
    'counter': '🦐',
    'critical': '⚡',
    'crushing': '↩️',
    'curse': '☠',
    'pierce': '↘',
    'pillage': '🪝',
    'plunder': '🧲',
    'protect': '🛡️',
    'reflect': '↗',
    'siphon': '🩵',
    'weaken': '💀',
  };
  return map[head] ?? '✨';
}
