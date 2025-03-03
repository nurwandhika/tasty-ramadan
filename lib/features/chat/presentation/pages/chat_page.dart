import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import 'favorites_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isDialogShowing = false;

  List<TextSpan> _parseText(String text) {
    final List<TextSpan> spans = [];
    final lines = text.split('\n');

    for (var line in lines) {
      // Handle titles (##)
      if (line.startsWith('## ')) {
        spans.add(
          TextSpan(
            text: '${line.substring(3)}\n',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 2,
            ),
          ),
        );
        continue;
      }

      // Handle bold text (*)
      final boldParts = line.split('*');
      if (boldParts.length > 1) {
        for (var i = 0; i < boldParts.length; i++) {
          if (boldParts[i].isEmpty) continue;
          spans.add(
            TextSpan(
              text: '${boldParts[i]}${i == boldParts.length - 1 ? '\n' : ''}',
              style: TextStyle(
                fontWeight: i % 2 == 1 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }
      } else {
        spans.add(TextSpan(text: '$line\n'));
      }
    }

    return spans;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().startConversation();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<ChatProvider>().addListener(_scrollToBottom);
  }

  @override
  void dispose() {
    context.read<ChatProvider>().removeListener(_scrollToBottom);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showFavoriteDialog(BuildContext context, bool isFavorite) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isFavorite ? 'Favorit Ditambahkan' : 'Favorit Dihapus'),
          content: Text(
            isFavorite
                ? 'Resep ini telah ditambahkan ke favorit Anda.'
                : 'Resep ini telah dihapus dari favorit Anda.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleLoadingState(BuildContext context, bool isLoading) {
    if (isLoading && !_isDialogShowing) {
      _isDialogShowing = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              backgroundColor: Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/animations/loading2.json',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tunggu ya, resep sedang disiapkan...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF1A1A1D), fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (!isLoading && _isDialogShowing) {
      _isDialogShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleLoadingState(context, context.read<ChatProvider>().isLoading);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasty Ramadan'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Color(0xFF007AFF)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFF2F2F7),
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      return message.isUser
                          ? Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 8,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF007AFF),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                message.text,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                          : Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 8,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: MarkdownBody(
                                data: message.text,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(
                                    color: Color(0xFF1A1A1D),
                                    height: 1.5,
                                    fontSize: 16,
                                  ),
                                  h2: TextStyle(
                                    color: Color(0xFF1A1A1D),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 2,
                                  ),
                                ),
                              ),
                            ),
                          );
                    },
                  );
                },
              ),
            ),
            if (context.watch<ChatProvider>().showOptions)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children:
                      context.watch<ChatProvider>().options.map((option) {
                        final isSelected = context
                            .watch<ChatProvider>()
                            .selectedIngredients
                            .contains(option);
                        return ElevatedButton(
                          onPressed:
                              () => context.read<ChatProvider>().selectOption(
                                option,
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isSelected ? Color(0xFF007AFF) : Colors.white,
                            foregroundColor:
                                isSelected ? Colors.white : Color(0xFF007AFF),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color:
                                    isSelected
                                        ? Colors.transparent
                                        : Color(0xFF007AFF),
                                width: 1,
                              ),
                            ),
                            elevation: isSelected ? 2 : 0,
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Color(0xFF1A1A1D),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            if (context.watch<ChatProvider>().step == 6 &&
                context.watch<ChatProvider>().showOptions)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        context
                                .watch<ChatProvider>()
                                .selectedIngredients
                                .isNotEmpty
                            ? () => context.read<ChatProvider>().selectOption(
                              'Lanjut',
                            )
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          context
                                  .watch<ChatProvider>()
                                  .selectedIngredients
                                  .isNotEmpty
                              ? Color(0xFF007AFF)
                              : Colors.grey[300],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation:
                          context
                                  .watch<ChatProvider>()
                                  .selectedIngredients
                                  .isNotEmpty
                              ? 2
                              : 0,
                    ),
                    child: Text(
                      'Lanjut',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            if (context.watch<ChatProvider>().messages.isNotEmpty &&
                context.watch<ChatProvider>().messages.last.text ==
                    'Tambahkan resep ini ke menu favorit jika kamu suka ya!')
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Replace the existing favorite button with this code
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final chatProvider = context.read<ChatProvider>();
                          if (chatProvider.isFavorite()) {
                            chatProvider.removeFavoriteRecipe();
                            _showFavoriteDialog(context, false);
                          } else {
                            chatProvider.saveFavoriteRecipe();
                            _showFavoriteDialog(context, true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              context.watch<ChatProvider>().isFavorite()
                                  ? Color(
                                    0xFFD84040,
                                  ) // Red background for "Batal Favorite"
                                  : Color(0xFF007AFF),
                          // Blue background for "Favorite"
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color:
                                  context.watch<ChatProvider>().isFavorite()
                                      ? Color(
                                        0xFFD84040,
                                      ) // Red border for "Batal Favorite"
                                      : Color(0xFF007AFF),
                              // Blue border for "Favorite"
                              width: 1,
                            ),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          context.watch<ChatProvider>().isFavorite()
                              ? 'Batal Favorite'
                              : 'Favorite',
                          style: TextStyle(
                            color: Colors.white, // White text for both states
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            () =>
                                context
                                    .read<ChatProvider>()
                                    .resetConversation(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF1A1A1D),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: Color(0xFF1A1A1D),
                              width: 1,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Buat Resep Lain',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
