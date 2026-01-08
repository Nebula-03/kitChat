import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';
import 'group_card.dart';
import 'create_group_page.dart';
import 'join_group_page.dart';
import 'profile_page.dart';
import 'auth_gate.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // 🔹 APP BAR
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: const Text("Kitchat"),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      
        // 🔹 DRAWER
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blueGrey),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    user?.email ?? "User",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
      
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Profile"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
      
              const Spacer(),
      
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout"),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      
        // 🔹 GROUP LIST
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .where('members', arrayContains: user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
      
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No groups yet\nTap + to create one",
                  textAlign: TextAlign.center,
                ),
              );
            }
      
            final groups = snapshot.data!.docs;
      
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final data =
                groups[index].data() as Map<String, dynamic>;

                final typingUsers = data['typingUsers'] ?? {};

                return GroupCard(
                  groupId: groups[index].id,
                  groupName: data['name'],
                  members: (data['members'] as List).length,
                  isTyping: typingUsers.isNotEmpty,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          groupId: groups[index].id,
                          groupName: data['name'],
                        ),
                      ),
                    );
                  },
                );


              },
            );
          },
        ),
      
        // 🔹 FLOATING ACTION BUTTON (BOTTOM SHEET)
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueGrey,
          child: const Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              builder: (_) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.group_add),
                    title: const Text("Create Group"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateGroupPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.vpn_key),
                    title: const Text("Join via Invite Code"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JoinGroupPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
