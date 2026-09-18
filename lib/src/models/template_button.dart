class TemplateButton {
  final String? componentType;
  final int? order;
  final String? buttonType;
  final String? text;
  final String? phoneNumber;
  final String? url;
  final String? formId;
  final bool? sendAsShortlink;
  final String? shortlinkCode;

  TemplateButton({
    this.componentType,
    this.order,
    this.buttonType,
    this.text,
    this.phoneNumber,
    this.url,
    this.formId,
    this.sendAsShortlink,
    this.shortlinkCode,
  });

  factory TemplateButton.fromJson(Map<String, dynamic> json) =>
      TemplateButton(
        componentType: json['component_type'] as String?,
        order: json['order'] as int?,
        buttonType: json['button_type'] as String?,
        text: json['text'] as String?,
        phoneNumber: json['phone_number'] as String?,
        url: json['url'] as String?,
        formId: json['form_id'] as String?,
        sendAsShortlink: json['send_as_shortlink'] as bool?,
        shortlinkCode: json['shortlink_code'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'component_type': componentType,
        'order': order,
        'button_type': buttonType,
        'text': text,
        'phone_number': phoneNumber,
        'url': url,
        'form_id': formId,
        'send_as_shortlink': sendAsShortlink,
        'shortlink_code': shortlinkCode,
      };

  @override
  String toString() => toJson().toString();
}
