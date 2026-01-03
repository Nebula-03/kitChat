import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController groupNameController = TextEditingController();
  bool loading = false;

  /// 🔹 Generate 6-digit invite code
  String generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> createGroup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || groupNameController.text.trim().isEmpty) return;

    setState(() => loading = true);

    try {
      await FirebaseFirestore.instance.collection('groups').add({
        'name': groupNameController.text.trim(),
        'admin': user.uid,
        'members': [user.uid],
        'inviteCode': generateInviteCode(), // ✅ IMPORTANT
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create group")),
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
          title: const Text("Create Group"),
          backgroundColor: Colors.blueGrey,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: groupNameController,
                decoration: const InputDecoration(
                  hintText: "Group name",
                ),
              ),
              const SizedBox(height: 20),
              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: createGroup,
                child: const Text("Create Group"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
