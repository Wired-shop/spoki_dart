# Documentazione tecnica — spoki_dart

Riferimento API completo del pacchetto. Per il contesto d'uso, gli
avvisi e lo stato di verifica di ogni endpoint vedi [README.md](README.md).

- Package: `spoki_dart` (v0.1.0)
- SDK: Dart `^3.4.3`
- Dipendenza runtime: `dio ^5.4.3+1`
- Base URL API: `https://api.spoki.com`
- Barrel file (unico import pubblico): `package:spoki_dart/core.dart`

## Indice

1. [Architettura](#architettura)
2. [ApiService](#apiservice)
3. [Repository](#repository)
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
4. [Modelli](#modelli)
5. [Enum](#enum)
6. [Helper](#helper)
7. [Gestione errori — SpokiException](#gestione-errori--spokiexception)
8. [Esempio end-to-end](#esempio-end-to-end)

## Architettura

Il pacchetto segue lo schema di `gym_manager_core`:

- **`ApiService`** — singleton che incapsula un client `dio` condiviso,
  base URL fissa e iniezione automatica dell'header `X-Spoki-Api-Key`.
- **Repository statici** — una classe per risorsa REST (`AccountRepository`,
  `TemplateRepository`, ecc.), tutti i metodi sono `static`, nessuno stato
  interno. Chiamano `ApiService.getInstance().dio` direttamente.
- **Modelli** — classi immutabili con `fromJson`/`toJson`, nessuna
  dipendenza da `build_runner`/codegen (mapping scritto a mano).
- **`lib/core.dart`** — barrel file: è l'unico punto di import consigliato
  per chi consuma il pacchetto.

```
lib/
├── core.dart                     # barrel file pubblico
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

Singleton che gestisce il client HTTP condiviso da tutti i repository.

```dart
class ApiService {
  static const String restBaseUrl = 'https://api.spoki.com';

  static ApiService getInstance();

  void setApiKey(String apiKey);
  String? getApiKey();

  final Dio dio; // client dio condiviso, baseUrl = restBaseUrl
}
```

Comportamento:

- Un `InterceptorsWrapper` aggiunge automaticamente, su ogni richiesta
  fatta con `dio`, l'header `X-Spoki-Api-Key` (se impostata con
  `setApiKey`) e `Content-Type: application/json`.
- Sugli errori HTTP, l'interceptor converte automaticamente la risposta
  in una [`SpokiException`](#gestione-errori--spokiexception) leggibile
  e la allega al `DioException` rilanciato.
- **Nota**: `MessageRepository._postSend` e `AuthRepository` passano
  esplicitamente l'header `X-Spoki-Api-Key` nella singola richiesta
  (utile per operazioni multi-account, dove l'API Key varia per
  chiamata invece di essere quella globale del singleton).

Uso tipico (singola API Key per tutta l'app):

```dart
ApiService.getInstance().setApiKey('LA_TUA_API_KEY');
```

## Repository

Tutti i metodi sono `static` e ritornano `Future`. Gli endpoint indicati
sono relativi a `https://api.spoki.com`.

### AccountRepository

`lib/src/repositories/account_repository.dart`

| Metodo | Endpoint | Ritorna | Descrizione |
|---|---|---|---|
| `list()` | `GET /api/1/accounts/` | `Future<List<SpokiAccount>>` | Elenca gli account visibili con l'API Key corrente. |
| `get(int id)` | `GET /api/1/accounts/{id}/` | `Future<SpokiAccount>` | Dettaglio di un account. |
| `getPrimary()` | — (usa `list()`) | `Future<SpokiAccount>` | Ritorna il primo account della lista; lancia `StateError` se la lista è vuota. |
| `currentReport(int accountId)` | `GET /api/1/accounts/{accountId}/current_report/` | `Future<SpokiAccountReport>` | Report statistiche correnti dell'account. |

### TemplateRepository

`lib/src/repositories/template_repository.dart`

| Metodo | Endpoint | Ritorna | Descrizione |
|---|---|---|---|
| `list()` | `GET /api/1/templates/` | `Future<List<SpokiTemplate>>` | Elenca i template WhatsApp. |
| `get(int id)` | `GET /api/1/templates/{id}/` | `Future<SpokiTemplate>` | Dettaglio template. |
| `create(SpokiTemplate template, {required TemplateLocalization localization})` | `POST /api/1/templates/` | `Future<SpokiTemplate>` | Crea un nuovo template con una localizzazione iniziale. |
| `submit(int templateId)` | `POST /api/1/templates/{id}/submit/` | `Future<void>` | Invia il template in revisione a Meta. |
| `delete(int templateId)` | `DELETE /api/1/templates/{id}/` | `Future<void>` | Elimina il template. |
| `update(int templateId, {required TemplateLocalization localization})` | `PATCH /api/1/templates/{id}/` | `Future<SpokiTemplate>` | ⚠️ Non testato con chiamata reale — aggiorna la localizzazione tramite `templatelocalization_set`. |
| `backToDraft(int templateId)` | `POST /api/1/templates/{id}/back_to_draft/` | `Future<void>` | ⚠️ Non testato — riporta il template in stato bozza. |
| `clone(int templateId)` | `GET /api/1/templates/{id}/clone/` | `Future<SpokiTemplate>` | ⚠️ Non testato — clona un template esistente. |

### MessageRepository

`lib/src/repositories/message_repository.dart`

Tutti i metodi che chiamano `/api/1/messages/send/` passano l'`apiKey`
esplicitamente per richiesta (non serve `ApiService.setApiKey`).

| Metodo | Endpoint | Ritorna | Descrizione |
|---|---|---|---|
| `sendWhatsappTemplate({required apiKey, required templateId, required phone, required language, email, customFields, buttons, metadata, channelId})` | `POST /api/1/messages/send/` (`type: Template`) | `Future<SpokiSendResult>` | **Endpoint principale**: invia un template per id senza bisogno di automazioni pre-configurate. |
| `sendWhatsappTemplateWithHeaderMedia({required apiKey, required templateId, required phone, required headerMediaUrl, required headerMediaFilename, email, customFields, metadata, channelId})` | `POST /api/1/messages/send/` | `Future<SpokiSendResult>` | Come sopra, con media (immagine/documento) nell'header del template. |
| `sendText({required apiKey, required phone, required text, metadata, channelId})` | `POST /api/1/messages/send/` (`content_type: Text`) | `Future<SpokiSendResult>` | Messaggio di testo libero (fuori template, entro la finestra 24h). |
| `sendWithButtons({required apiKey, required phone, required text, required buttons, header, footer, metadata, channelId})` | `POST /api/1/messages/send/` (`content_type: Interactive`) | `Future<SpokiSendResult>` | Messaggio interattivo con bottoni. |
| `sendList({required apiKey, required phone, required text, required list, header, footer, metadata, channelId})` | `POST /api/1/messages/send/` (`content_type: List`) | `Future<SpokiSendResult>` | Messaggio con lista di opzioni. |
| `sendWhatsappViaAutomation({required automationUrl, required secret, required phone, firstName, lastName, email, language, customFields, metadata})` | `POST {automationUrl}` (webhook esterno, non `api.spoki.com`) | `Future<SpokiSendResult>` | Invia via automazione pre-configurata su Spoki (modello legacy, utile per flussi multi-step). |
| `sendWhatsappViaAutomationBulk({required automationUrl, required secret, required contacts})` | `POST {automationUrl}/bulk/` | `Future<SpokiSendResult>` | Invio massivo via automazione a più contatti in una chiamata. |
| `send({required channel, required automationUrl, required secret, required phone, firstName, lastName, email, customFields})` | — (dispatcher) | `Future<SpokiSendResult>` | Instrada su `SpokiChannelType`; solo `whatsapp` è implementato, `sms`/`voice` lanciano `UnimplementedError`. |

Note implementative:

- `sendWhatsappViaAutomation*` e `AuthRepository` istanziano un `Dio()`
  **nuovo** (non il singleton `ApiService`), perché l'URL target è
  l'automazione custom del cliente, non `api.spoki.com`.
- Tutti gli errori HTTP sui metodi `_postSend`/via-automazione vengono
  intercettati e rilanciati come `SpokiException`.

### AuthRepository

`lib/src/repositories/auth_repository.dart`

| Metodo | Endpoint | Ritorna | Descrizione |
|---|---|---|---|
| `getAuthenticationToken({required apiKey, required email, required privateKey})` | `POST /api/1/auth/get_authentication_token/` | `Future<SpokiAuthToken>` | Ottiene un token per l'embed via iframe della UI Spoki (chat, ecc.). Verificato con chiamata reale. |

### TemplateAutomationRegistry

`lib/src/repositories/template_automation_registry.dart`

Non è uno "static repository" ma una classe istanziabile che mantiene
un registro in memoria `templateKey → TemplateAutomationConfig`, utile
per centralizzare gli URL/secret delle automazioni legacy per template.

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

`send()` cerca la config per `templateKey` e delega a
`MessageRepository.sendWhatsappViaAutomation`; se la chiave non è
registrata lancia `SpokiException`.

### RoleRepository

`lib/src/repositories/role_repository.dart`

| Metodo | Endpoint | Ritorna | Descrizione |
|---|---|---|---|
| `list()` | `GET /api/1/roles/` | `Future<List<SpokiRole>>` | ⚠️ Non testato — elenca i ruoli/utenti dell'account. |
| `get(int roleId)` | `GET /api/1/roles/{id}/` | `Future<SpokiRole>` | Dettaglio ruolo. |
| `addServiceUser({required role, required name})` | `POST /api/1/roles/add_service_user/` | `Future<SpokiRole>` | Crea un service user (utente tecnico, non persona fisica). |
| `generatePrivateKey(int roleId)` | `POST /api/1/roles/{id}/generate_private_key/` | `Future<Map<String, dynamic>>` | Genera la private key per l'autenticazione del service user. |
| `hasPrivateKey(int roleId)` | `GET /api/1/roles/{id}/has_private_key/` | `Future<bool>` | Controlla se il ruolo ha già una private key generata. |
| `updateRole(int roleId, {required role})` | `POST /api/1/roles/{id}/update_role/` | `Future<void>` | Cambia il ruolo assegnato. |
| `delete(int roleId)` | `DELETE /api/1/roles/{id}/` | `Future<void>` | Elimina il ruolo/utente. |

### CustomFieldRepository

`lib/src/repositories/custom_field_repository.dart`

| Metodo | Endpoint | Ritorna | Descrizione |
|---|---|---|---|
| `list()` | `GET /api/1/custom-fields/` | `Future<List<SpokiCustomField>>` | ⚠️ Non testato — elenca i campi personalizzati. |
| `get(int id)` | `GET /api/1/custom-fields/{id}/` | `Future<SpokiCustomField>` | Dettaglio campo. |
| `create({required label, required code, required fieldType, example})` | `POST /api/1/custom-fields/` | `Future<SpokiCustomField>` | Crea un campo personalizzato (`fieldType` è l'`apiValue` int di [`SpokiCustomFieldType`](#spokicustomfieldtype)). |
| `update(int id, {label})` | `PATCH /api/1/custom-fields/{id}/` | `Future<SpokiCustomField>` | Aggiorna la label. |
| `delete(int id)` | `DELETE /api/1/custom-fields/{id}/` | `Future<void>` | Elimina il campo. |

⚠️ **Non usare per creare** `FIRST_NAME`, `LAST_NAME`, `EMAIL`, `PHONE`,
`ACCOUNT_NAME`, `LANGUAGE` — sono campi riservati dalla piattaforma.

### PartnerRepository

`lib/src/repositories/partner_repository.dart`

Tutti i metodi ritornano `Map<String, dynamic>` grezzo (nessun modello
dedicato). ⚠️ Schema da documentazione ufficiale, non testato con
chiamate reali.

| Metodo | Endpoint | Descrizione |
|---|---|---|
| `getAssociatedAccounts()` | `GET /api/1/partners/accounts/` | Lista degli account cliente visibili con una API Key a livello Partner. |
| `createApiKeyForAccount(int accountId)` | `POST /api/1/partners/create_api_key_for_account/` | Crea una API Key per un account cliente, senza dashboard. |
| `revokeApiKeyForAccount(int accountId)` | `POST /api/1/partners/revoke_api_key_for_account/` | Revoca la API Key di un account cliente. |
| `createOnboardingLink(int accountId)` | `POST /api/1/partners/onboarding/` | Genera un link di onboarding per l'account. |
| `addSoftwareVendorClients(List<Map<String, dynamic>> clients)` | `POST /api/1/partners/add_sv_clients/` | Crea nuovi account cliente via API. |
| `createMetaCreditSubrecharge({required destinationAccount, required amountMillis})` | `POST /api/1/partners/create_subrecharge/` | Ricarica credito Meta su un account cliente (importo in millesimi di euro). |
| `setAccountProfitMargins({required destinationAccount, smsProfitMargin, smsOneWayProfitMargin, utilityProfitMargin, authenticationProfitMargin, marketingProfitMargin, serviceProfitMargin, conversationProfitMargin})` | `POST /api/1/partners/set_profits/` | Imposta i margini di rivendita per categoria di messaggio. |
| `moveCreditFromAccount({required accountId, required creditToMoveMillis})` | `POST /api/1/partners/move_credit_from_account/` | Sposta credito da un account cliente (importo in millesimi di euro). |
| `getAccountReport({required accountId, required granularity, required startDate, required endDate})` | `GET /api/1/partners/get_account_report/` | Report aggregato su un intervallo di date. |
| `getAccountForecasts({required accountId, required countryCode})` | `GET /api/1/partners/get_account_forecasts/` | Stime di utilizzo/costi per paese. |

### AgencyRepository

`lib/src/repositories/agency_repository.dart`

⚠️ Schema da documentazione, non testato. Ritorna `Map<String, dynamic>`
grezzo (nessun modello dedicato).

| Metodo | Endpoint | Descrizione |
|---|---|---|
| `list()` | `GET /api/1/agencies/` | Elenca le agenzie. |
| `get(int agencyId)` | `GET /api/1/agencies/{id}/` | Dettaglio agenzia. |

### AutomationRepository

`lib/src/repositories/automation_repository.dart`

⚠️ Schema da documentazione (molto dettagliato per `create`), non
testato con chiamate reali.

| Metodo | Endpoint | Ritorna | Descrizione |
|---|---|---|---|
| `list()` | `GET /api/1/automations/` | `Future<List<SpokiAutomation>>` | Elenca le automazioni. |
| `get(int automationId)` | `GET /api/1/automations/{id}/` | `Future<SpokiAutomation>` | Dettaglio automazione. |
| `customFieldsUsed(int automationId)` | `GET /api/1/automations/{id}/custom-fields-used/` | `Future<Map<String, dynamic>>` | Campi personalizzati referenziati dall'automazione. |
| `create({required name, description, category, isActive = true, isFavorite = false, automationGroups, steps, webhookSet, onFirstMessageStarterSet, fieldConditionStarterSet})` | `POST /api/1/automations/` | `Future<SpokiAutomation>` | Crea un'automazione completa con step, trigger e condizioni. |

Lo schema dei singoli `step` (in `steps`) supporta oltre 40 tipi diversi
documentati nella collection Postman ufficiale ma non tutti modellati
in questo pacchetto (per non far esplodere la dimensione). Passali come
`List<Map<String, dynamic>>` grezzi, oppure usa gli helper di
[`AutomationStepBuilder`](#automationstepbuilder) per i tipi più comuni.

## Modelli

Tutti i modelli espongono `fromJson`/`toJson` scritti a mano (nessun
codegen) e un `toString()` basato su `toJson()`.

### SpokiAccount

`lib/src/models/spoki_account.dart` — rappresenta un account WhatsApp
Business su Spoki.

Campi principali (tutti nullable tranne `id`):
`id`, `name`, `currentCreditMillis`, `status`, `defaultLanguage`,
`phone`, `hasOfficialVerification`, `dailyLimit`, `phoneStatus`,
`qualityScore`, `qualityReasons`, `isActive`, `countryCode`,
`accountType`, `defaultPricingDelta`, `lowCreditThreshold`,
`hasLowCreditAlert`, `minCreditBalanceMillicents`, `defaultPrefix`,
`defaultCountryCode`, `timezone`, `contactedIn24h`, `contactedIn7d`,
`primaryChannelId`, `estimatedAvailableConversations`,
`channels: List<SpokiChannel>`.

Getter/metodi utili:

- `double? get currentCreditEuros` — `currentCreditMillis / 1000`.
  **Importante**: `current_credit` dall'API è in millesimi di euro.
- `bool get isLowCredit` — true se `hasLowCreditAlert` o se il credito
  è sotto `lowCreditThreshold`.
- `int? estimatedMessagesAtPrice(double pricePerMessageEuros)` — stima
  quanti messaggi si possono ancora inviare al prezzo di rivendita
  indicato (a differenza di `estimated_available_conversations`, che è
  calcolato da Spoki al *suo* prezzo all'ingrosso).

### SpokiAccountReport

`lib/src/models/spoki_account_report.dart` — statistiche di un account
in un dato periodo. Campi: `accountId`, `granularity`, `periodStart`,
`contactedContacts`, `templateMessageCount`, `freeMessageCount`,
`incomingMessageCount`, `exchangedMessages`, `sentMessageCount`,
`deliveredMessageCount`, `readMessageCount`, `conversationCount`,
`createdDatetime`, `updatedDatetime` (i campi data sono `DateTime?`
parsati da ISO8601).

### SpokiAuthToken

`lib/src/models/spoki_auth_token.dart` — token per l'embed iframe.
Campi: `token`, `uid` (entrambi required).

- `String buildIframeUrl({String pageSlug = 'chats', String language = 'it'})`
  costruisce l'URL `https://spoki.app/{pageSlug}?auth_token=...&auth_uid=...&language=...`.

### SpokiAutomation

`lib/src/models/spoki_automation.dart` — Campi: `id` (required),
`name`, `isActive`, `isFavorite`, `webhookSet: List<Map<String, dynamic>>`.

- `String? get firstWebhookUrl` — legge `link` dal primo elemento di
  `webhookSet`, se presente.

### SpokiChannel

`lib/src/models/spoki_channel.dart` — numero WhatsApp collegato a un
account. Campi: `id`, `name`, `phone`, `phoneStatus`, `qualityScore`,
`qualityReasons`, `hasOfficialVerification`, `dailyLimit`,
`accountType`, `isActive` (tutti nullable).

### SpokiCustomField

`lib/src/models/spoki_custom_field.dart` — Campi: `id`,
`label` (required), `code` (required), `fieldType` (required, int —
vedi [`SpokiCustomFieldType`](#spokicustomfieldtype)), `example`.

### SpokiRole

`lib/src/models/spoki_role.dart` — utente/ruolo dell'account. Campi:
`id`, `name`, `email`, `role`, `isServiceUser` (tutti nullable).

### SpokiSendResult

`lib/src/models/spoki_send_result.dart` — risultato di un invio
messaggio. Campi: `accepted: bool` (default `false` se assente),
`raw: Map<String, dynamic>` (risposta completa dell'API).

### SpokiTemplate

`lib/src/models/spoki_template.dart` — template WhatsApp. Campi: `id`,
`name` (required), `category: SpokiTemplateCategory` (default
`marketing`), `subcategory` (default `'CLASSIC'`), `isApproved`
(default `false`), `isFavorite` (default `false`),
`customFieldSet: List<String>`,
`localizations: List<TemplateLocalization>`.

- `SpokiTemplateStatus get overallStatus` — deriva lo stato aggregato
  del template dalle sue localizzazioni (priorità: approvato →
  rifiutato → in attesa → stato della prima localizzazione → sconosciuto).
- `TemplateLocalization? localizationFor(String language)` — cerca la
  localizzazione per codice lingua.
- `Map<String, dynamic> toCreatePayload({required TemplateLocalization localization})`
  — payload minimo per `TemplateRepository.create`.

### TemplateAutomationConfig

`lib/src/models/template_automation_config.dart` — configurazione per
`TemplateAutomationRegistry`. Campi (tutti required): `templateKey`,
`automationUrl`, `secret`.

### TemplateButton

`lib/src/models/template_button.dart` — bottone di un template. Campi:
`componentType`, `order`, `buttonType`, `text`, `phoneNumber`, `url`,
`formId`, `sendAsShortlink`, `shortlinkCode` (tutti nullable).

### TemplateComponent

`lib/src/models/template_component.dart` — componente generico di
template (header/body/footer). Campi: `componentType` (required),
`format`, `text`, `parameters: List<dynamic>`.

### TemplateLocalization

`lib/src/models/template_localization.dart` — versione di un template
per una lingua specifica. Campi: `id`, `language` (required),
`status: SpokiTemplateStatus` (default `unknown`), `rejectionReason`,
`rejectionDetail`, `rejectionRecommendation`, `statusUpdatedAt`,
`header: TemplateComponent?`, `body: TemplateComponent` (required),
`footer: TemplateComponent?`, `buttons: List<TemplateButton>`,
`defaultHeaderMedia: TemplateMedia?`,
`exampleCustomFields: Map<String, String>`.

- `Map<String, dynamic> toCreatePayload()` — payload ridotto (senza
  `id`/`status`/metadati) usato da `TemplateRepository.create`/`update`.

### TemplateMedia

`lib/src/models/template_media.dart` — media di default nell'header di
un template. Campi: `id`, `title`, `mediaUrl`, `contentType`,
`formatType`, `externalUrl`, `externalId`, `isDeleted` (tutti nullable).

## Enum

### SpokiChannelType

`lib/src/enums/spoki_channel_type.dart` — `whatsapp`, `sms`, `voice`.
`sms`/`voice` esistono in previsione di un'estensione futura, ma
**non sono implementati** lato invio (`MessageRepository.send` lancia
`UnimplementedError` per questi due canali).

- `static SpokiChannelType fromString(String value)` — case-insensitive,
  default `whatsapp` se il valore non è riconosciuto.

### SpokiCustomFieldType

`lib/src/enums/spoki_custom_field_type.dart` — `text`, `date`, `datetime`.

- `int get apiValue` — `text → 1`, `date → 2`, `datetime → 3`.

### SpokiTemplateCategory

`lib/src/enums/spoki_template_category.dart` — `utility`, `marketing`,
`authentication`.

- `String get apiValue` — `'UTILITY'`, `'MARKETING'`, `'AUTHENTICATION'`.
- `static SpokiTemplateCategory fromString(String? value)` —
  case-insensitive, default `marketing`.

### SpokiTemplateStatus

`lib/src/enums/spoki_template_status.dart` — `approved`, `pending`,
`rejected`, `unknown`.

- `static SpokiTemplateStatus fromString(String? value)` —
  case-insensitive; `'REVIEW'` viene mappato a `pending`; default
  `unknown`.

## Helper

### AutomationStepBuilder

`lib/src/helpers/automation_step_builder.dart` — costruisce le mappe
`step` per `AutomationRepository.create`, coprendo i tipi più comuni
(lo schema completo ne supporta oltre 40; per gli altri tipi, costruisci
la mappa a mano con `step_type` + campi specifici).

| Metodo | Produce (`step_type`) |
|---|---|
| `templateMessage({required templateId, customFieldValues, position})` | `'TemplateMessage'` |
| `freeMessage({required text, position})` | `'FreeMessage'` |
| `delay({required delaySeconds, position})` | `'Delay'` |
| `addTag({required tags, position})` | `'AddTag'` |
| `webhookTrigger({required name})` | trigger webhook (`{'name': name, 'platform': 'api'}`) |

### TemplatePlaceholders

`lib/src/helpers/template_placeholders.dart` — utility per i
placeholder `%%CAMPO%%` nel testo dei template.

- `static List<String> extract(String text)` — estrae i nomi dei
  placeholder (senza `%%`), deduplicati, nell'ordine di comparsa.
- `static bool looksRiskyRatio(String bodyText)` — euristica per
  rilevare template con troppi placeholder rispetto al testo fisso
  (parole statiche < placeholder × 2); utile per anticipare l'errore
  Spoki `spoki::3014` (vedi [`SpokiException`](#gestione-errori--spokiexception))
  prima di sottomettere il template.

## Gestione errori — SpokiException

`lib/src/exceptions/spoki_exception.dart`

```dart
class SpokiException implements Exception {
  final String message;   // messaggio leggibile, tradotto in italiano quando possibile
  final int? httpStatus;
  final String? code;     // codice errore Spoki, es. "spoki::3014"
  final String? rawBody;  // corpo risposta originale, per debug
}
```

`SpokiException.fromResponse({required httpStatus, required body})` è
il costruttore usato internamente da `ApiService` (interceptor globale)
e dai metodi che istanziano un `Dio` proprio
(`MessageRepository`/`AuthRepository`). Logica di traduzione, in ordine
di priorità:

1. **Codici errore noti** — es. `spoki::3014` (troppe variabili
   `%%CAMPO%%` rispetto al testo fisso) viene tradotto in un messaggio
   italiano esplicativo.
2. **Errori di validazione per campo** — se il body è un oggetto senza
   `code`/`detail`/`title` ma con errori per campo (es. risposte DRF),
   vengono tradotti ricorsivamente (i messaggi `required` diventano
   "Campo obbligatorio mancante: ...").
3. **`detail`/`title` generico** — prefissato con `"Errore non tradotto: "`
   se non è stato possibile mapparlo a un messaggio conosciuto.
4. **Fallback per HTTP status** — `401`/`403` → messaggio su API Key,
   `404` → risorsa non trovata, `429` → troppe richieste, `≥500` →
   errore server Spoki.
5. **Fallback finale** — `"Errore sconosciuto ({status})."`.

Tutti i repository che gestiscono errori esplicitamente
(`MessageRepository`, `AuthRepository`) catturano `DioException` e
rilanciano `SpokiException`; gli altri repository si affidano
all'interceptor globale di `ApiService`, che fa lo stesso lavoro in
modo trasparente.

## Esempio end-to-end

```dart
import 'package:spoki_dart/core.dart';

Future<void> main() async {
  ApiService.getInstance().setApiKey('LA_TUA_API_KEY');

  // 1. Account primario e credito residuo
  final account = await AccountRepository.getPrimary();
  print('Credito: €${account.currentCreditEuros}');
  if (account.isLowCredit) {
    print('Attenzione: credito basso!');
  }

  // 2. Elenco template disponibili
  final templates = await TemplateRepository.list();
  final approved = templates.where((t) => t.isApproved).toList();

  // 3. Invio di un template per id — nessuna automazione da configurare
  try {
    final result = await MessageRepository.sendWhatsappTemplate(
      apiKey: 'LA_TUA_API_KEY',
      templateId: approved.first.id!,
      phone: '+393331234567',
      language: 'IT',
      customFields: {'FIRST_NAME': 'Mario'},
    );
    print('Accettato: ${result.accepted}');
  } on SpokiException catch (e) {
    print('Errore Spoki: ${e.message} (status ${e.httpStatus})');
  }
}
```

Vedi anche [example/lib/main.dart](example/lib/main.dart) per un esempio
completo con UI Flutter.
