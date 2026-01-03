import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class GroupInfoPage extends StatelessWidget {
  final String groupId;
  final String groupName;

  const GroupInfoPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Info"),
        backgroundColor: Colors.blueGrey,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final inviteCode = data['inviteCode'] ?? 'N/A';
          final members = List<String>.from(data['members'] ?? []);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text("Members (${members.length})"),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text("Invite people"),
                  onPressed: () {
                    Share.share(
                      "Join my KitChat group!\nInvite code: $inviteCode",
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
