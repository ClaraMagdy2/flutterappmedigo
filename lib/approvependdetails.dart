import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class PendingApprovalDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const PendingApprovalDetailsScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final t = provider.t;
    final isArabic = provider.currentLanguage == 'ar';

    final record = item['record'] ?? {};
    final results = List<Map<String, dynamic>>.from(record['results'] ?? []);
    final imageUrl = record['image_url'];

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
          title: Text(t("record_details")),
          actions: [
            Row(
              children: [
                const Text('EN', style: TextStyle(color: Colors.white)),
                Switch(
                  value: isArabic,
                  onChanged: (value) async {
                    await provider.load(value ? 'ar' : 'en');
                  },
                  activeColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey,
                ),
                const Text('عربي', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text("${t("data_type")}: ${item['collection']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("${t("national_id")}: ${item['national_id']}"),
              Text("${t("extracted_date")}: ${record['extracted_date'] ?? 'N/A'}"),
              const SizedBox(height: 16),

              if (imageUrl != null)
                GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      child: InteractiveViewer(
                        child: Image.network(imageUrl),
                      ),
                    ),
                  ),
                  child: Hero(
                    tag: 'image_preview',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
              Text(t("results"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              ...results.map((r) {
                final isFlagged = r['flag'] == true;
                return Card(
                  color: isFlagged ? Colors.red.shade50 : Colors.green.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    title: Text(
                      "${r['item']} = ${r['value']} ${r['unit'] ?? ''}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text("${t("reference_range")}: ${r['reference_range'] ?? '--'}"),
                    trailing: Icon(
                      isFlagged ? Icons.warning_amber_rounded : Icons.check_circle,
                      color: isFlagged ? Colors.red : Colors.green,
                    ),
                  ),
                );
              }).toList()
            ],
          ),
        ),
      ),
    );
  }
}
