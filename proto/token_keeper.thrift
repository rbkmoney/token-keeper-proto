/**
 * Сервис хранения оффлайн токенов.
 */

namespace java com.rbkmoney.token.keeper
namespace erlang token_keeper

include "base.thrift"
include "proto/context.thrift"

typedef base.ID AuthDataID
typedef string Token

typedef context.ContextFragment ContextFragment

typedef string MetadataNamespace
typedef map<MetadataNamespace, map<string, string>> Metadata

enum AuthDataStatus {
    active
    revoked
}

struct AuthData {
    /**
     * Основной идентификатор авторизационных данных.
     * Отсутствует у эфемерных токенов.
     */
    1: optional AuthDataID             id
    2: required Token                  token
    3: required AuthDataStatus         status
    4: required ContextFragment        context
    5: required Metadata               metadata
}

exception TokenMalformed {}

exception TokenUntrusted {
    1: required string code
    2: optional string description
}

exception AuthDataNotFound {}
exception AuthDataRevoked {}

service TokenKeeper {

    /**
    * Создать новый оффлайн токен.
    **/
    AuthData Create (1: ContextFragment context, 2: Metadata metadata)

    /**
    * Создать новый эфемерный токен.
    * Эфемерный токен не имеет идентификатора, потому что с ним не связаны никакие данные на
    * стороне сервиса. Как следствие, эфемерный токен невозможно отозвать. В связи с этим
    * клиентам рекомендуется обязательно задавать такие атрибуты, которые позволят контролировать
    * время жизни токена.
    **/
    AuthData CreateEphemeral (1: ContextFragment context, 2: Metadata metadata)

    /**
    * Получить данные токена по токену.
    **/
    AuthData GetByToken (1: Token token)
        throws (
            1: TokenMalformed ex1
            2: TokenUntrusted ex2
            3: AuthDataNotFound ex3
            4: AuthDataRevoked ex4
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
