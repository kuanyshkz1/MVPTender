import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/tender_model.dart';
import 'filter_screen.dart';
import 'tender_details_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Tender> allTenders = [];
  List<Tender> displayedTenders = [];
  
  final TextEditingController _searchController = TextEditingController();
  
  bool isPremium = false; 
  bool isLoading = true; 

  // Настройки видимости элементов карточки
  bool showNumber = true;
  bool showTitle = true;
  bool showCustomer = true;
  bool showPrice = true;
  bool showStatus = true;
  bool showEndDate = true;

  @override
  void initState() {
    super.initState();
    fetchTendersFromApi();
  }

  // ==========================================
  // БОЕВОЙ ЗАПРОС К API ГОСЗАКУПОК v3
  // ==========================================
  Future<void> fetchTendersFromApi() async {
    // Твой реальный токен вставлен сюда:
    const token = '0c38087b96cdac5816161222df3b8d99'; 

    final query = {
      "query": "query { trd_buy(limit: 25) { id name_ru number_anno total_sum ref_buy_status_id end_date } }"
    };

    try {
      print('🚀 Отправляем боевой запрос на Госзакупки v3...');
      
      final response = await http.post(
        Uri.parse('https://ows.goszakup.gov.kz/v3/graphql'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Подставляем токен
        },
        body: json.encode(query),
      );

      print('📡 Статус код: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Проверяем, есть ли ошибки от самого GraphQL
        if (data.containsKey('errors')) {
          print('⚠️ Ошибка GraphQL: ${data['errors']}');
          setState(() => isLoading = false);
          return;
        }

        if (data['data'] != null && data['data']['trd_buy'] != null) {
          final List<dynamic> lotsJson = data['data']['trd_buy'];
          print('✅ Успешно загружено тендеров: ${lotsJson.length}');
          
          setState(() {
            // Превращаем JSON в наши объекты Tender
            allTenders = lotsJson.map((json) => Tender.fromJson(json)).toList();
            displayedTenders = allTenders;
            isLoading = false; 
          });
        } else {
          print('⚠️ Сервер ответил 200, но массив trd_buy пустой или отсутствует.');
          setState(() => isLoading = false);
        }
      } else {
        print('❌ Ошибка сервера: ${response.statusCode}');
        print('Ответ: ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Ошибка сети или парсинга: $e');
      setState(() => isLoading = false);
    }
  }

  // ==========================================
  // ПОИСК И НАСТРОЙКИ КАРТОЧКИ
  // ==========================================
  void _filterTenders(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedTenders = allTenders;
      } else {
        displayedTenders = allTenders
            .where((tender) => tender.title.toLowerCase().contains(query.toLowerCase()) || 
                               tender.number.contains(query))
            .toList();
      }
    });
  }

  void _showCardSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Настройка карточки', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildToggle('Номер объявления', showNumber, (val) { setModalState(() => showNumber = val); setState(() {}); }),
                  _buildToggle('Наименование', showTitle, (val) { setModalState(() => showTitle = val); setState(() {}); }),
                  _buildToggle('Заказчик', showCustomer, (val) { setModalState(() => showCustomer = val); setState(() {}); }),
                  _buildToggle('Бюджет', showPrice, (val) { setModalState(() => showPrice = val); setState(() {}); }),
                  _buildToggle('Статус', showStatus, (val) { setModalState(() => showStatus = val); setState(() {}); }),
                  _buildToggle('Сроки', showEndDate, (val) { setModalState(() => showEndDate = val); setState(() {}); }),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildToggle(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(title: Text(title, style: const TextStyle(fontSize: 15)), value: value, activeColor: Colors.blue, onChanged: onChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================
  // ИНТЕРФЕЙС ЭКРАНА
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final itemsToShow = isPremium ? displayedTenders.length : (displayedTenders.length > 25 ? 25 : displayedTenders.length);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Tenders KZ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.dashboard_customize_outlined, color: Colors.blueGrey), onPressed: _showCardSettings),
          IconButton(icon: const Icon(Icons.tune, color: Colors.blue), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FilterScreen()))),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTenders,
              decoration: InputDecoration(
                hintText: 'Поиск по лотам или номеру',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () { _searchController.clear(); _filterTenders(''); }) : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          Expanded(
            child: isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : displayedTenders.isEmpty
                    ? const Center(child: Text('Ничего не найдено', style: TextStyle(color: Colors.grey)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: itemsToShow,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final tender = displayedTenders[index];
                          final bool isActive = tender.status == 'Прием заявок';
                          final Color statusColor = isActive ? Colors.green : Colors.grey;

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TenderDetailsScreen(tender: tender))),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (showNumber) Text(tender.number, style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                                          if (showNumber && showTitle) const SizedBox(height: 4),
                                          if (showTitle) Text(tender.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          if (showTitle && showCustomer) const SizedBox(height: 8),
                                          if (showCustomer) Text('${tender.customer} | БИН: ${tender.bin}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                          if ((showTitle || showCustomer) && showStatus) const SizedBox(height: 12),
                                          if (showStatus)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: statusColor.withOpacity(0.5))),
                                              child: Text(tender.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (showPrice) Text('${tender.price.toInt()} ₸', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 16)),
                                        if (showEndDate) ...[
                                          const SizedBox(height: 4),
                                          Text('до ${tender.endDate.day}.${tender.endDate.month}', style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                        const SizedBox(height: 8),
                                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}