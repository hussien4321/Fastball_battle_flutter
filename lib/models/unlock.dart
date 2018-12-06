

class Unlock{

  int _unlockThreshold;
  bool _unlocked;
  int _coinPrice;

  int get unlockThreshold => _unlockThreshold;
  bool get unlocked => _unlocked;
  int get coinPrice => _coinPrice;
  

  Unlock.fromJson(Map<String, dynamic> json)
    : _unlockThreshold = json['unlock_threshold'],
      _unlocked = json['unlocked'] == 'true',
      _coinPrice = json['coin_price'];

}