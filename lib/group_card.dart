import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  final String groupId;
  final String groupName;
  final int members;
  final bool isTyping;
  final VoidCallback onTap;

  const GroupCard({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.members,
    required this.isTyping,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.group, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTyping ? "typing..." : "$members member",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontStyle:
                        isTyping ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
