enum CharterDayType { halfDay,fullDay,multiDay }
enum PayType { fullPay,deposit }
enum FavouriteType { service,charter,yacht,host }
enum PaymentMethodEnum { card,appStore,crypto,wallet }
enum SplitType { yes,no }
enum DepositStatus {nothingPaid,twentyFivePaid,fullPaid,giveRating}
enum NotificationReceiverType { person,host }
enum SeeAllType { charter,service,host,yacht }
enum PaymentPayoutsStatus { pending,paid,received }
enum BookingStatus { ongoing,completed,canceled, }
enum PaymentStatus {confirmBooking,payInAppOrCash,markAsComplete,giveRating,ratingDone}
enum PaymentType {payCash,payInApp}
enum CharterStatus {active,inactive}
enum EarnHistory {earn,paid}
enum AppContentType {
  privacyPolicy,termsOfService,safetyCenter
  ,howYachtWorks,
  privacySharing,helpCenter,givingBack,covidPolicy,refundPolicy
  ,cancellationPolicy,
  exploreResources,reportListing,bringingAnimals}
enum UserType { user, admin }
enum UserStatus { active,blocked,deleted }
enum RequestStatus { notHost, requestHost,host }
