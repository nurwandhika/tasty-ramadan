import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../../../../core/models/chat_message.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../helpers/database_helper.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  final List<String> _selectedIngredients = [];
  List<String> _favoriteRecipes = [];
  bool _isLoading = false;
  int _step = 0;
  bool _showOptions = true;

  String _category = '';
  String _cuisine = '';
  String _subCuisine = '';
  String _dishType = '';
  String _dietaryPreference = '';
  String _cookingTime = '';
  String _currentRecipe = '';

  List<ChatMessage> get messages => _messages;

  bool get isLoading => _isLoading;

  bool get showOptions => _showOptions;

  List<String> get selectedIngredients => _selectedIngredients;

  int get step => _step;

  List<String> get favoriteRecipes => _favoriteRecipes;

  ChatProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    _favoriteRecipes = await DatabaseHelper().getFavorites();
    notifyListeners();
  }

  List<String> get options {
    switch (_step) {
      case 1:
        return ['Sahur', 'Iftar'];
      case 2:
        return [
          'Pembuka',
          'Hidangan Utama',
          'Lauk',
          'Makanan Penutup & Camilan',
          'Minuman',
        ];
      case 3:
        return ['Masakan Indonesia', 'Masakan Luar Negeri'];
      case 4:
        if (_cuisine == 'Masakan Indonesia') {
          return [
            'Jawa',
            'Sunda',
            'Betawi',
            'Sumatera Barat',
            'Sumatera Utara',
            'Sumatera Selatan',
            'Bali',
            'Sulawesi Selatan',
            'Kalimantan',
            'Maluku & Papua',
          ];
        } else {
          return ['Timur Tengah & Arab', 'Barat', 'Asia', 'Fusion'];
        }
      case 5:
        return [
          'Reguler',
          'Vegan',
          'Rendah Karbohidrat',
          'Tinggi Protein',
          'Rendah Kalori',
        ];
      case 6:
        return [
          'Protein',
          'Karbohidrat',
          'Sayuran',
          'Rempah & Herbal',
          'Susu & Alternatif',
          'Pemanis',
          'Apa Saja',
        ];
      case 7:
        return ['Cepat & Mudah', 'Standar', 'Lambat Dimasak'];
      default:
        return [];
    }
  }

  void startConversation() {
    _messages.add(
      ChatMessage(text: 'Apakah ini untuk Sahur atau Iftar?', isUser: false),
    );
    _step = 1;
    _showOptions = true;
    notifyListeners();
  }

  void selectOption(String option) {
    if (_step == 6 && option != 'Lanjut') {
      if (option == 'Apa Saja') {
        _selectedIngredients.clear();
        _selectedIngredients.add(option);
      } else {
        if (_selectedIngredients.contains('Apa Saja')) {
          _selectedIngredients.remove('Apa Saja');
        }
        if (_selectedIngredients.contains(option)) {
          _selectedIngredients.remove(option);
        } else {
          _selectedIngredients.add(option);
        }
      }
      notifyListeners();
      return;
    }

    if (_step == 6 && option == 'Lanjut') {
      _messages.add(ChatMessage(text: _selectedIngredients.join(', '), isUser: true));
    } else {
      _messages.add(ChatMessage(text: option, isUser: true));
    }
    notifyListeners();

    switch (_step) {
      case 1:
        _category = option;
        _messages.add(
          ChatMessage(
            text: 'Pilih jenis hidangan yang kamu mau:',
            isUser: false,
          ),
        );
        _step = 2;
        break;
      case 2:
        _dishType = option;
        _messages.add(
          ChatMessage(
            text: 'Masakan dari daerah mana nih?',
            isUser: false,
          ),
        );
        _step = 3;
        break;
      case 3:
        _cuisine = option;
        _messages.add(
          ChatMessage(text: 'Pilih sub-regional masakannya:', isUser: false),
        );
        _step = 4;
        break;
      case 4:
        _subCuisine = option;
        _messages.add(
          ChatMessage(text: 'Ada preferensi diet tertentu?', isUser: false),
        );
        _step = 5;
        break;
      case 5:
        _dietaryPreference = option;
        _messages.add(
          ChatMessage(text: 'Bahan apa aja yang tersedia?', isUser: false),
        );
        _step = 6;
        break;
      case 6:
        _messages.add(
          ChatMessage(text: 'Pilih waktu memasak:', isUser: false),
        );
        _step = 7;
        break;
      case 7:
        _cookingTime = option;
        _showOptions = false; // Hide options after selecting cooking time
        suggestRecipe();
        break;
    }
  }

  Future<void> suggestRecipe() async {
    _isLoading = true;
    notifyListeners();

    final prompt = '''
Karena sekarang bulan Ramadan, buat resep yang rinci untuk $_category. Resep ini untuk $_dishType yang berasal dari $_cuisine ($_subCuisine) dengan preferensi diet $_dietaryPreference. 
Resep harus mencakup bahan-bahan berikut: ${_selectedIngredients.join(', ')}. Waktu memasak sekitar $_cookingTime. 
Harap berikan instruksi langkah demi langkah, termasuk waktu persiapan dan waktu memasak. 
Judul resep harus dibungkus oleh ##.
''';
    print('Prompt: $prompt');

    try {
      final responseText = await _geminiService.generateResponse(prompt);
      _currentRecipe = responseText;
      _messages.add(
        ChatMessage(text: responseText, isUser: false, isMarkdown: true),
      );
      _messages.add(
        ChatMessage(
          text: 'Tambahkan resep ini ke menu favorit jika kamu suka ya!',
          isUser: false,
        ),
      );
      _showOptions = false;
    } catch (e, stackTrace) {
      developer.log(
        'Gagal mendapatkan saran resep',
        name: 'ChatProvider',
        error: e,
        stackTrace: stackTrace,
      );

      _messages.add(
        ChatMessage(
          text: 'Error: Gagal mendapatkan saran resep. Silakan coba lagi.',
          isUser: false,
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void saveFavoriteRecipe() async {
    if (_currentRecipe.isNotEmpty &&
        !_favoriteRecipes.contains(_currentRecipe)) {
      _favoriteRecipes.add(_currentRecipe);
      await DatabaseHelper().insertFavorite(_currentRecipe);
      notifyListeners();
    }
  }

  void removeFavoriteRecipe() async {
    if (_currentRecipe.isNotEmpty &&
        _favoriteRecipes.contains(_currentRecipe)) {
      _favoriteRecipes.remove(_currentRecipe);
      await DatabaseHelper().deleteFavorite(_currentRecipe);
      notifyListeners();
    }
  }

  bool isFavorite() {
    return _favoriteRecipes.contains(_currentRecipe);
  }

  void resetConversation() {
    _messages.clear();
    _selectedIngredients.clear();
    _category = '';
    _cuisine = '';
    _subCuisine = '';
    _dishType = '';
    _dietaryPreference = '';
    _cookingTime = '';
    _currentRecipe = '';
    _step = 0;
    _showOptions = true;
    startConversation();
  }
}