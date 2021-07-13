include "base.thrift"

namespace java com.rbkmoney.notification
namespace erlang notification

typedef string ContinuationToken
typedef base.ID PartyID
typedef base.ID NotificationTemplateId

exception NotificationTemplateNotFound {}
exception BadContinuationToken { 1: string reason }
exception BadNotificationTemplateState { 1: string reason }

struct NotificationTemplate {
    1: required NotificationTemplateId template_id
    2: required string title
    3: required base.Timestamp created_at
    4: optional base.Timestamp updated_at
    5: required NotificationTemplateState state
    6: required NotificationContent content,
    7: optional NotificationTemplateDistributionDetails distribution_details
}

struct NotificationTemplateDistributionDetails {
    1: required i64 read_count
    2: required i64 total_count
}

enum NotificationTemplateState {
    /* Состояние при котором возможно производить изменения в notification template */
    draft_state
    /*
       Состояние после которого невозможно модифицировать notification template.
       К примеру, после отправки нотификаций
    */
    final_state
}

enum NotificationStatus {
    read
    unread
}

struct Party {
    1: required PartyID party_id
}

struct PartyNotification {
    1: required NotificationTemplateId template_id
    2: required Party party
    3: required NotificationStatus status
}

union DateFilter {
    1: FixedDateFilter fixed_date_filter
    2: RangeDateFilter range_date_filter
}

struct FixedDateFilter {
    1: required base.Timestamp date
}

struct RangeDateFilter {
    1: required base.Timestamp from_date
    2: required base.Timestamp to_date
}

struct NotificationTemplatePartyRequest {
    1: required NotificationTemplateId template_id
    2: optional NotificationStatus status
    3: optional ContinuationToken continuation_token
    4: optional i32 limit
}

struct NotificationTemplatePartyResponse {
    1: required list<PartyNotification> parties
    2: optional ContinuationToken continuation_token
}

struct NotificationTemplateSearchRequest {
    1: optional string title
    2: optional string content
    3: optional DateFilter date
    4: optional ContinuationToken continuation_token
    5: optional i32 limit
}

struct NotificationTemplateSearchResponse {
    1: required list<NotificationTemplate> notification_templates
    2: optional ContinuationToken continuation_token
}

struct NotificationContent {
    1: required string text
    // Пример, text/markdown; charset=UTF-8
    2: optional string content_type
}

struct NotificationTemplateCreateRequest {
    1: required string title
    2: required NotificationContent content
}

struct NotificationTemplateModifyRequest {
    1: required NotificationTemplateId template_id
    2: optional string title
    3: optional NotificationContent content
}

service NotificationService {

    /* Создание шаблона уведомления */
    NotificationTemplate createNotificationTemplate(1: NotificationTemplateCreateRequest notification_request)
            throws (
                1: base.InvalidRequest ex1
            )

    /* Редактирование шаблона уведомления */
    NotificationTemplate modifyNotificationTemplate(1: NotificationTemplateModifyRequest notification_request)
            throws (
                1: base.InvalidRequest ex1,
                2: NotificationTemplateNotFound ex2,
                3: BadNotificationTemplateState ex3
            )

    NotificationTemplate getNotificationTemplate(1: NotificationTemplateId template_id)
            throws (
                1: NotificationTemplateNotFound ex1
            )

    /* Получение списка отправленных уведомлений для выбранного шаблона */
    NotificationTemplatePartyResponse findNotificationTemplateParties(1: NotificationTemplatePartyRequest party_request)
            throws (
                1: BadContinuationToken ex1
            )

    /* Поиск шаблонов уведомлений */
    NotificationTemplateSearchResponse findNotificationTemplates(1: NotificationTemplateSearchRequest notification_search_request)
            throws (
                1: BadContinuationToken ex1
            )

    /* Отправка уведомления выбранным мерчантам */
    void sendNotification(1: NotificationTemplateId template_id, 2: list<PartyID> party_ids)
            throws (
                1: NotificationTemplateNotFound ex1,
            )

    /* Отправка уведомления для всех мерчантов */
    void sendNotificationAll(1: NotificationTemplateId template_id)
            throws (
                1: NotificationTemplateNotFound ex1,
            )

}
