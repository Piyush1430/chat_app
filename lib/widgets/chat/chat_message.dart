import "package:chat_app/widgets/chat/message_bubble.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});
  @override
  Widget build(BuildContext context) {
    final authenticatedUserId = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chat")
          .orderBy("create-at", descending: true)
          .snapshots(),
      builder: (context, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Message found.."),
          );
        }
        if (chatSnapshots.hasError) {
          return const Center(
            child: Text("Someting went wrong.."),
          );
        }
        final loadedMessage = chatSnapshots.data!.docs;
        return ListView.builder(
            padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
            reverse: true,
            itemCount: loadedMessage.length,
            itemBuilder: (context, index) {
              final chatMessages = loadedMessage[index].data();
              final nextChatMessages = index + 1 < loadedMessage.length
                  ? loadedMessage[index + 1].data()
                  : null;
              final currentMessageUserId = chatMessages["userId"];
              final nextMessageUserId =
                  nextChatMessages != null ? nextChatMessages["userId"] : null;
              final nextUserIsSame = nextMessageUserId == currentMessageUserId;
              if (nextUserIsSame) {
                return MessageBubble.next(
                  message: chatMessages["text"],
                  isMe: authenticatedUserId.uid == currentMessageUserId,
                );
              } else {
                return MessageBubble.first(
                    userImage: chatMessages["userImage"],
                    username: chatMessages["username"],
                    message: chatMessages["text"],
                    isMe: authenticatedUserId.uid == currentMessageUserId);
              }
            });
      },
    );
  }
}
