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

typedef map<string, string> Metadata
typedef string Authority

enum AuthDataStatus {
    active
    revoked
}

/**
* Авторизационные данные.
*/
struct AuthData {
    /**
     * Основной идентификатор авторизационных данных.
     * Отсутствует у эфемерных токенов.
     */
    1: optional AuthDataID             id
    /**
     * Токен, выпущенный для авторизационных данных.
     * Отсутствует в ситуациях, когда авторизационные данные были получены повторно после сохранения.
     */
    2: optional Token                  token
    3: required AuthDataStatus         status
    4: required ContextFragment        context
    5: required Metadata               metadata
    /**
    * Сущность, выпустившая данный токен.
    *
    * @deprecation Данное поле будет удалено после окончания фазы сбора информации о существующих в системе токенах.
    **/
    6: optional Authority              authority
}

struct TokenSourceContext {
    1: optional string request_origin
}

/**
 * Токен не может быть обработан.
 * Детали того, по каким причинам обработка невозможна, можно увидеть в аудит-логе. Причинами могут
 * выступать, например:
 *  - невозможность распарсить токен или его содержимое,
 *  - неподдерживаемая схема криптографической подписи,
 *  - неверная подпись,
 *  - невозможность найти секретный ключ, которым токен был подписан,
 *  - ...
 */
exception InvalidToken {}

/**
 * Авторизационные данные с таким ID не найдены
 **/
exception AuthDataNotFound {}

/**
 * Авторизационные данные с таким ID уже существуют
 **/
exception AuthDataAlreadyExists {}

exception AuthDataRevoked {}


/**
 * Сервис, осуществляющий аутентификацию токенов выпущенных всеми существующими в системе authority.
 **/
service TokenAuthenticator {

    /*
    AuthData Authenticate (1: Token token)
        throws (
            1: InvalidToken ex1
            2: AuthDataNotFound ex2
            3: AuthDataRevoked ex3
    )
    */

    /**
    * Аутентифицировать токен и получить (или вычислить) авторизационные данные.
    * Вычисление ContextFragment производится на основе данных об обстоятельствах, при которых токен поступил
    * в обработку, а значит корректность его результата не гарантирована.
    *
    * @deprecation Данный метод будет заменен на Authenticate (1: Token) после окончания фазы сбора информации о
    * существующих в системе токенах
    **/
    AuthData Authenticate (1: Token token, 2: TokenSourceContext source_context)
        throws (
            1: InvalidToken ex1
            2: AuthDataNotFound ex2
            3: AuthDataRevoked ex3
    )

    /**
    * Добавить авторизационные данные для существующего токена.
    * Метод предназначен для использования в тандеме с GetByToken для токенов, неизвестных до этого системе после
    * подтверждения корректности вычисленного для них авторизационных данных.
    *
    * @deprecation Данный метод будет удален после окончания фазы сбора информации о существующих в системе токенах
    **/
    AuthData AddExistingToken (1: AuthDataID id, 2: ContextFragment context, 3: Metadata metadata, 4: Authority authority)
        throws (
            1: AuthDataAlreadyExists ex1
    )

}

/**
 * Сервис, выступающий интерфейсом к одной эфемерной authority.
 * Authority ответственна за выпуск авторизационных данных и управление ими.
 **/
service EphemeralTokenAuthority {

    /**
    * Выпустить новые эфемерные авторизационные данные и токен.
    * Эфемерные авторизационные данные не имеют идентификатора, потому что с ними не связаны никакие данные на
    * стороне сервиса. Как следствие, эфемерные авторизационные данные невозможно отозвать. В связи с этим
    * клиентам рекомендуется обязательно задавать такие атрибуты, которые позволят контролировать
    * время жизни авторизационных данных.
    **/
    AuthData Create (1: ContextFragment context, 2: Metadata metadata)

}

/**
 * Сервис, выступающий интерфейсом к одной оффлайн authority.
 * Authority ответственна за выпуск авторизационных данных и управление ими.
 **/
service TokenAuthority {

    /**
    * Выпустить новые авторизационные данные и токен.
    **/
    AuthData Create (1: AuthDataID id, 2: ContextFragment context, 3: Metadata metadata)
        throws (
            1: AuthDataAlreadyExists ex1
    )

    /**
    * Получить авторизационные данные по идентификатору.
    **/
    AuthData Get (1: AuthDataID id)
        throws (
            1: AuthDataNotFound ex1
    )

    /**
    * Отозвать авторизационные данные по идентификатору.
    **/
    void Revoke (1: AuthDataID id)
        throws (
            1: AuthDataNotFound ex1
    )

}
