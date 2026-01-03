import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinGroupPage extends StatefulWidget {
  const JoinGroupPage({super.key});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  final TextEditingController codeController = TextEditingController();
  bool loading = false;

  Future<void> joinGroup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || codeController.text.isEmpty) return;

    setState(() => loading = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection('groups')
          .where('inviteCode', isEqualTo: codeController.text.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid invite code")),
        );
        return;
      }

      final groupDoc = query.docs.first;

      await groupDoc.reference.update({
        'members': FieldValue.arrayUnion([user.uid])
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to join group")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Join Group"),
          backgroundColor: Colors.blueGrey,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  hintText: "Enter invite code",
                ),
              ),
              const SizedBox(height: 20),
              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: joinGroup,
                child: const Text("Join"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
