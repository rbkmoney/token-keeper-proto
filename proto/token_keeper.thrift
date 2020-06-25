/**
 * Сервис хранения оффлайн токенов.
 */

namespace java com.rbkmoney.token.keeper
namespace erlang token_keeper

include "base.thrift"
include "attributes.thrift"

typedef base.ID AuthDataID
typedef string Token
typedef base.Timestamp AuthDataExpTime
typedef list<attributes.Attribute> Attributes

// Не нужно ли усложнить до чего-то типа `map<Namespace, map<string, string>>` или даже
// `map<Namespace, JSON>`? Могу представить ситуацию, когда сервис менеджмента api-ключей захочет
// записать и непрозрачную клиентскую метадату, и какую-то свою. К тому же токены будут выписывать
// разные сервисы.
typedef map<string, string> Metadata

enum AuthDataStatus {
    active
    revoked
    expired
}

struct AuthData {
    /**
     * Основной идентификатор авторизационных данных.
     * Отсутствует у эфемерных токенов.
     */
    1: optional AuthDataID             id
    2: required Token                  token
    3: required AuthDataStatus         status
    4: required AuthDataExpTime        exp_time
    5: required Attributes             attributes
    6: required Metadata               metadata

    // Realm превратился в один из атрибутов. Разумно ли?
    // 8: required Realm                  realm
}

exception AuthDataNotFound {}
exception AuthDataRevoked {}
exception AuthDataExpired {}

service TokenKeeper {

    /**
    * Создать новый оффлайн токен.
    **/
    AuthData Create (1: Attributes attributes, 2: Metadata metadata)

    /**
    * Создать новый токен с ограниченным временем жизни.
    **/
    AuthData CreateWithExpiration (1: Attributes attributes, 2: Metadata metadata, 3: AuthDataExpTime exp_time)
    // AuthData CreateEphemeral(1: Attributes attributes, 2: Metadata metadata)?

    /**
    * Получить данные токена по токену.
    **/
    AuthData GetByToken (1: Token token)
        throws (
            // Нам не нужно больше подробностей?
            // Сейчас получается, что ситуацию «нет токена с таким зашитым в токен id» отличить от
            // ситуации «подпись чёт неверная» или «у нас нет такого ключа» клиент никак не сможет.
            // Проблему я здесь вижу только в том, что кому-то не помешает в (аудит?)лог кажется
            // писануть сообщение со всеми подробностями, которые в этот момент только у клиента
            // есть.
            1: AuthDataNotFound ex1
            /// Тут логика в том, что мы обезопашиваем клиентов от необходимости в дополнительной
            /// логике проверки статусов, и как следствие от возможности ошибиться.
            2: AuthDataExpired ex2
            3: AuthDataRevoked ex3
    )

    /**
    * Получить данные токена по идентификатору.
    **/
    AuthData Get (1: AuthDataID id)
        throws (
            1: AuthDataNotFound ex1
    )

    /**
    * Деактивировать оффлайн токен.
    **/
    void Revoke (1: AuthDataID id)
        throws (
            1: AuthDataNotFound ex1
    )

}
