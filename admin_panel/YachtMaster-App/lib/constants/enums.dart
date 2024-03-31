enum MediaTypeEnum { image, video }

enum MessageType { text }

enum ChatType { single, group }

enum UserType { user, admin }
enum CharterStatus {active,inactive}
enum BookingStatus { ongoing,completed,cancelled, }
enum PaymentPayoutsStatus { pending,paid }
enum DepositStatus {nothingPaid,twentyFivePaid,fullPaid,giveRating}
enum PayType { fullPay,deposit }
enum CharterDayType { halfDay,fullDay,multiDay }
enum StatusType { active, blocked, deleted }
enum RequestStatus { notHost, requestHost,host,all }


enum LoginType { email, google, apple }

enum UserStatus { active,blocked,deleted }


enum PostType { newPost, shared }

enum PostStatus { active, inActive, deleted }

enum NotificationsType { like, comment, addFriend, chat, group ,report}

enum ReportStatusType { completed, pending }

enum CommentType { newComment, reply }

enum CommentStatus { active, deleted }

enum GroupStatus { inactive, active, deleted }

enum GenderEnum { male, female, other }
enum AppContentType {
  privacyPolicy,termsOfService,safetyCenter
  ,howYachtWorks,
  privacySharing,helpCenter,givingBack,covidPolicy,refundPolicy
  ,cancellationPolicy,
  exploreResources,reportListing,bringingAnimals}

enum NotificationReceiverType { person,host }
