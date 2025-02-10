import 'package:test/test.dart';
import 'package:illuminate_mail/mail.dart';

void main() {
  group('Mail Package', () {
    test('exports all required components', () {
      // Verify all essential classes are exported
      expect(MailManager, isNotNull);
      expect(Mailable, isNotNull);
      expect(MailDriver, isNotNull);
      expect(SmtpDriver, isNotNull);
      expect(MailgunDriver, isNotNull);
      expect(LogDriver, isNotNull);
      expect(Address, isNotNull);
      expect(Attachment, isNotNull);
      expect(MailException, isNotNull);
    });
  });
}
