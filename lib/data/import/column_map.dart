class ColumnMap {
  static const faultNumber = 'fault_number';
  static const remoteAddress = 'remote_address_octal';
  static const subsets = 'subsets';
  static const failure = 'failure';

  static const alarmItem = 'alarm_item';
  static const designation = 'designation';
  static const dcsGroup = 'dcs_group';
  static const logic = 'logic';
  static const condition = 'condition';
  static const tempo = 'tempo';

  static const headerAliases = <String, List<String>>{
    faultNumber: [
      'fault number                                  ( display on local panel )',
      'fault number ( display on local panel )',
      'fault number',
    ],
    remoteAddress: [
      'address remote                              (octal)',
      'address remote (octal)',
      'address remote',
    ],
    subsets: ['subsets', 'subset'],
    failure: ['failure:', 'failure'],
    alarmItem: ['alarm item:', 'alarm item'],
    designation: ['designation:', 'designation'],
    dcsGroup: ['dcs group:', 'dcs group'],
    logic: ['logic:', 'logic'],
    condition: ['condition:', 'condition'],
    tempo: ['tempo:', 'tempo'],
  };

  static String norm(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
