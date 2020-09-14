/**
 * Сервис хранения оффлайн токенов.
 */

namespace java com.rbkmoney.token.keeper
namespace erlang token_keeper

include "base.thrift"
include "proto/decisions.thrift"

typedef base.ID AuthDataID
typedef string Token

typedef decisions.Context Context

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
    4: required Context                context
    5: required Metadata               metadata
}

exception AuthDataNotFound {}
exception AuthDataRevoked {}

service TokenKeeper {

    /**
    * Создать новый оффлайн токен.
    **/
    AuthData Create (1: Context context, 2: Metadata metadata)

    /**
    * Создать новый эфемерный токен.
    * Эфемерный токен не имеет идентификатора, потому что с ним не связаны никакие данные на
    * стороне сервиса. Как следствие, эфемерный токен невозможно отозвать. В связи с этим
    * клиентам рекомендуется обязательно задавать такие атрибуты, которые могут позволят время
    * жизни токена.
    **/
    AuthData CreateEphemeral (1: Context context, 2: Metadata metadata)

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
            2: AuthDataRevoked ex2
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
