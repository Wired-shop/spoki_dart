[🇬🇧 English](README.md) | **🇮🇹 [Italiano](README.it.md)**

# Technical documentation — spoki_dart

Full API reference for the package.

- Package: `spoki_dart` (v0.1.0)
- SDK: Dart `^3.4.3`
- Runtime dependency: `dio ^5.4.3+1`
- API base URL: `https://api.spoki.com`
- Barrel file (single public import): `package:spoki_dart/core.dart`

## Table of contents

1. [Architecture](#architecture)
2. [ApiService](#apiservice)
3. [Repositories](#repositories)
   - [AccountRepository](#accountrepository)
   - [TemplateRepository](#templaterepository)
   - [MessageRepository](#messagerepository)
   - [AuthRepository](#authrepository)
   - [TemplateAutomationRegistry](#templateautomationregistry)
   - [RoleRepository](#rolerepository)
   - [CustomFieldRepository](#customfieldrepository)
   - [PartnerRepository](#partnerrepository)
   - [AgencyRepository](#agencyrepository)
   - [AutomationRepository](#automationrepository)
4. [Models](#models)
5. [Enums](#enums)
6. [Helpers](#helpers)
7. [Error handling — SpokiException](#error-handling--spokiexception)
8. [End-to-end example](#end-to-end-example)

## Architecture

The package follows the `gym_manager_core` pattern:

- **`ApiService`** — singleton that wraps a shared `dio` client, a
  fixed base URL, and automatic injection of the `X-Spoki-Api-Key`
  header.
- **Static repositories** — one class per REST resource
  (`AccountRepository`, `TemplateRepository`, etc.), every method is
  `static`, no internal state. They call `ApiService.getInstance().dio`
  directly.
- **Models** — immutable classes with `fromJson`/`toJson`, no
  `build_runner`/codegen dependency (mapping written by hand).
- **`lib/core.dart`** — barrel file: the single recommended import
  entry point for consumers of the package.

```
lib/
├── core.dart                     # public barrel file
└── src/
    ├── services/api_service.dart
    ├── repositories/*.dart
    ├── models/*.dart
    ├── enums/*.dart
    ├── helpers/*.dart
    └── exceptions/spoki_exception.dart
```

## ApiService

`lib/src/services/api_service.dart`

Singleton that manages the HTTP client shared by every repository.

```dart
class ApiService {
  static const String restBaseUrl = 'https://api.spoki.com';

  static ApiService getInstance();

  void setApiKey(String apiKey);
  String? getApiKey();

  final Dio dio; // shared dio client, baseUrl = restBaseUrl
}
```

Behavior:

- An `InterceptorsWrapper` automatically adds, on every request made
  with `dio`, the `X-Spoki-Api-Key` header (if set via `setApiKey`)
  and `Content-Type: application/json`.
- On HTTP errors, the interceptor automatically converts the response
  into a readable [`SpokiException`](#error-handling--spokiexception)
  and attaches it to the re-thrown `DioException`.
- **Note**: `MessageRepository._postSend` and `AuthRepository`
  explicitly pass the `X-Spoki-Api-Key` header on the individual
  request (useful for multi-account operations, where the API Key
  varies per call instead of being the singleton's global one).

Typical usage (a single API Key for the whole app):

```dart
ApiService.getInstance().setApiKey('YOUR_API_KEY');
```

## Repositories

All methods are `static` and return a `Future`. Listed endpoints are
relative to `https://api.spoki.com`.

### AccountRepository

`lib/src/repositories/account_repository.dart`

| Method | Endpoint | Returns | Description |
|---|---|---|---|
| `list()` | `GET /api/1/accounts/` | `Future<List<SpokiAccount>>` | Lists the accounts visible with the current API Key. |
| `get(int id)` | `GET /api/1/accounts/{id}/` | `Future<SpokiAccount>` | Detail of a single account. |
| `getPrimary()` | — (uses `list()`) | `Future<SpokiAccount>` | Returns the first account in the list; throws `StateError` if the list is empty. |
| `currentReport(int accountId)` | `GET /api/1/accounts/{accountId}/current_report/` | `Future<SpokiAccountReport>` | Current statistics report for the account. |

### TemplateRepository

`lib/src/repositories/template_repository.dart`

| Method | Endpoint | Returns | Description |
|---|---|---|---|
| `list()` | `GET /api/1/templates/` | `Future<List<SpokiTemplate>>` | Lists WhatsApp templates. |
| `get(int id)` | `GET /api/1/templates/{id}/` | `Future<SpokiTemplate>` | Template detail. |
| `create(SpokiTemplate template, {required TemplateLocalization localization})` | `POST /api/1/templates/` | `Future<SpokiTemplate>` | Creates a new template with an initial localization. |
| `submit(int templateId)` | `POST /api/1/templates/{id}/submit/` | `Future<void>` | Submits the template for review to Meta. |
| `delete(int templateId)` | `DELETE /api/1/templates/{id}/` | `Future<void>` | Deletes the template. |
| `update(int templateId, {required TemplateLocalization localization})` | `PATCH /api/1/templates/{id}/` | `Future<SpokiTemplate>` | ⚠️ Not tested against a real call — updates the localization via `templatelocalization_set`. |
| `backToDraft(int templateId)` | `POST /api/1/templates/{id}/back_to_draft/` | `Future<void>` | ⚠️ Not tested — moves the template back to draft status. |
| `clone(int templateId)` | `GET /api/1/templates/{id}/clone/` | `Future<SpokiTemplate>` | ⚠️ Not tested — clones an existing template. |

### MessageRepository

`lib/src/repositories/message_repository.dart`

Every method that calls `/api/1/messages/send/` passes `apiKey`
explicitly per request (`ApiService.setApiKey` is not required).

| Method | Endpoint | Returns | Description |
|---|---|---|---|
| `sendWhatsappTemplate({required apiKey, required templateId, required phone, required language, email, customFields, buttons, metadata, channelId})` | `POST /api/1/messages/send/` (`type: Template`) | `Future<SpokiSendResult>` | **Main endpoint**: sends a template by id with no pre-configured automation required. |
| `sendWhatsappTemplateWithHeaderMedia({required apiKey, required templateId, required phone, required headerMediaUrl, required headerMediaFilename, email, customFields, metadata, channelId})` | `POST /api/1/messages/send/` | `Future<SpokiSendResult>` | Same as above, with media (image/document) in the template header. |
| `sendText({required apiKey, required phone, required text, metadata, channelId})` | `POST /api/1/messages/send/` (`content_type: Text`) | `Future<SpokiSendResult>` | Free-form text message (outside a template, within the 24h window). |
| `sendWithButtons({required apiKey, required phone, required text, required buttons, header, footer, metadata, channelId})` | `POST /api/1/messages/send/` (`content_type: Interactive`) | `Future<SpokiSendResult>` | Interactive message with buttons. |
| `sendList({required apiKey, required phone, required text, required list, header, footer, metadata, channelId})` | `POST /api/1/messages/send/` (`content_type: List`) | `Future<SpokiSendResult>` | Message with a list of options. |
| `sendWhatsappViaAutomation({required automationUrl, required secret, required phone, firstName, lastName, email, language, customFields, metadata})` | `POST {automationUrl}` (external webhook, not `api.spoki.com`) | `Future<SpokiSendResult>` | Sends via a pre-configured Spoki automation (legacy model, useful for multi-step flows). |
| `sendWhatsappViaAutomationBulk({required automationUrl, required secret, required contacts})` | `POST {automationUrl}/bulk/` | `Future<SpokiSendResult>` | Bulk send via automation to multiple contacts in a single call. |
| `send({required channel, required automationUrl, required secret, required phone, firstName, lastName, email, customFields})` | — (dispatcher) | `Future<SpokiSendResult>` | Routes based on `SpokiChannelType`; only `whatsapp` is implemented, `sms`/`voice` throw `UnimplementedError`. |

Implementation notes:

- `sendWhatsappViaAutomation*` and `AuthRepository` instantiate a
  **new** `Dio()` (not the `ApiService` singleton), because the target
  URL is the client's custom automation, not `api.spoki.com`.
- All HTTP errors from the `_postSend`/via-automation methods are
  caught and re-thrown as `SpokiException`.

### AuthRepository

`lib/src/repositories/auth_repository.dart`

| Method | Endpoint | Returns | Description |
|---|---|---|---|
| `getAuthenticationToken({required apiKey, required email, required privateKey})` | `POST /api/1/auth/get_authentication_token/` | `Future<SpokiAuthToken>` | Obtains a token for embedding the Spoki UI (chat, etc.) via iframe. Verified against a real call. |

### TemplateAutomationRegistry

`lib/src/repositories/template_automation_registry.dart`

Not a "static repository" but an instantiable class that keeps an
in-memory registry `templateKey → TemplateAutomationConfig`, useful to
centralize URLs/secrets for legacy per-template automations.

```dart
class TemplateAutomationRegistry {
  void register(TemplateAutomationConfig config);
  void registerAll(List<TemplateAutomationConfig> configs);
  List<String> get registeredKeys;

  Future<SpokiSendResult> send({
    required String templateKey,
    required String phone,
    String? firstName,
    String? lastName,
    String? email,
    Map<String, String> customFields = const {},
  });
}
```

`send()` looks up the config for `templateKey` and delegates to
`MessageRepository.sendWhatsappViaAutomation`; if the key isn't
registered it throws `SpokiException`.

### RoleRepository

`lib/src/repositories/role_repository.dart`

| Method | Endpoint | Returns | Description |
|---|---|---|---|
| `list()` | `GET /api/1/roles/` | `Future<List<SpokiRole>>` | ⚠️ Not tested — lists the account's roles/users. |
| `get(int roleId)` | `GET /api/1/roles/{id}/` | `Future<SpokiRole>` | Role detail. |
| `addServiceUser({required role, required name})` | `POST /api/1/roles/add_service_user/` | `Future<SpokiRole>` | Creates a service user (technical user, not a natural person). |
| `generatePrivateKey(int roleId)` | `POST /api/1/roles/{id}/generate_private_key/` | `Future<Map<String, dynamic>>` | Generates the private key for the service user's authentication. |
| `hasPrivateKey(int roleId)` | `GET /api/1/roles/{id}/has_private_key/` | `Future<bool>` | Checks whether the role already has a private key generated. |
| `updateRole(int roleId, {required role})` | `POST /api/1/roles/{id}/update_role/` | `Future<void>` | Changes the assigned role. |
| `delete(int roleId)` | `DELETE /api/1/roles/{id}/` | `Future<void>` | Deletes the role/user. |

### CustomFieldRepository

`lib/src/repositories/custom_field_repository.dart`

| Method | Endpoint | Returns | Description |
|---|---|---|---|
| `list()` | `GET /api/1/custom-fields/` | `Future<List<SpokiCustomField>>` | ⚠️ Not tested — lists custom fields. |
| `get(int id)` | `GET /api/1/custom-fields/{id}/` | `Future<SpokiCustomField>` | Field detail. |
| `create({required label, required code, required fieldType, example})` | `POST /api/1/custom-fields/` | `Future<SpokiCustomField>` | Creates a custom field (`fieldType` is the int `apiValue` of [`SpokiCustomFieldType`](#spokicustomfieldtype)). |
| `update(int id, {label})` | `PATCH /api/1/custom-fields/{id}/` | `Future<SpokiCustomField>` | Updates the label. |
| `delete(int id)` | `DELETE /api/1/custom-fields/{id}/` | `Future<void>` | Deletes the field. |

⚠️ **Do not use to create** `FIRST_NAME`, `LAST_NAME`, `EMAIL`, `PHONE`,
`ACCOUNT_NAME`, `LANGUAGE` — these are reserved by the platform.

### PartnerRepository

`lib/src/repositories/partner_repository.dart`

All methods return a raw `Map<String, dynamic>` (no dedicated model).
⚠️ Schema from official documentation, not tested against real calls.

| Method | Endpoint | Description |
|---|---|---|
| `getAssociatedAccounts()` | `GET /api/1/partners/accounts/` | List of client accounts visible with a Partner-level API Key. |
| `createApiKeyForAccount(int accountId)` | `POST /api/1/partners/create_api_key_for_account/` | Creates an API Key for a client account, without going through the dashboard. |
| `revokeApiKeyForAccount(int accountId)` | `POST /api/1/partners/revoke_api_key_for_account/` | Revokes a client account's API Key. |
| `createOnboardingLink(int accountId)` | `POST /api/1/partners/onboarding/` | Generates an onboarding link for the account. |
| `addSoftwareVendorClients(List<Map<String, dynamic>> clients)` | `POST /api/1/partners/add_sv_clients/` | Creates new client accounts via API. |
| `createMetaCreditSubrecharge({required destinationAccount, required amountMillis})` | `POST /api/1/partners/create_subrecharge/` | Tops up Meta credit on a client account (amount in thousandths of a euro). |
| `setAccountProfitMargins({required destinationAccount, smsProfitMargin, smsOneWayProfitMargin, utilityProfitMargin, authenticationProfitMargin, marketingProfitMargin, serviceProfitMargin, conversationProfitMargin})` | `POST /api/1/partners/set_profits/` | Sets resale profit margins per message category. |
| `moveCreditFromAccount({required accountId, required creditToMoveMillis})` | `POST /api/1/partners/move_credit_from_account/` | Moves credit out of a client account (amount in thousandths of a euro). |
| `getAccountReport({required accountId, required granularity, required startDate, required endDate})` | `GET /api/1/partners/get_account_report/` | Aggregated report over a date range. |
| `getAccountForecasts({required accountId, required countryCode})` | `GET /api/1/partners/get_account_forecasts/` | Usage/cost estimates per country. |

### AgencyRepository

`lib/src/repositories/agency_repository.dart`

⚠️ Schema from documentation, not tested. Returns a raw
`Map<String, dynamic>` (no dedicated model).

| Method | Endpoint | Description |
|---|---|---|
| `list()` | `GET /api/1/agencies/` | Lists agencies. |
| `get(int agencyId)` | `GET /api/1/agencies/{id}/` | Agency detail. |

### AutomationRepository

`lib/src/repositories/automation_repository.dart`

⚠️ Schema from documentation (very detailed for `create`), not tested
against real calls.

| Method | Endpoint | Returns | Description |
|---|---|---|---|
| `list()` | `GET /api/1/automations/` | `Future<List<SpokiAutomation>>` | Lists automations. |
| `get(int automationId)` | `GET /api/1/automations/{id}/` | `Future<SpokiAutomation>` | Automation detail. |
| `customFieldsUsed(int automationId)` | `GET /api/1/automations/{id}/custom-fields-used/` | `Future<Map<String, dynamic>>` | Custom fields referenced by the automation. |
| `create({required name, description, category, isActive = true, isFavorite = false, automationGroups, steps, webhookSet, onFirstMessageStarterSet, fieldConditionStarterSet})` | `POST /api/1/automations/` | `Future<SpokiAutomation>` | Creates a full automation with steps, triggers and conditions. |

The schema of individual `step`s (in `steps`) supports over 40
different types documented in the official Postman collection, but not
all of them are modeled in this package (to keep its size in check).
Pass them as raw `List<Map<String, dynamic>>`, or use the
[`AutomationStepBuilder`](#automationstepbuilder) helpers for the most
common types.

## Models

All models expose hand-written `fromJson`/`toJson` (no codegen) and a
`toString()` based on `toJson()`.

### SpokiAccount

`lib/src/models/spoki_account.dart` — represents a WhatsApp Business
account on Spoki.

Main fields (all nullable except `id`):
`id`, `name`, `currentCreditMillis`, `status`, `defaultLanguage`,
`phone`, `hasOfficialVerification`, `dailyLimit`, `phoneStatus`,
`qualityScore`, `qualityReasons`, `isActive`, `countryCode`,
`accountType`, `defaultPricingDelta`, `lowCreditThreshold`,
`hasLowCreditAlert`, `minCreditBalanceMillicents`, `defaultPrefix`,
`defaultCountryCode`, `timezone`, `contactedIn24h`, `contactedIn7d`,
`primaryChannelId`, `estimatedAvailableConversations`,
`channels: List<SpokiChannel>`.

Useful getters/methods:

- `double? get currentCreditEuros` — `currentCreditMillis / 1000`.
  **Important**: `current_credit` from the API is expressed in
  thousandths of a euro.
- `bool get isLowCredit` — true if `hasLowCreditAlert` is set, or the
  credit is below `lowCreditThreshold`.
- `int? estimatedMessagesAtPrice(double pricePerMessageEuros)` —
  estimates how many messages can still be sent at the given resale
  price (unlike `estimated_available_conversations`, which is
  computed by Spoki at *its own* wholesale price).

### SpokiAccountReport

`lib/src/models/spoki_account_report.dart` — statistics for an account
over a given period. Fields: `accountId`, `granularity`,
`periodStart`, `contactedContacts`, `templateMessageCount`,
`freeMessageCount`, `incomingMessageCount`, `exchangedMessages`,
`sentMessageCount`, `deliveredMessageCount`, `readMessageCount`,
`conversationCount`, `createdDatetime`, `updatedDatetime` (date fields
are `DateTime?` parsed from ISO8601).

### SpokiAuthToken

`lib/src/models/spoki_auth_token.dart` — token for iframe embedding.
Fields: `token`, `uid` (both required).

- `String buildIframeUrl({String pageSlug = 'chats', String language = 'it'})`
  builds the URL `https://spoki.app/{pageSlug}?auth_token=...&auth_uid=...&language=...`.

### SpokiAutomation

`lib/src/models/spoki_automation.dart` — Fields: `id` (required),
`name`, `isActive`, `isFavorite`, `webhookSet: List<Map<String, dynamic>>`.

- `String? get firstWebhookUrl` — reads `link` from the first element
  of `webhookSet`, if present.

### SpokiChannel

`lib/src/models/spoki_channel.dart` — WhatsApp number linked to an
account. Fields: `id`, `name`, `phone`, `phoneStatus`, `qualityScore`,
`qualityReasons`, `hasOfficialVerification`, `dailyLimit`,
`accountType`, `isActive` (all nullable).

### SpokiCustomField

`lib/src/models/spoki_custom_field.dart` — Fields: `id`,
`label` (required), `code` (required), `fieldType` (required, int —
see [`SpokiCustomFieldType`](#spokicustomfieldtype)), `example`.

### SpokiRole

`lib/src/models/spoki_role.dart` — account user/role. Fields: `id`,
`name`, `email`, `role`, `isServiceUser` (all nullable).

### SpokiSendResult

`lib/src/models/spoki_send_result.dart` — result of a message send.
Fields: `accepted: bool` (defaults to `false` if absent),
`raw: Map<String, dynamic>` (the full API response).

### SpokiTemplate

`lib/src/models/spoki_template.dart` — WhatsApp template. Fields: `id`,
`name` (required), `category: SpokiTemplateCategory` (defaults to
`marketing`), `subcategory` (defaults to `'CLASSIC'`), `isApproved`
(defaults to `false`), `isFavorite` (defaults to `false`),
`customFieldSet: List<String>`,
`localizations: List<TemplateLocalization>`.

- `SpokiTemplateStatus get overallStatus` — derives the template's
  aggregate status from its localizations (priority: approved →
  rejected → pending → first localization's status → unknown).
- `TemplateLocalization? localizationFor(String language)` — looks up
  the localization for a language code.
- `Map<String, dynamic> toCreatePayload({required TemplateLocalization localization})`
  — minimal payload for `TemplateRepository.create`.

### TemplateAutomationConfig

`lib/src/models/template_automation_config.dart` — configuration for
`TemplateAutomationRegistry`. Fields (all required): `templateKey`,
`automationUrl`, `secret`.

### TemplateButton

`lib/src/models/template_button.dart` — a template button. Fields:
`componentType`, `order`, `buttonType`, `text`, `phoneNumber`, `url`,
`formId`, `sendAsShortlink`, `shortlinkCode` (all nullable).

### TemplateComponent

`lib/src/models/template_component.dart` — generic template component
(header/body/footer). Fields: `componentType` (required), `format`,
`text`, `parameters: List<dynamic>`.

### TemplateLocalization

`lib/src/models/template_localization.dart` — a template's version for
a specific language. Fields: `id`, `language` (required),
`status: SpokiTemplateStatus` (defaults to `unknown`),
`rejectionReason`, `rejectionDetail`, `rejectionRecommendation`,
`statusUpdatedAt`, `header: TemplateComponent?`,
`body: TemplateComponent` (required), `footer: TemplateComponent?`,
`buttons: List<TemplateButton>`, `defaultHeaderMedia: TemplateMedia?`,
`exampleCustomFields: Map<String, String>`.

- `Map<String, dynamic> toCreatePayload()` — reduced payload (without
  `id`/`status`/metadata) used by `TemplateRepository.create`/`update`.

### TemplateMedia

`lib/src/models/template_media.dart` — default media in a template's
header. Fields: `id`, `title`, `mediaUrl`, `contentType`,
`formatType`, `externalUrl`, `externalId`, `isDeleted` (all nullable).

## Enums

### SpokiChannelType

`lib/src/enums/spoki_channel_type.dart` — `whatsapp`, `sms`, `voice`.
`sms`/`voice` exist in anticipation of a future extension, but
**are not implemented** on the send side (`MessageRepository.send`
throws `UnimplementedError` for these two channels).

- `static SpokiChannelType fromString(String value)` — case-insensitive,
  defaults to `whatsapp` if the value isn't recognized.

### SpokiCustomFieldType

`lib/src/enums/spoki_custom_field_type.dart` — `text`, `date`, `datetime`.

- `int get apiValue` — `text → 1`, `date → 2`, `datetime → 3`.

### SpokiTemplateCategory

`lib/src/enums/spoki_template_category.dart` — `utility`, `marketing`,
`authentication`.

- `String get apiValue` — `'UTILITY'`, `'MARKETING'`, `'AUTHENTICATION'`.
- `static SpokiTemplateCategory fromString(String? value)` —
  case-insensitive, defaults to `marketing`.

### SpokiTemplateStatus

`lib/src/enums/spoki_template_status.dart` — `approved`, `pending`,
`rejected`, `unknown`.

- `static SpokiTemplateStatus fromString(String? value)` —
  case-insensitive; `'REVIEW'` maps to `pending`; defaults to
  `unknown`.

## Helpers

### AutomationStepBuilder

`lib/src/helpers/automation_step_builder.dart` — builds the `step`
maps for `AutomationRepository.create`, covering the most common types
(the full schema supports over 40; for other types, build the map by
hand following `step_type` + type-specific fields).

| Method | Produces (`step_type`) |
|---|---|
| `templateMessage({required templateId, customFieldValues, position})` | `'TemplateMessage'` |
| `freeMessage({required text, position})` | `'FreeMessage'` |
| `delay({required delaySeconds, position})` | `'Delay'` |
| `addTag({required tags, position})` | `'AddTag'` |
| `webhookTrigger({required name})` | webhook trigger (`{'name': name, 'platform': 'api'}`) |

### TemplatePlaceholders

`lib/src/helpers/template_placeholders.dart` — utility for the
`%%FIELD%%` placeholders in template text.

- `static List<String> extract(String text)` — extracts placeholder
  names (without `%%`), deduplicated, in order of appearance.
- `static bool looksRiskyRatio(String bodyText)` — heuristic to detect
  templates with too many placeholders relative to static text (static
  words < placeholders × 2); useful to anticipate the Spoki
  `spoki::3014` error (see
  [`SpokiException`](#error-handling--spokiexception)) before
  submitting the template.

## Error handling — SpokiException

`lib/src/exceptions/spoki_exception.dart`

```dart
class SpokiException implements Exception {
  final String message;   // human-readable message, translated to Italian when possible
  final int? httpStatus;
  final String? code;     // Spoki error code, e.g. "spoki::3014"
  final String? rawBody;  // original response body, for debugging
}
```

`SpokiException.fromResponse({required httpStatus, required body})` is
the constructor used internally by `ApiService` (global interceptor)
and by the methods that instantiate their own `Dio`
(`MessageRepository`/`AuthRepository`). Translation logic, in priority
order:

1. **Known error codes** — e.g. `spoki::3014` (too many `%%FIELD%%`
   variables relative to static text) is translated into an
   explanatory message.
2. **Per-field validation errors** — if the body is an object without
   `code`/`detail`/`title` but with per-field errors (e.g. DRF
   responses), they are translated recursively (`required` messages
   become "Missing required field: ...").

   > Note: the messages produced by this step are currently emitted in
   > Italian in the underlying code (`SpokiException` is not yet
   > localized per-locale); see the source for details.
3. **Generic `detail`/`title`** — prefixed with `"Untranslated error: "`
   if it couldn't be mapped to a known message.
4. **Fallback by HTTP status** — `401`/`403` → message about the API
   Key, `404` → resource not found, `429` → too many requests, `≥500`
   → Spoki server error.
5. **Final fallback** — `"Unknown error ({status})."`.

All repositories that handle errors explicitly (`MessageRepository`,
`AuthRepository`) catch `DioException` and re-throw `SpokiException`;
the other repositories rely on `ApiService`'s global interceptor, which
does the same work transparently.

## End-to-end example

```dart
import 'package:spoki_dart/core.dart';

Future<void> main() async {
  ApiService.getInstance().setApiKey('YOUR_API_KEY');

  // 1. Primary account and remaining credit
  final account = await AccountRepository.getPrimary();
  print('Credit: €${account.currentCreditEuros}');
  if (account.isLowCredit) {
    print('Warning: low credit!');
  }

  // 2. List of available templates
  final templates = await TemplateRepository.list();
  final approved = templates.where((t) => t.isApproved).toList();

  // 3. Send a template by id — no automation to configure
  try {
    final result = await MessageRepository.sendWhatsappTemplate(
      apiKey: 'YOUR_API_KEY',
      templateId: approved.first.id!,
      phone: '+393331234567',
      language: 'IT',
      customFields: {'FIRST_NAME': 'Mario'},
    );
    print('Accepted: ${result.accepted}');
  } on SpokiException catch (e) {
    print('Spoki error: ${e.message} (status ${e.httpStatus})');
  }
}
```

See also [example/lib/main.dart](example/lib/main.dart) for a full
example with a Flutter UI.
