class SpokiException implements Exception {
  final String message;
  final int? httpStatus;
  final String? code;
  final String? rawBody;

  SpokiException(this.message, {this.httpStatus, this.code, this.rawBody});

  static const Map<String, String> _knownErrorCodes = {
    'spoki::3014':
        'Il template ha troppe variabili (%%CAMPO%%) rispetto alla quantità '
            'di testo fisso attorno a esse. Aggiungi più testo descrittivo '
            'tra un campo e l\'altro, oppure riduci il numero di variabili.',
  };

  factory SpokiException.fromResponse({
    required int? httpStatus,
    required dynamic body,
  }) {
    String? code;
    String? detail;
    Map<String, dynamic>? bodyMap;

    if (body is Map<String, dynamic>) {
      bodyMap = body;
      code = body['code'] as String?;
      detail = (body['detail'] ?? body['title'])?.toString();
    } else if (body is String && body.isNotEmpty) {
      detail = body;
    }

    if (code != null && _knownErrorCodes.containsKey(code)) {
      return SpokiException(
        _knownErrorCodes[code]!,
        httpStatus: httpStatus,
        code: code,
        rawBody: body?.toString(),
      );
    }

    if (bodyMap != null && code == null && detail == null) {
      final fieldErrors = _translateFieldErrors(bodyMap);
      if (fieldErrors.isNotEmpty) {
        return SpokiException(
          fieldErrors.join(' — '),
          httpStatus: httpStatus,
          rawBody: body?.toString(),
        );
      }
    }

    if (detail != null) {
      return SpokiException(
        'Errore non tradotto: $detail',
        httpStatus: httpStatus,
        code: code,
        rawBody: body?.toString(),
      );
    }

    switch (httpStatus) {
      case 401:
      case 403:
        return SpokiException(
          'Accesso non autorizzato: controlla che l\'API Key sia corretta e approvata.',
          httpStatus: httpStatus,
        );
      case 404:
        return SpokiException('Risorsa non trovata.', httpStatus: httpStatus);
      case 429:
        return SpokiException(
          'Troppe richieste in poco tempo: riprova tra qualche istante.',
          httpStatus: httpStatus,
        );
    }

    if (httpStatus != null && httpStatus >= 500) {
      return SpokiException(
        'Errore del server Spoki: riprova più tardi o contatta il supporto.',
        httpStatus: httpStatus,
      );
    }

    return SpokiException(
      'Errore sconosciuto${httpStatus != null ? " ($httpStatus)" : ""}.',
      httpStatus: httpStatus,
      rawBody: body?.toString(),
    );
  }

  static List<String> _translateFieldErrors(
    Map<String, dynamic> obj, {
    String path = '',
  }) {
    final parts = <String>[];
    obj.forEach((key, value) {
      final label = path.isEmpty ? key : '$path > $key';
      if (value is List) {
        for (final msg in value) {
          final msgStr = msg.toString();
          if (RegExp('required', caseSensitive: false).hasMatch(msgStr)) {
            parts.add('Campo obbligatorio mancante: $label');
          } else {
            parts.add('$label: $msgStr');
          }
        }
      } else if (value is Map<String, dynamic>) {
        parts.addAll(_translateFieldErrors(value, path: label));
      }
    });
    return parts;
  }

  @override
  String toString() => message;
}
