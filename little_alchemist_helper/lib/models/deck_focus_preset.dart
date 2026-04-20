/// Step-by-step deck filling mode.
enum DeckFocusPreset {
  /// Choose the next card by maximum attack gain in combos with the deck.
  attack,

  /// Choose the next card by maximum defense gain in combos with the deck.
  defense,

  /// Choose the next card by total attack + defense of combo results.
  sumStats,
}
