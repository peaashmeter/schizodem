import 'dart:convert';

extension ToJson on Map {
  get json => jsonEncode(this);
}
