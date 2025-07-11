import 'dart:async'; // ✅ для unawaited
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final messages = await _apiService.getMessages();
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final username = _usernameController.text.trim();
    final content = _messageController.text.trim();

    final request = CreateMessageRequest(username: username, content: content);
    final validationError = request.validate();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    try {
      final newMessage = await _apiService.createMessage(request);
      setState(() {
        _messages.add(newMessage);
        _messageController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _editMessage(Message message) async {
    final controller = TextEditingController(text: message.content);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      final request = UpdateMessageRequest(content: result);
      final validationError = request.validate();
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validationError)));
        return;
      }

      try {
        final updatedMessage = await _apiService.updateMessage(message.id, request);
        setState(() {
          final index = _messages.indexWhere((m) => m.id == updatedMessage.id);
          if (index != -1) _messages[index] = updatedMessage;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message updated')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteMessage(message.id);
        setState(() {
          _messages.removeWhere((m) => m.id == message.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message deleted')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _showHTTPStatus(int code) async {
  try {
    final status = await _apiService.getHTTPStatus(code);
    await showDialog( // ✅ именно await
      context: context,
      builder: (_) => AlertDialog(
        title: Text('HTTP Status: ${status.statusCode}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status.description),
            const SizedBox(height: 10),
            Image.network(
              status.imageUrl,
              height: 150,
              errorBuilder: (_, __, ___) => const Text('Failed to load image'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}


  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(child: Text(message.username[0].toUpperCase())),
      title: Text('${message.username} • ${message.timestamp.toLocal()}'),
      subtitle: Text(message.content),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'Edit') _editMessage(message);
          if (value == 'Delete') _deleteMessage(message);
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'Edit', child: Text('Edit')),
          PopupMenuItem(value: 'Delete', child: Text('Delete')),
        ],
      ),
      onTap: () {
        final codes = [200, 404, 500];
        final random = Random();
        _showHTTPStatus(codes[random.nextInt(codes.length)]);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Enter your username'),
          ),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(labelText: 'Enter your message'),
          ),
          Row(
            children: [
              ElevatedButton(onPressed: _sendMessage, child: const Text('Send')),
              const SizedBox(width: 12),
              TextButton(onPressed: () => _showHTTPStatus(200), child: const Text('200 OK')),
              TextButton(onPressed: () => _showHTTPStatus(404), child: const Text('404 Not Found')),
              TextButton(onPressed: () => _showHTTPStatus(500), child: const Text('500 Error')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error', style: const TextStyle(color: Colors.red)),
          ElevatedButton(onPressed: _loadMessages, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMessages),
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _error != null
              ? _buildErrorWidget()
              : _messages.isEmpty
                  ? const Center(
                      child: SingleChildScrollView( // ✅ для теста пустого состояния
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('No messages yet'),
                            Text('Send your first message to get started!'),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (_, index) => _buildMessageTile(_messages[index]),
                    ),
      bottomSheet: _buildMessageInput(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMessages,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
