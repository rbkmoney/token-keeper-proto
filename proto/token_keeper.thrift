/**
 * Сервис хранения оффлайн токенов.
 */

namespace java com.rbkmoney.token.keeper
namespace erlang token_keeper

include "base.thrift"

typedef base.ID AuthDataID
typedef base.ID SubjectID
typedef string Token
typedef base.Timestamp AuthDataExpTime
typedef map<string, string> Metadata
typedef string Domain

enum AuthDataStatus {
    active
    revoked
}

enum Realm {
    external,
    internal
}

/**
* Используется как контейнер для хранения ролей в виде строки,
* которые обрабатываются с помощью UAC
**/
struct UACRole {
    1: required string role
}

/**
* Контейнер для ролей.
**/
union Role {
    1: UACRole uac_role
}

/**
 * Набор ролей для сервиса.
**/
struct RoleStorage {
    1: required list<Role> roles
}

/**
 * Ссылка на party/shop.
**/
struct Reference {
    1: required string shop_id
    2: required string party_id
}

/**
 * Информация связанная с токеном.
**/
struct Scope {
    1: required Reference reference
    2: optional map<Domain, RoleStorage> resource_access
}

struct AuthData {
    1: required AuthDataID             id
    2: required Token                  token
    3: required AuthDataStatus         status
    4: required AuthDataExpTime        exp_time
    5: required Scope                  scope
    6: required Metadata               metadata
    7: required SubjectID              subject_id
    8: required Realm                  realm
}

exception AuthDataNotFound {}

service TokenKeeper {

    /**
    * Создать новый оффлайн токен.
    **/
    AuthData Create (1: Scope scope, 2: Metadata metadata, 3: SubjectID subject_id, 4: Realm realm)

    /**
    * Обновить существующий оффлайн токен.
    **/
    AuthData Update (1: Scope scope, 2: Metadata metadata, 3: AuthDataID id)

    /**
    * Создать новый токен с ограниченным временем жизни.
    **/
    AuthData CreateWithExpiration (1: Scope scope, 2: Metadata metadata, 3: SubjectID subject_id, 4: Realm realm 5: AuthDataExpTime exp_time)

    /**
    * Получить данные токена по токену.
    **/
    AuthData GetByToken (1: Token token)
        throws (
            1: AuthDataNotFound ex1
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
