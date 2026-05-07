import '../models/hidden_gem_model.dart';

class MockData {
  static List<HiddenGem> mockGems = [
    HiddenGem(
      id: '1',
      name: 'The Secret Jazz Garden',
      description: 'A hidden courtyard behind an old villa where local jazz musicians gather every Tuesday night. No signs outside, just follow the music.',
      category: 'Nightlife',
      vibe: 'Chill / Artistic',
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1514525253361-bee8718a74a2?auto=format&fit=crop&q=80&w=800',
      latitude: 30.0444,
      longitude: 31.2357,
      localsTip: 'Order the hibiscus tea and arrive before 9 PM to get a seat near the stage.',
      recommendedDishes: ['Hibiscus Tea', 'Karkadeh Popsicles'],
      isTrending: true,
    ),
    HiddenGem(
      id: '2',
      name: 'Tante Amira\'s Kitchen',
      description: 'The best homemade Mulukhiyah in the city. It\'s literally just Tante Amira\'s living room converted into a tiny dining area.',
      category: 'Food',
      vibe: 'Cozy / Authentic',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1541544741938-0af808871cc0?auto=format&fit=crop&q=80&w=800',
      latitude: 30.0500,
      longitude: 31.2400,
      localsTip: 'Don\'t ask for a menu; just ask what Amira cooked today.',
      recommendedDishes: ['Mulukhiyah with Rabbit', 'Roz Bel Laban'],
    ),
    HiddenGem(
      id: '3',
      name: 'Old City Rooftop View',
      description: 'An abandoned rooftop that offers the best sunset view of the Citadel without the crowds.',
      category: 'Sightseeing',
      vibe: 'Quiet / Romantic',
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1571235961513-399066601b34?auto=format&fit=crop&q=80&w=800',
      latitude: 30.0300,
      longitude: 31.2500,
      localsTip: 'Bring your own drinks and a light jacket.',
      recommendedDishes: [],
      isPremium: true,
    ),
  ];
}
