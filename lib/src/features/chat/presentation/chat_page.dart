import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../core/services/api_service.dart';
import '../../../core/utils/nepal_timezone.dart';
import '../../auth/auth_service.dart';

class ChatPage extends StatefulWidget {
  final String chatUrl;
  final String courseName;
  final String batchName;
  final int batchId;

  const ChatPage({
    super.key,
    required this.chatUrl,
    required this.courseName,
    required this.batchName,
    required this.batchId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreMessages = true;
  Timer? _refreshTimer;
  String? _currentUserId;



  @override
  void initState() {
    super.initState();
    _currentUserId = AuthService.currentUser?['id']?.toString();
    
    _initializeUserData().then((_) {
      // Reload messages after user data is properly initialized
      _loadMessages();
    });
    _scrollController.addListener(_onScroll);
    _startRealTimeUpdates();
  }

  Future<void> _initializeUserData() async {
    try {
      // Always fetch profile to ensure we have the latest user data including ID
      await AuthService.getProfile();
      _currentUserId = AuthService.currentUser?['id']?.toString();
      
      // If we still don't have a user ID, check for alternative fields
      if (_currentUserId == null) {
        // Try alternative user ID fields that might be used
        _currentUserId = AuthService.currentUser?['user_id']?.toString() ??
                       AuthService.currentUser?['student_id']?.toString() ??
                       AuthService.currentUser?['userId']?.toString();
      }
    } catch (e) {
      // Silently handle profile fetch errors
    }
  }

  void _startRealTimeUpdates() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkForNewMessages();
    });
  }

  Future<void> _checkForNewMessages() async {
    if (_isLoading || _isSending) return;
    
    try {
      // Get the latest message timestamp to check for newer messages
      DateTime? lastMessageTime;
      if (_messages.isNotEmpty) {
        lastMessageTime = _messages.last.timestamp;
      }
      
      final response = await ApiService.getChatMessages(widget.batchId, page: 1);
      
      if (response['success'] == true) {
        final chatMessages = response['data']['chat_messages'];
        final messagesData = chatMessages['data'] as List? ?? [];
        
        final latestMessages = messagesData.map((messageData) {
          final senderId = messageData['sender_id'].toString();
          
          // More robust user comparison
          final isCurrentUser = senderId == _currentUserId || 
                                senderId == _currentUserId?.toString() ||
                                messageData['sender_id'].toString() == _currentUserId;
          
          return ChatMessage(
            id: messageData['id'].toString(),
            userId: senderId,
            userName: messageData['from'] ?? 'Unknown User',
            message: messageData['message'] ?? '',
            timestamp: DateTime.tryParse(messageData['created_at'] ?? '') ?? DateTime.now(),
            isCurrentUser: isCurrentUser,
            userAvatar: null,
          );
        }).toList();
        
        // Sort by timestamp
        latestMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        // Filter for truly new messages (newer than our latest message)
        final newMessages = latestMessages.where((message) {
          // Check if message doesn't exist in current messages
          final existingIds = _messages.map((m) => m.id).toSet();
          final isNewMessage = !existingIds.contains(message.id);
          
          // Also check if it's newer than our latest message
          final isNewerThanLatest = lastMessageTime == null || 
              message.timestamp.isAfter(lastMessageTime);
          
          return isNewMessage && isNewerThanLatest;
        }).toList();
        
        if (newMessages.isNotEmpty) {
          setState(() {
            _messages.addAll(newMessages);
            // Keep messages sorted by timestamp
            _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          });
          
          // Only scroll to bottom if user is near the bottom
          if (_scrollController.hasClients) {
            final maxScroll = _scrollController.position.maxScrollExtent;
            final currentScroll = _scrollController.position.pixels;
            final isNearBottom = (maxScroll - currentScroll) < 100;
            
            if (isNearBottom) {
              _scrollToBottom();
            }
          }
        }
      }
    } catch (e) {
      // Silently fail for background updates
      print('Background update failed: $e');
    }
  }

  void _onScroll() {
    // Check if scrolled to top
    if (_scrollController.position.pixels <= 100 && _hasMoreMessages && !_isLoadingMore) {
      print('Scroll detected at top, loading older messages...');
      _loadOlderMessages();
    }
  }

  Future<void> _loadOlderMessages() async {
    if (_isLoadingMore || !_hasMoreMessages) return;
    
    print('Loading older messages - Current page: $_currentPage, Has more: $_hasMoreMessages');
    
    try {
      setState(() {
        _isLoadingMore = true;
      });
      
      final nextPage = _currentPage + 1;
      final response = await ApiService.getChatMessages(widget.batchId, page: nextPage);
      
      if (response['success'] == true) {
        final chatMessages = response['data']['chat_messages'];
        final messagesData = chatMessages['data'] as List? ?? [];
        
        final newMessages = messagesData.map((messageData) {
          final senderId = messageData['sender_id'].toString();
          
          // More robust user comparison
          final isCurrentUser = senderId == _currentUserId || 
                                senderId == _currentUserId?.toString() ||
                                messageData['sender_id'].toString() == _currentUserId;
          
          return ChatMessage(
            id: messageData['id'].toString(),
            userId: senderId,
            userName: messageData['from'] ?? 'Unknown User',
            message: messageData['message'] ?? '',
            timestamp: DateTime.tryParse(messageData['created_at'] ?? '') ?? DateTime.now(),
            isCurrentUser: isCurrentUser,
            userAvatar: null,
          );
        }).toList();
        
        // Filter out any duplicate messages before inserting
        final existingIds = _messages.map((m) => m.id).toSet();
        final uniqueNewMessages = newMessages.where((m) => !existingIds.contains(m.id)).toList();
        
        print('Loaded ${uniqueNewMessages.length} new messages from page $nextPage');
        
        if (uniqueNewMessages.isNotEmpty) {
          setState(() {
            // Insert older messages at the beginning
            _messages.insertAll(0, uniqueNewMessages);
            // Re-sort all messages to ensure proper order
            _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            _currentPage = nextPage;
            _hasMoreMessages = chatMessages['current_page'] < chatMessages['last_page'];
            _isLoadingMore = false;
          });
        } else {
          setState(() {
            _currentPage = nextPage;
            _hasMoreMessages = chatMessages['current_page'] < chatMessages['last_page'];
            _isLoadingMore = false;
          });
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to load older messages');
      }
    } catch (e) {
      print('Error loading older messages: $e');
      setState(() {
        _isLoadingMore = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load older messages: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
        _hasMoreMessages = true;
      });

      // Try to fetch messages from API
      try {
        final response = await ApiService.getChatMessages(widget.batchId, page: 1);
        
        if (response['success'] == true) {
          final chatMessages = response['data']['chat_messages'];
          final messagesData = chatMessages['data'] as List? ?? [];
          
          final newMessages = messagesData.map((messageData) {
            final senderId = messageData['sender_id'].toString();
            
            // More robust user comparison - handle both string and int comparisons
            final isCurrentUser = senderId == _currentUserId || 
                                  senderId == _currentUserId?.toString() ||
                                  messageData['sender_id'].toString() == _currentUserId;
            
            return ChatMessage(
              id: messageData['id'].toString(),
              userId: senderId,
              userName: messageData['from'] ?? 'Unknown User',
              message: messageData['message'] ?? '',
              timestamp: DateTime.tryParse(messageData['created_at'] ?? '') ?? DateTime.now(),
              isCurrentUser: isCurrentUser,
              userAvatar: null, // Will be generated using first letter
            );
          }).toList();
          
          // Sort new messages by timestamp (oldest first)
          newMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          setState(() {
            _messages = newMessages;
            _currentPage = 1;
            _isLoading = false;
            _hasMoreMessages = chatMessages['current_page'] < chatMessages['last_page'];
          });
          // Scroll to bottom after initial load with a more reliable approach
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Future.delayed(const Duration(milliseconds: 300));
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
        } else {
          throw Exception(response['message'] ?? 'Failed to load messages');
        }
      } catch (apiError) {
        // Fall back to demo data if API fails
        print('API Error: $apiError');
        final currentUser = AuthService.currentUser;
        final userName = currentUser?['name'] ?? currentUser?['username'] ?? 'You';
        
        setState(() {
          _messages = [
            ChatMessage(
              id: '1',
              userId: '1',
              userName: 'Admin',
              message: 'Welcome to the ${widget.courseName} batch chat! Feel free to ask any questions.',
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              isCurrentUser: false,
              userAvatar: null,
            ),
            ChatMessage(
              id: '2',
              userId: '2',
              userName: 'Dinesh Pokharel',
              message: 'Thank you! When is our next class?',
              timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
              isCurrentUser: false,
              userAvatar: null,
            ),
            ChatMessage(
              id: '3',
              userId: currentUser?['id']?.toString() ?? '3',
              userName: userName,
              message: 'I have the same question. Looking forward to the next session.',
              timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
              isCurrentUser: true,
              userAvatar: null,
            ),
          ];
          _isLoading = false;
          _hasMoreMessages = false;
        });
        // Also scroll to bottom for demo data
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(const Duration(milliseconds: 300));
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }

    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final currentUser = AuthService.currentUser;
      final userName = currentUser?['name'] ?? currentUser?['username'] ?? 'You';
      final userId = _currentUserId ?? 'current_user';
      
      // Create temporary message with current time (will be updated with server time)
      final newMessage = ChatMessage(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        userName: userName,
        message: messageText,
        timestamp: DateTime.now(),
        isCurrentUser: true,
        userAvatar: null,
      );

      // Add message to list immediately for better UX
      setState(() {
        _messages.add(newMessage);
        _messageController.clear();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Send message to API
      try {
        final response = await ApiService.sendChatMessage(widget.batchId, messageText);
        
        if (response['success'] == true) {
          // Update the local message with server response data including correct timestamp
          final serverMessage = response['data'];
          final messageIndex = _messages.length - 1;
          
          if (messageIndex >= 0) {
            setState(() {
              _messages[messageIndex] = ChatMessage(
                id: serverMessage['id'].toString(),
                userId: serverMessage['sender_id'].toString(),
                userName: serverMessage['from'] ?? 'You',
                message: serverMessage['message'],
                timestamp: DateTime.tryParse(serverMessage['created_at']) ?? DateTime.now(),
                isCurrentUser: true,
                userAvatar: null,
              );
            });
          }
        } else {
          // If server response is not successful, remove the message
          setState(() {
            _messages.removeLast();
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Failed to send message'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      } catch (apiError) {
        print('API Error sending message: $apiError');
        // Remove the message from list if API call failed
        setState(() {
          _messages.removeLast();
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send message: ${apiError.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return; // Exit early if API call failed
      }

    } catch (e) {
      // Remove message from list if sending failed
      setState(() {
        _messages.removeLast();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _loadAllOlderMessages(int lastPage) async {
    // Load all remaining pages during initial load
    for (int page = 2; page <= lastPage; page++) {
      try {
        final response = await ApiService.getChatMessages(widget.batchId, page: page);
        
        if (response['success'] == true) {
          final chatMessages = response['data']['chat_messages'];
          final messagesData = chatMessages['data'] as List? ?? [];
          
          final pageMessages = messagesData.map((messageData) {
            return ChatMessage(
              id: messageData['id'].toString(),
              userId: messageData['sender_id'].toString(),
              userName: messageData['from'] ?? 'Unknown User',
              message: messageData['message'] ?? '',
              timestamp: DateTime.tryParse(messageData['created_at'] ?? '') ?? DateTime.now(),
              isCurrentUser: messageData['sender_id'].toString() == _currentUserId,
              userAvatar: null,
            );
          }).toList();
          
          // Filter out duplicates
          final existingIds = _messages.map((m) => m.id).toSet();
          final uniqueMessages = pageMessages.where((m) => !existingIds.contains(m.id)).toList();
          
          if (uniqueMessages.isNotEmpty) {
            setState(() {
              _messages.addAll(uniqueMessages);
              // Keep messages sorted by timestamp
              _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
              _currentPage = page;
            });
          }
        }
      } catch (e) {
        print('Error loading page $page: $e');
        break; // Stop loading if there's an error
      }
    }
    
    // Update pagination state
    setState(() {
      _hasMoreMessages = false; // All messages loaded
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.courseName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.batchName,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Failed to load messages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMessages,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 400,
          child: Center(
            child: Text(
              'No messages yet.\nStart the conversation!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the top when loading more
        if (_isLoadingMore && index == 0) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final messageIndex = _isLoadingMore ? index - 1 : index;
        final message = _messages[messageIndex];
        final showDateHeader = _shouldShowDateHeader(messageIndex);
        
        return Column(
          children: [
            if (showDateHeader) _buildDateHeader(message.timestamp),
            _buildMessageBubble(message),
          ],
        );
      },
    );
  }

  bool _shouldShowDateHeader(int index) {
    if (index == 0) return true;
    
    final currentMessage = _messages[index];
    final previousMessage = _messages[index - 1];
    
    return !_isSameDay(currentMessage.timestamp, previousMessage.timestamp);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return NepalTimezone.isSameDay(date1, date2);
  }

  Widget _buildDateHeader(DateTime date) {
    String dateText = NepalTimezone.formatChatDate(date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateText,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isCurrentUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isCurrentUser) ...[
            _buildUserAvatar(message),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isCurrentUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                if (!message.isCurrentUser)
                  Text(
                    message.userName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isCurrentUser 
                        ? Colors.red[300] 
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomRight: message.isCurrentUser 
                          ? const Radius.circular(4) 
                          : const Radius.circular(18),
                      bottomLeft: message.isCurrentUser 
                          ? const Radius.circular(18) 
                          : const Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      color: message.isCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMessageTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (message.isCurrentUser) ...[
            const SizedBox(width: 8),
            _buildUserAvatar(message),
          ],
        ],
      ),
    );
  }

  Widget _buildUserAvatar(ChatMessage message) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: message.isCurrentUser ? Colors.red[100] : Colors.grey[300],
      child: message.userAvatar != null
          ? ClipOval(child: Image.network(message.userAvatar!))
          : Text(
              message.userName.isNotEmpty ? message.userName[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: message.isCurrentUser ? Colors.red[700] : Colors.grey[700],
              ),
            ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    return NepalTimezone.formatChatTime(timestamp);
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _isSending ? Colors.grey : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}

class ChatMessage {
  final String id;
  final String userId;
  final String userName;
  final String message;
  final DateTime timestamp;
  final bool isCurrentUser;
  final String? userAvatar;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
    required this.isCurrentUser,
    this.userAvatar,
  });
} 