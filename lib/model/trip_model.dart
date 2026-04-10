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

  // Computed helpers
  String get vehicleRegNo =>
      vehicleDetails?['registrationNo']?.toString() ?? '';
  String get vehicleSpec =>
      vehicleDetails?['vehicleModelName']?.toString() ?? '';
  String get driverName =>
      '${driverFirstName ?? ''} ${driverLastName ?? ''}'.trim();

  bool get isPendingAcceptance =>
      status.toLowerCase() == 'planned' ||
      status.toLowerCase() == 'pendingdriveracceptance';
  bool get isAccepted =>
      status.toLowerCase() == 'accepted' || driverStatusId == 2;
  bool get isOnGoing =>
      status.toLowerCase() == 'ongoing' || tripStatusId == 3;
  bool get isCompleted =>
      status.toLowerCase() == 'completed' || tripStatusId == 4;
  bool get isCancelled =>
      status.toLowerCase() == 'cancelled' || tripStatusId == 5;
  bool get isActive => !isCompleted && !isCancelled;
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
