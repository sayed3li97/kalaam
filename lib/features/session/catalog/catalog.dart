import 'package:genui/genui.dart';

import 'package:kalaam/features/session/catalog/items/conjugation_table_item.dart';
import 'package:kalaam/features/session/catalog/items/cultural_note_item.dart';
import 'package:kalaam/features/session/catalog/items/dialogue_bubble_item.dart';
import 'package:kalaam/features/session/catalog/items/fill_in_blank_item.dart';
import 'package:kalaam/features/session/catalog/items/harakat_builder_item.dart';
import 'package:kalaam/features/session/catalog/items/mastery_ring_item.dart';
import 'package:kalaam/features/session/catalog/items/phoneme_card_item.dart';
import 'package:kalaam/features/session/catalog/items/quick_choice_item.dart';
import 'package:kalaam/features/session/catalog/items/root_explorer_item.dart';
import 'package:kalaam/features/session/catalog/items/scene_card_item.dart';
import 'package:kalaam/features/session/catalog/items/sentence_builder_item.dart';
import 'package:kalaam/features/session/catalog/items/vocab_card_item.dart';
import 'package:kalaam/features/session/catalog/items/vocab_carousel_item.dart';

/// The catalog id the AI must reference in every `createSurface` message.
const String kalaamCatalogId = 'kalaam-widgets-catalog';

/// genui layout + input primitives the AI may use to compose rich screens.
/// (Media/date/modal widgets are intentionally excluded — Kalaam handles audio
/// via flutter_tts, and keeps the catalog focused on teaching.)
final List<CatalogItem> _primitives = [
  BasicCatalogItems.column,
  BasicCatalogItems.row,
  BasicCatalogItems.card,
  BasicCatalogItems.text,
  BasicCatalogItems.button,
  BasicCatalogItems.icon,
  BasicCatalogItems.divider,
  BasicCatalogItems.image,
  BasicCatalogItems.list,
  BasicCatalogItems.tabs,
  BasicCatalogItems.choicePicker,
  BasicCatalogItems.textField,
  BasicCatalogItems.checkBox,
  BasicCatalogItems.slider,
];

/// Kalaam's bespoke Arabic-teaching widgets.
final List<CatalogItem> _kalaamWidgets = [
  sceneCardItem,
  vocabCardItem,
  vocabCarouselItem,
  rootExplorerItem,
  harakatBuilderItem,
  conjugationTableItem,
  phonemeCardItem,
  dialogueBubbleItem,
  culturalNoteItem,
  fillInBlankItem,
  sentenceBuilderItem,
  quickChoiceItem,
  masteryRingItem,
];

/// The full catalog Gemini composes with: genui primitives + Kalaam's custom
/// Arabic widgets. Combining the two lets the model lay out multi-widget
/// lessons (e.g. a Column with an intro Text, a RootExplorer, and a Row of
/// action Buttons) rather than emitting one widget at a time.
final Catalog kalaamCatalog = Catalog([
  ..._primitives,
  ..._kalaamWidgets,
], catalogId: kalaamCatalogId);
