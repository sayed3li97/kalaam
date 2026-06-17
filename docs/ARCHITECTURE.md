# Architecture

Kalaam is a Flutter app that lets a Gemini model **compose the UI at runtime** via the
[`genui`](https://pub.dev/packages/genui) package (A2UI v0.9). This document explains the
moving parts and the conventions.

## The GenUI loop

```
 user tap/answer ─▶ UserActionEvent ─▶ SurfaceController.onSubmit
                                            │ ChatMessage(UiInteractionPart)
                                            ▼
   firebase_ai (Gemini)  ◀── system prompt + catalog JSON schema + chat history
            │ streams text containing fenced A2UI JSON
            ▼
   A2uiTransportAdapter.addChunk ─parse─▶ SurfaceController.handleMessage
            │                                   │ creates/updates Surfaces + DataModel
            │                                   ▼
            │                         Surface widgets (the visible lesson)
            └─────────── a2uiLog ──────▶ Live GenUI Inspector
```

1. The session screen sends an opening message (scenario or free-text goal).
2. `AiSessionService._handleSend` streams the conversation to Gemini and pipes the
   response text into `A2uiTransportAdapter.addChunk`.
3. The transport parses fenced ```json A2UI messages (`createSurface`,
   `updateComponents`, `updateDataModel`) and the `SurfaceController` renders them.
4. Interactive widgets dispatch a `UserActionEvent` (via `sendKalaamAction`) carrying the
   result in its `context` map. The controller turns it into a `ChatMessage` on
   `onSubmit`, which `Conversation` forwards back to the model — closing the loop.

> **Key SDK fact:** `ChatMessage.text` excludes `UiInteractionPart` (DataPart) payloads,
> and `handleUiEvent` does **not** auto-attach the data model. So the service merges
> `message.parts.uiInteractionParts` explicitly, and widgets put the answer in the action
> `context`. This is the bug that, unfixed, silently drops every interaction.

## Layers (feature-first)

| Layer | Rule | Where |
|---|---|---|
| **View** | Layout + watch providers + navigate. No business logic. | `features/*/view/` |
| **ViewModel** | `Notifier` holding screen state + intents (`startSession`, `sendMessage`). | `features/session/viewmodel/` |
| **Service** | The genui transport + Gemini conversation. | `shared/services/ai_session_service.dart` |
| **Repository** | Single source of truth for persisted data. | `shared/repositories/` |
| **Model** | Immutable `freezed` data. | `shared/models/` |

State management is **Riverpod** (codegen `@riverpod`). Routing is **go_router**.

## The catalog (the heart of the showcase)

`features/session/catalog/catalog.dart` combines genui **primitives**
(`Column`, `Row`, `Card`, `Text`, `Button`, `Icon`, `Divider`, `List`) with Kalaam's
**custom Arabic widgets** (`items/*.dart`). Each `CatalogItem` has:

- `name` — the component name the model emits;
- `dataSchema` — the JSON schema the model must satisfy (kept **permissive**: no enums on
  display-only fields, widget-managed state fields optional — over-strict schemas fail
  validation and break whole turns);
- `exampleData` — a one-shot example the model learns from;
- `widgetBuilder` — the Flutter widget.

Display widgets carry a built-in `KalaamContinueButton`; exercises advance by dispatching
on answer. The prompt forbids the model from composing its own navigation buttons (avoids
duplicates).

## Demo vs Live

A `--dart-define=KALAAM_DEMO=true` flag swaps the live Gemini transport for a scripted
replay of canned A2UI transcripts (`features/session/demo/`) through the *same*
`A2uiTransportAdapter` — so Demo Mode exercises the real render pipeline with no backend.
Live mode (default) uses `FirebaseAI.googleAI()` (Gemini Developer API).

## RTL & i18n

The app is Arabic-first: `MaterialApp` sets `locale: ar`, `supportedLocales`, and the
`GlobalMaterialLocalizations` delegates, so the whole tree lays out right-to-left.
