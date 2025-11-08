import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutterappmedigo/approvependdetails.dart';
import 'translation_provider.dart';

class PendingApprovalsScreen extends StatefulWidget {
  final String reviewerId;
  final String reviewerName;

  const PendingApprovalsScreen({
    Key? key,
    required this.reviewerId,
    required this.reviewerName,
  }) : super(key: key);

  @override
  _PendingApprovalsScreenState createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends State<PendingApprovalsScreen> {
  final String baseUrl = "http://10.0.2.2:8000";
  List<dynamic> pendingItems = [];
  bool isLoading = true;
  String errorMessage = "";
  final allowedCollections = ['bloodbiomarkers', 'radiology'];

  @override
  void initState() {
    super.initState();
    fetchPendingItems();
  }

  Future<void> fetchPendingItems() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pending/reviewer/${widget.reviewerName}'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final filtered = data.where((item) {
          final collection = item['collection'] ?? '';
          return allowedCollections.contains(collection);
        }).toList();

        setState(() {
          pendingItems = filtered;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load pending items.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error: $e";
        isLoading = false;
      });
    }
  }

  Future<void> handleApproval(String docId, bool isApproval, String collection) async {
    final t = Provider.of<TranslationProvider>(context, listen: false).t;
    final action = isApproval ? "approve" : "reject";
    final url = Uri.parse(
      '$baseUrl/pending/$action/${widget.reviewerName}/$docId'
          '?reviewer_name=${Uri.encodeComponent(widget.reviewerName)}',
    );

    try {
      final response = isApproval ? await http.post(url) : await http.delete(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          pendingItems.removeWhere((item) => item['id'] == docId && item['collection'] == collection);
        });

        final msg = data['message'] ?? (isApproval ? t("approve") : t("reject"));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$msg ${t("successfully")}.")),
        );
      } else {
        throw Exception(data['detail'] ?? 'Unknown error');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void confirmAction(bool isApproval, String docId, String dataType) {
    final t = Provider.of<TranslationProvider>(context, listen: false).t;
    final action = isApproval ? t("approve") : t("reject");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("${t("confirm")} $action"),
        content: Text("${t("areYouSure")} $action this $dataType record?"),
        actions: [
          TextButton(
            child: Text(t("cancel")),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isApproval ? Colors.green : Colors.red),
            child: Text(action.toUpperCase()),
            onPressed: () {
              Navigator.of(ctx).pop();
              handleApproval(docId, isApproval, dataType);
            },
          ),
        ],
      ),
    );
  }

  Widget buildItemCard(dynamic item) {
    final t = Provider.of<TranslationProvider>(context).t;
    final docId = item['id'] ?? '';
    final nationalId = item['national_id'] ?? '';
    final dataType = item['collection'] ?? '';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: ListTile(
        tileColor: Colors.blue[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          "${t("type")}: $dataType",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        subtitle: Text("${t("id")}: $nationalId", style: const TextStyle(fontSize: 13)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              tooltip: t("approve"),
              onPressed: () => confirmAction(true, docId, dataType),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              tooltip: t("reject"),
              onPressed: () => confirmAction(false, docId, dataType),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PendingApprovalDetailsScreen(item: item),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<TranslationProvider>(context).t;
    final provider = Provider.of<TranslationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        title: Text("${t("pendingApprovals")} - ${widget.reviewerName}"),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchPendingItems,
          ),
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Switch Language',
            onPressed: () => provider.toggleLanguage(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)))
          : RefreshIndicator(
        color: Colors.blueAccent,
        onRefresh: fetchPendingItems,
        child: pendingItems.isEmpty
            ? Center(child: Text(t("noPendingRecords"), style: const TextStyle(fontSize: 16)))
            : ListView.separated(
          padding: const EdgeInsets.only(top: 10),
          itemCount: pendingItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, index) => buildItemCard(pendingItems[index]),
        ),
      ),
    );
  }
}
