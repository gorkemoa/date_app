import 'package:flutter/material.dart';
import '../../models/events/event_model.dart';

class EventsViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<EventModel> _events = [];
  List<EventModel> get events => _events;

  void loadEvents() {
    _isLoading = true;
    notifyListeners();

    // Demo Data
    _events = [
      EventModel(
        id: '1',
        title: 'CEO Networking & Kahvaltı',
        description: 'Bölgedeki üst düzey yöneticiler ve kurucu ortaklar için özel networking kahvaltısı.',
        location: 'Four Seasons, Beşiktaş',
        date: DateTime.now().add(const Duration(days: 2)),
        creatorName: 'Ahmet Yılmaz',
        attendeeCount: 12,
        category: 'Kahvaltı',
        imageUrl: 'https://images.unsplash.com/photo-1543269865-cbf427effbad?q=80&w=1470&auto=format&fit=crop',
        attendeePhotos: ['https://i.pravatar.cc/150?u=1', 'https://i.pravatar.cc/150?u=2'],
      ),
      EventModel(
        id: '2',
        title: 'Teknoloji & Yatırım Paneli',
        description: 'Yapay zeka ve fintech dikeylerinde yatırım alan girişimlerin deneyim paylaşım paneli.',
        location: 'Kolektif House, Levent',
        date: DateTime.now().add(const Duration(days: 5)),
        creatorName: 'Zeynep Ak',
        attendeeCount: 45,
        category: 'Panel',
        imageUrl: 'https://images.unsplash.com/photo-1559136555-9303baea8ebd?q=80&w=1470&auto=format&fit=crop',
        attendeePhotos: ['https://i.pravatar.cc/150?u=3', 'https://i.pravatar.cc/150?u=4', 'https://i.pravatar.cc/150?u=5'],
      ),
      EventModel(
        id: '3',
        title: 'Akşamüstü Networking Kokteyli',
        description: 'İş sonrası rahat bir ortamda sektör liderleriyle tanışma fırsatı.',
        location: 'Hilton Rooftop, Taksim',
        date: DateTime.now().add(const Duration(days: 7)),
        creatorName: 'Can Mert',
        attendeeCount: 30,
        category: 'Kokteyl',
        imageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=1469&auto=format&fit=crop',
        attendeePhotos: ['https://i.pravatar.cc/150?u=6', 'https://i.pravatar.cc/150?u=7'],
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void createEvent(EventModel event) {
    _events.insert(0, event);
    notifyListeners();
  }
}
