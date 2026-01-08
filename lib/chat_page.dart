import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'group_info_page.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const ChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  Future<void> setTyping(bool isTyping) async {
    if (user == null) return;

    final ref =
    FirebaseFirestore.instance.collection('groups').doc(widget.groupId);

    if (isTyping) {
      await ref.update({
        'typingUsers.${user!.uid}': user!.email,
      });
    } else {
      await ref.update({
        'typingUsers.${user!.uid}': FieldValue.delete(),
      });
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty || user == null) return;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .add({
      'text': messageController.text.trim(),
      'senderId': user!.uid,
      'senderEmail': user!.email,
      'timestamp': FieldValue.serverTimestamp(),
    });

    messageController.clear();
    await setTyping(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupInfoPage(
                  groupId: widget.groupId,
                  groupName: widget.groupName,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.groupName),
              const Text("Tap for group info", style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data =
                    messages[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == user!.uid;

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                          isMe ? Colors.blueGrey : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .doc(widget.groupId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final typingUsers = Map<String, dynamic>.from(
                  data['typingUsers'] ?? {});

              typingUsers.remove(user!.uid);

              if (typingUsers.isEmpty) return const SizedBox();

              return Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${typingUsers.values.join(', ')} typing...",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.indigo,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setTyping(true);
                      } else {
                        setTyping(false);
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueGrey),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
