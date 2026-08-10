import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onam/widgets/custom_text_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phone Number Validation & Input Field Unit Tests', () {
    testWidgets('CustomTextField phone field enforces numeric keyboard, digitsOnly, maxLength: 10 and exact 10-digit validation', (WidgetTester tester) async {
      final controller = TextEditingController();

      String? phoneValidator(String? val) {
        if (val != null && val.trim().isNotEmpty) {
          if (val.trim().length != 10) {
            return 'Enter a valid 10-digit phone number';
          }
        }
        return null;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Phone Number (Recommended)',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              maxLength: 10,
              validator: phoneValidator,
            ),
          ),
        ),
      );

      // Verify underlying TextField widget properties
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, equals(TextInputType.number));
      expect(textField.maxLength, equals(10));
      expect(textField.inputFormatters, contains(FilteringTextInputFormatter.digitsOnly));

      // Test Valid: 10 digits
      expect(phoneValidator('9876543210'), isNull);

      // Test Valid: Empty string (optional)
      expect(phoneValidator(''), isNull);
      expect(phoneValidator(null), isNull);

      // Test Invalid: Less than 10 digits
      expect(phoneValidator('98765'), equals('Enter a valid 10-digit phone number'));
      expect(phoneValidator('987654321'), equals('Enter a valid 10-digit phone number'));

      // Test Input Formatter behavior with non-digit inputs
      final formatter = FilteringTextInputFormatter.digitsOnly;

      // Input with alphabets: 98765abc10 -> 9876510
      const inputAlphabets = TextEditingValue(text: '98765abc10');
      final outputAlphabets = formatter.formatEditUpdate(TextEditingValue.empty, inputAlphabets);
      expect(outputAlphabets.text, equals('9876510'));

      // Input with special chars/dashes: 98765-43210 -> 9876543210
      const inputDashes = TextEditingValue(text: '98765-43210');
      final outputDashes = formatter.formatEditUpdate(TextEditingValue.empty, inputDashes);
      expect(outputDashes.text, equals('9876543210'));

      // Input with spaces: 98765 43210 -> 9876543210
      const inputSpaces = TextEditingValue(text: '98765 43210');
      final outputSpaces = formatter.formatEditUpdate(TextEditingValue.empty, inputSpaces);
      expect(outputSpaces.text, equals('9876543210'));

      // Input with plus sign: +919876543210 -> 919876543210
      const inputPlus = TextEditingValue(text: '+919876543210');
      final outputPlus = formatter.formatEditUpdate(TextEditingValue.empty, inputPlus);
      expect(outputPlus.text, equals('919876543210'));
    });
  });
}
