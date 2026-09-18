enum SpokiTemplateStatus {
  approved,
  pending,
  rejected,
  unknown;

  static SpokiTemplateStatus fromString(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'APPROVED':
        return SpokiTemplateStatus.approved;
      case 'PENDING':
      case 'REVIEW':
        return SpokiTemplateStatus.pending;
      case 'REJECTED':
        return SpokiTemplateStatus.rejected;
      default:
        return SpokiTemplateStatus.unknown;
    }
  }
}
