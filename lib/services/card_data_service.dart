import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logging/app_logger.dart';

class CardIssuer {
  final String id;
  final String name;
  final String? logoUrl;
  final String? websiteUrl;
  final String? customerServicePhone;
  final bool isActive;

  CardIssuer({
    required this.id,
    required this.name,
    this.logoUrl,
    this.websiteUrl,
    this.customerServicePhone,
    required this.isActive,
  });

  factory CardIssuer.fromJson(Map<String, dynamic> json) {
    return CardIssuer(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo_url'],
      websiteUrl: json['website_url'],
      customerServicePhone: json['customer_service_phone'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class CardProduct {
  final String id;
  final String issuerId;
  final String? categoryId;
  final String productName;
  final String? description;
  final double? annualFee;
  final double? joiningFee;
  final double? rewardRate;
  final String? welcomeBonus;
  final List<String> keyBenefits;
  final bool isActive;

  CardProduct({
    required this.id,
    required this.issuerId,
    this.categoryId,
    required this.productName,
    this.description,
    this.annualFee,
    this.joiningFee,
    this.rewardRate,
    this.welcomeBonus,
    required this.keyBenefits,
    required this.isActive,
  });

  factory CardProduct.fromJson(Map<String, dynamic> json) {
    return CardProduct(
      id: json['id'],
      issuerId: json['issuer_id'],
      categoryId: json['category_id'],
      productName: json['product_name'],
      description: json['product_description'],
      annualFee: json['annual_fee']?.toDouble(),
      joiningFee: json['joining_fee']?.toDouble(),
      rewardRate: json['reward_rate']?.toDouble(),
      welcomeBonus: json['welcome_bonus'],
      keyBenefits:
          (json['key_benefits'] as List<dynamic>?)?.cast<String>() ?? [],
      isActive: json['is_active'] ?? true,
    );
  }
}

class CardDataService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all active card issuers from the database
  static Future<List<CardIssuer>> getCardIssuers() async {
    try {
      AppLogger.debug('Fetching card issuers from database');

      final response = await _supabase
          .from('card_issuers')
          .select()
          .eq('is_active', true)
          .order('name');

      final List<CardIssuer> issuers = (response as List<dynamic>)
          .map((json) => CardIssuer.fromJson(json))
          .toList();

      AppLogger.info('Fetched ${issuers.length} card issuers', null, null, {
        'issuers': issuers.map((i) => i.name).toList(),
      });

      return issuers;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to fetch card issuers', error, stackTrace);

      // Return fallback data for Indian banks
      return [
        CardIssuer(id: 'fallback-hdfc', name: 'HDFC Bank', isActive: true),
        CardIssuer(id: 'fallback-axis', name: 'Axis Bank', isActive: true),
        CardIssuer(id: 'fallback-icici', name: 'ICICI Bank', isActive: true),
        CardIssuer(
            id: 'fallback-sbi', name: 'State Bank of India', isActive: true),
        CardIssuer(
            id: 'fallback-kotak', name: 'Kotak Mahindra Bank', isActive: true),
      ];
    }
  }

  /// Fetch card products for a specific issuer
  static Future<List<CardProduct>> getCardProducts(String issuerId) async {
    try {
      AppLogger.debug('Fetching card products for issuer', null, null, {
        'issuerId': issuerId,
      });

      final response = await _supabase
          .from('card_products')
          .select()
          .eq('issuer_id', issuerId)
          .eq('is_active', true)
          .order('product_name');

      final List<CardProduct> products = (response as List<dynamic>)
          .map((json) => CardProduct.fromJson(json))
          .toList();

      AppLogger.info('Fetched ${products.length} card products', null, null, {
        'issuerId': issuerId,
        'products': products.map((p) => p.productName).toList(),
      });

      return products;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to fetch card products', error, stackTrace, {
        'issuerId': issuerId,
      });

      // Return empty list on error
      return [];
    }
  }

  /// Get all card products with issuer information
  static Future<List<Map<String, dynamic>>> getCardProductsWithIssuer() async {
    try {
      AppLogger.debug('Fetching all card products with issuer info');

      final response = await _supabase
          .from('card_products')
          .select('''
            id,
            product_name,
            annual_fee,
            reward_rate,
            key_benefits,
            card_issuers!inner(id, name)
          ''')
          .eq('is_active', true)
          .eq('card_issuers.is_active', true)
          .order('card_issuers(name), product_name');

      AppLogger.info('Fetched card products with issuer info', null, null, {
        'count': (response as List<dynamic>).length,
      });

      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (error, stackTrace) {
      AppLogger.error(
          'Failed to fetch card products with issuer info', error, stackTrace);
      return [];
    }
  }

  /// Search card products by name or issuer name
  static Future<List<Map<String, dynamic>>> searchCardProducts(
      String query) async {
    try {
      AppLogger.debug('Searching card products', null, null, {
        'query': query,
      });

      final response = await _supabase
          .from('card_products')
          .select('''
            id,
            product_name,
            annual_fee,
            reward_rate,
            key_benefits,
            card_issuers!inner(id, name)
          ''')
          .eq('is_active', true)
          .eq('card_issuers.is_active', true)
          .or('product_name.ilike.%$query%,card_issuers.name.ilike.%$query%')
          .order('card_issuers(name), product_name');

      AppLogger.info(
          'Found ${(response as List<dynamic>).length} matching products',
          null,
          null, {
        'query': query,
      });

      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to search card products', error, stackTrace, {
        'query': query,
      });
      return [];
    }
  }
}
