// ignore_for_file: avoid_print

import 'package:flutter_application_3/screens/models/address_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressService {
  static const String _addressTable = 'UserAddress';
  final supabase = Supabase.instance.client;

  Future<List<Object>> getAddresses(String userId) async {
    final response = await supabase
        .from(_addressTable)
        .select()
        .eq('user_id', userId);

    if (response.error != null) {
      print('Error fetching addresses: ${response.error!.message}');
      return [];
    }

    return (response.data as List<dynamic>)
        .map((item) => Address.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> saveAddress(Address address, String userId) async {
    final response = await supabase.from(_addressTable).insert({
      'user_id': userId,
      'name': address.name,
      'email': address.email,
      'phone': address.phone,
      'address': address.address,
      'zipCode': address.zipCode,
      'city': address.city,
      'country': address.country,
      'isDefault': address.isDefault,
    });

    if (response.error != null) {
      print('Error saving address: ${response.error!.message}');
      return false;
    }

    return true;
  }

  Future<bool> deleteAddress(String addressId) async {
    final response = await supabase
        .from(_addressTable)
        .delete()
        .eq('id', addressId);

    if (response.error != null) {
      print('Error deleting address: ${response.error!.message}');
      return false;
    }

    return true;
  }
}

extension on PostgrestList {
  get error => null;
  
  get data => null;
}
