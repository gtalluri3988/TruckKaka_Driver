class TripModel {
  final int? tripId;
  final String? tripCode;
  final int? vehicleId;
  final int? driverId;
  final int? ownerId;
  final int? bookingId;
  final String? startLocation;
  final String? endLocation;
  final String? loadDescription;
  final double? weight;
  final double? totalPrice;
  final double? salaryAmount;
  final double? approvedAmount;
  final String? startDateTime;
  final String? endDateTime;
  final String? tripStartTime;
  final String? tripEndTime;
  final int? distance;
  final int? duration; // minutes
  final bool isSelfDrive;
  // status is a string: "Planned" | "Accepted" | "OnGoing" | "Completed" | "Cancelled"
  final String status;
  final int? driverStatusId;
  final int? tripStatusId;
  final int? vehicleStatusId;
  final Map<String, dynamic>? vehicleDetails;
  final Map<String, dynamic>? tripStatus;
  // Flat driver fields
  final String? driverFirstName;
  final String? driverLastName;
  final String? driverMobile;
  // Cancellation
  final String? cancelledBy;
  final String? cancelledDate;
  final String? cancellationReason;
  // Payment
  final String? paymentStatus;
  // Timestamp
  final String? createdDate;
  // Location detail fields (city/state/country)
  final String? pickUpCity;
  final String? pickUpState;
  final String? pickUpCountry;
  final String? dropCity;
  final String? dropState;
  final String? dropCountry;

  const TripModel({
    this.tripId,
    this.tripCode,
    this.vehicleId,
    this.driverId,
    this.ownerId,
    this.bookingId,
    this.startLocation,
    this.endLocation,
    this.loadDescription,
    this.weight,
    this.totalPrice,
    this.salaryAmount,
    this.approvedAmount,
    this.startDateTime,
    this.endDateTime,
    this.tripStartTime,
    this.tripEndTime,
    this.distance,
    this.duration,
    this.isSelfDrive = false,
    this.status = 'Planned',
    this.driverStatusId,
    this.tripStatusId,
    this.vehicleStatusId,
    this.vehicleDetails,
    this.tripStatus,
    this.driverFirstName,
    this.driverLastName,
    this.driverMobile,
    this.cancelledBy,
    this.cancelledDate,
    this.cancellationReason,
    this.paymentStatus,
    this.createdDate,
    this.pickUpCity,
    this.pickUpState,
    this.pickUpCountry,
    this.dropCity,
    this.dropState,
    this.dropCountry,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      tripId: json['tripId'] as int?,
      tripCode: json['tripCode']?.toString(),
      vehicleId: json['vehicleId'] as int?,
      driverId: json['driverId'] as int?,
      ownerId: json['ownerId'] as int?,
      bookingId: json['bookingId'] as int?,
      startLocation: json['startLocation']?.toString(),
      endLocation: json['endLocation']?.toString(),
      loadDescription: json['loadDescription']?.toString(),
      weight: (json['weight'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      salaryAmount: (json['salaryAmount'] as num?)?.toDouble(),
      approvedAmount: (json['approvedAmount'] as num?)?.toDouble(),
      startDateTime: json['startDateTime']?.toString(),
      endDateTime: json['endDateTime']?.toString(),
      tripStartTime: json['tripStartTime']?.toString(),
      tripEndTime: json['tripEndTime']?.toString(),
      distance: json['distance'] as int?,
      duration: json['duration'] as int?,
      isSelfDrive: json['isSelfDrive'] as bool? ?? false,
      status: json['status']?.toString() ?? 'Planned',
      driverStatusId: json['driverStatusId'] as int?,
      tripStatusId: json['tripStatusId'] as int?,
      vehicleStatusId: json['vehicleStatusId'] as int?,
      vehicleDetails: json['vehicleDetails'] as Map<String, dynamic>?,
      tripStatus: json['tripStatus'] as Map<String, dynamic>?,
      driverFirstName: json['driverFirstName']?.toString(),
      driverLastName: json['driverLastName']?.toString(),
      driverMobile: json['driverMobile']?.toString(),
      cancelledBy: json['cancelledBy']?.toString(),
      cancelledDate: json['cancelledDate']?.toString(),
      cancellationReason: json['cancellationReason']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
      createdDate: json['createdDate']?.toString(),
      pickUpCity: json['pickUpCity']?.toString(),
      pickUpState: json['pickUpState']?.toString(),
      pickUpCountry: json['pickUpCountry']?.toString(),
      dropCity: json['dropCity']?.toString(),
      dropState: json['dropState']?.toString(),
      dropCountry: json['dropCountry']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'tripId': tripId,
        'vehicleId': vehicleId,
        'driverId': driverId,
        'startLocation': startLocation,
        'endLocation': endLocation,
        'loadDescription': loadDescription,
        'weight': weight,
        'totalPrice': totalPrice,
        'startDateTime': startDateTime,
        'endDateTime': endDateTime,
        'distance': distance,
        'ownerId': ownerId,
        'isSelfDrive': isSelfDrive,
        'status': status,
      };

  // ── Status helpers ────────────────────────────────────────────────────────────
  // New TripStatus values: Planned=1, DriverAssigned=2, DriverAccepted=3,
  // Started=4, PickupConfirmed=5, InTransit=6, Completed=7, Cancelled=8, DriverRejected=9

  bool get isPendingAcceptance =>
      tripStatusId == 2 || // DriverAssigned
      status.toLowerCase() == 'driverassigned' ||
      status.toLowerCase() == 'planned'; // backward compat

  bool get isAccepted =>
      tripStatusId == 3 || // DriverAccepted
      status.toLowerCase() == 'driveraccepted' ||
      status.toLowerCase() == 'accepted'; // backward compat

  bool get isOnGoing =>
      (tripStatusId != null && tripStatusId! >= 4 && tripStatusId! <= 6) || // Started/PickupConfirmed/InTransit
      status.toLowerCase() == 'started' ||
      status.toLowerCase() == 'pickupconfirmed' ||
      status.toLowerCase() == 'intransit' ||
      status.toLowerCase() == 'ongoing'; // backward compat

  bool get isCompleted =>
      tripStatusId == 7 || // Completed
      status.toLowerCase() == 'completed';

  bool get isCancelled =>
      tripStatusId == 8 || // Cancelled
      status.toLowerCase() == 'cancelled';

  bool get isDriverRejected =>
      tripStatusId == 9 || // DriverRejected
      status.toLowerCase() == 'driverrejected';

  bool get isActive => !isCompleted && !isCancelled && !isDriverRejected;

  // ── Vehicle helpers ───────────────────────────────────────────────────────────

  String get vehicleRegNo =>
      vehicleDetails?['registrationNo']?.toString() ?? '';

  String get vehicleSpec =>
      vehicleDetails?['vehicleModelName']?.toString() ?? '';

  /// "Container Truck - KA 01 AB 1234"  or just reg no if type unavailable.
  String get vehicleDisplay {
    final truckType = vehicleDetails?['truckType'];
    final typeName = (truckType is Map)
        ? truckType['truckTypeName']?.toString()
        : null;
    final reg = vehicleRegNo;
    if (typeName != null && typeName.isNotEmpty && reg.isNotEmpty) {
      return '$typeName - $reg';
    }
    return reg.isNotEmpty ? reg : '—';
  }

  // ── Location helpers ──────────────────────────────────────────────────────────

  /// Pickup city/state/country joined, falls back to startLocation.
  String get pickupDisplay {
    final parts = [pickUpCity, pickUpState, pickUpCountry]
        .where((s) => s != null && s.isNotEmpty)
        .toList();
    if (parts.isNotEmpty) return parts.join(', ');
    return startLocation?.isNotEmpty == true ? startLocation! : '—';
  }

  /// Drop city/state/country joined, falls back to endLocation.
  String get dropDisplay {
    final parts = [dropCity, dropState, dropCountry]
        .where((s) => s != null && s.isNotEmpty)
        .toList();
    if (parts.isNotEmpty) return parts.join(', ');
    return endLocation?.isNotEmpty == true ? endLocation! : '—';
  }

  // ── Driver name ───────────────────────────────────────────────────────────────

  String get driverName =>
      '${driverFirstName ?? ''} ${driverLastName ?? ''}'.trim();

  // ── Date / time helpers ───────────────────────────────────────────────────────

  /// "2026-04-05 at 09:00 AM"
  String get startDateTimeDisplay {
    if (startDateTime == null) return '—';
    try {
      final d = DateTime.parse(startDateTime!);
      final h = d.hour > 12
          ? d.hour - 12
          : (d.hour == 0 ? 12 : d.hour);
      final ampm = d.hour >= 12 ? 'PM' : 'AM';
      final mm = d.minute.toString().padLeft(2, '0');
      final yy = d.year;
      final mo = d.month.toString().padLeft(2, '0');
      final dd = d.day.toString().padLeft(2, '0');
      return '$yy-$mo-$dd at $h:$mm $ampm';
    } catch (_) {
      return startDateTime!;
    }
  }

  /// Relative time: "Just now", "5 mins ago", "2 hours ago", "3 days ago"
  String get postedDisplay {
    if (createdDate == null) return '';
    try {
      final date = DateTime.parse(createdDate!).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
      if (diff.inHours < 24) return '${diff.inHours} hours ago';
      return '${diff.inDays} days ago';
    } catch (_) {
      return '';
    }
  }

  /// "5 hours 35 mins" or "45 mins" or "" if unavailable.
  String get durationDisplay {
    if (duration == null || duration! <= 0) return '';
    final h = duration! ~/ 60;
    final m = duration! % 60;
    if (h == 0) return '$m mins';
    if (m == 0) return '$h ${h == 1 ? "hour" : "hours"}';
    return '$h ${h == 1 ? "hour" : "hours"} $m mins';
  }

  /// "277 km • 5 hours 35 mins" or just km / duration parts.
  String get distanceDurationDisplay {
    final km = distance != null && distance! > 0 ? '${distance} km' : '';
    final dur = durationDisplay;
    if (km.isNotEmpty && dur.isNotEmpty) return '$km • $dur';
    if (km.isNotEmpty) return km;
    if (dur.isNotEmpty) return dur;
    return '';
  }

  /// "2026-04-02" from endDateTime / tripEndTime
  String get completedDateDisplay {
    final raw = endDateTime ?? tripEndTime;
    if (raw == null) return '—';
    try {
      final d = DateTime.parse(raw).toLocal();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.split('T').first;
    }
  }

  /// Driver's salary: salaryAmount → approvedAmount → 0
  double get earningsAmount => salaryAmount ?? approvedAmount ?? 0.0;

  /// "₹4,500" formatted, "—" if zero/unset
  String get earningsDisplay {
    final amt = earningsAmount;
    if (amt <= 0) return '—';
    return '₹${_fmtTripNum(amt.toInt())}';
  }

  /// "9 hrs" or "9 hrs 30 mins" from duration in minutes
  String get workingHoursDisplay {
    if (duration == null || duration! <= 0) return '—';
    final h = duration! ~/ 60;
    final m = duration! % 60;
    if (h == 0) return '$m mins';
    if (m == 0) return '$h hrs';
    return '$h hrs $m mins';
  }
}

// ── Trip Document Model ───────────────────────────────────────────────────────

class TripDocumentModel {
  final int? id;
  final int? tripId;
  final String documentType; // "pickup" | "received"
  final String? imageGuid;
  final String? originalFileName;
  final String? preview;
  final String? createdDate;

  const TripDocumentModel({
    this.id,
    this.tripId,
    required this.documentType,
    this.imageGuid,
    this.originalFileName,
    this.preview,
    this.createdDate,
  });

  factory TripDocumentModel.fromJson(Map<String, dynamic> json) {
    return TripDocumentModel(
      id: json['id'] as int?,
      tripId: json['tripId'] as int?,
      documentType: json['documentType']?.toString() ?? '',
      imageGuid: json['imageGuid']?.toString(),
      originalFileName: json['originalFileName']?.toString(),
      preview: json['preview']?.toString(),
      createdDate: json['createdDate']?.toString(),
    );
  }

  /// "2 Apr 2026 at 09:00 AM"
  String get uploadedAtDisplay {
    if (createdDate == null) return '';
    try {
      final d = DateTime.parse(createdDate!).toLocal();
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
      final mm = d.minute.toString().padLeft(2, '0');
      final ampm = d.hour >= 12 ? 'PM' : 'AM';
      return '${d.day} ${months[d.month - 1]} ${d.year} at $h:$mm $ampm';
    } catch (_) {
      return '';
    }
  }

  bool get isPickup => documentType.toLowerCase() == 'pickup';
  bool get isReceived => documentType.toLowerCase() == 'received';
}

// ── Expense Model ─────────────────────────────────────────────────────────────

class TripExpenseModel {
  final int? transactionId;
  final int? tripId;
  final String? transactionType;
  final int? expenseTypeId;
  final String? expenseTypeName;
  final double? amount;
  final String? transactionDate;
  final String? notes;

  const TripExpenseModel({
    this.transactionId,
    this.tripId,
    this.transactionType,
    this.expenseTypeId,
    this.expenseTypeName,
    this.amount,
    this.transactionDate,
    this.notes,
  });

  factory TripExpenseModel.fromJson(Map<String, dynamic> json) {
    final expType = json['expenseType'] as Map<String, dynamic>?;
    return TripExpenseModel(
      transactionId: json['transactionId'] as int?,
      tripId: json['tripId'] as int?,
      transactionType: json['transactionType']?.toString(),
      expenseTypeId: json['expenseTypeId'] as int? ?? (expType?['id'] as int?),
      expenseTypeName: expType?['name']?.toString() ??
          json['transactionType']?.toString() ??
          'Expense',
      amount: (json['amount'] as num?)?.toDouble(),
      transactionDate: json['transactionDate']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  /// "₹500" or "₹1,200"
  String get amountDisplay {
    if (amount == null) return '—';
    if (amount! == amount!.truncateToDouble()) {
      return '₹${amount!.toInt()}';
    }
    return '₹${amount!.toStringAsFixed(2)}';
  }

  /// "2 Apr 2026" formatted date
  String get dateDisplay {
    if (transactionDate == null) return '';
    try {
      final d = DateTime.parse(transactionDate!).toLocal();
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '';
    }
  }
}

// ── Advance Model ─────────────────────────────────────────────────────────────

class TripAdvanceModel {
  final int? advanceId;
  final int? tripId;
  final double? requestedAmount;
  final double? approvedAmount;
  final String? status;
  final String? requestorComments;
  final String? approverComments;
  final String? paymentMode;
  final String? requestDate;

  const TripAdvanceModel({
    this.advanceId,
    this.tripId,
    this.requestedAmount,
    this.approvedAmount,
    this.status,
    this.requestorComments,
    this.approverComments,
    this.paymentMode,
    this.requestDate,
  });

  factory TripAdvanceModel.fromJson(Map<String, dynamic> json) {
    return TripAdvanceModel(
      advanceId: json['advanceId'] as int?,
      tripId: json['tripId'] as int?,
      requestedAmount: (json['requestedAmount'] as num?)?.toDouble(),
      approvedAmount: (json['approvedAmount'] as num?)?.toDouble(),
      status: json['status']?.toString(),
      requestorComments: json['requestorComments']?.toString(),
      approverComments: json['approverComments']?.toString(),
      paymentMode: json['paymentMode']?.toString(),
      requestDate: json['requestDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'advanceId': advanceId,
        'tripId': tripId,
        'requestedAmount': requestedAmount,
        'approvedAmount': approvedAmount,
        'status': status,
        'requestorComments': requestorComments,
        'paymentMode': paymentMode,
      };
}

// ── Transaction Summary Model ─────────────────────────────────────────────────

class TripTransactionModel {
  final double? tripCost;
  final double? tripDriverAdvance;
  final double? driverSpent;
  final double? balanceLeft;
  final double? driverSalaryApprovedAmount;
  final double? driverEarnedSalary;
  final double? driverSalaryAfterAdjustment;
  final double? totalExpenses;

  const TripTransactionModel({
    this.tripCost,
    this.tripDriverAdvance,
    this.driverSpent,
    this.balanceLeft,
    this.driverSalaryApprovedAmount,
    this.driverEarnedSalary,
    this.driverSalaryAfterAdjustment,
    this.totalExpenses,
  });

  factory TripTransactionModel.fromJson(Map<String, dynamic> json) {
    return TripTransactionModel(
      tripCost: (json['tripCost'] as num?)?.toDouble(),
      tripDriverAdvance: (json['tripDriverAdvance'] as num?)?.toDouble(),
      driverSpent: (json['driverSpent'] as num?)?.toDouble(),
      balanceLeft: (json['balanceLeft'] as num?)?.toDouble(),
      driverSalaryApprovedAmount:
          (json['driverSalaryApprovedAmount'] as num?)?.toDouble(),
      driverEarnedSalary: (json['driverEarnedSalary'] as num?)?.toDouble(),
      driverSalaryAfterAdjustment:
          (json['driverSalaryAfterAdjustment'] as num?)?.toDouble(),
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble(),
    );
  }
}

// ── Notification Model ────────────────────────────────────────────────────────

class NotificationModel {
  final int? id;
  final String? title;
  final String? message;
  final String? type;
  final int? referenceId;
  final int? userId;
  final bool isRead;
  final String? createdDate;

  const NotificationModel({
    this.id,
    this.title,
    this.message,
    this.type,
    this.referenceId,
    this.userId,
    this.isRead = false,
    this.createdDate,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int?,
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      type: json['type']?.toString(),
      referenceId: json['referenceId'] as int?,
      userId: json['userId'] as int?,
      isRead: json['isRead'] as bool? ?? false,
      createdDate: json['createdDate']?.toString(),
    );
  }
}

// ── Number format helper ──────────────────────────────────────────────────────

/// Formats an integer with thousand separators: 18000 → "18,000"
String _fmtTripNum(int n) {
  final s = n.abs().toString();
  if (s.length <= 3) return n < 0 ? '-$s' : s;
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return (n < 0 ? '-' : '') + buf.toString();
}
