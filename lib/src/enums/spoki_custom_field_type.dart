enum SpokiCustomFieldType {
  text,
  date,
  datetime;

  int get apiValue {
    switch (this) {
      case SpokiCustomFieldType.text:
        return 1;
      case SpokiCustomFieldType.date:
        return 2;
      case SpokiCustomFieldType.datetime:
        return 3;
    }
  }
}
