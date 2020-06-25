/**
 * Репозиторий атрибутов для принятия решений по контролю доступа.
 */

namespace java com.rbkmoney.token.attributes
namespace erlang token_attr

struct Attribute {

    /**
     * Идентификатор атрибута.
     *
     * Можно представить в виде строки, например:
     *  - 'auth.method.id'
     *  - 'capi.operation.invoice.id'
     *  - 'capi.requester.ip.v4'
     *  - 'user.realm'
     *  - 'org.member.role'
     */
    1: required AttributeID id

    2: required Value value

}

/** Значение атрибута */
union Value {
    1: string str
}

/** Иерархия идентификаторов атрибутов */
union AttributeID {
    1: Auth         auth
    2: CommonAPI    capi
    3: User         user
    4: Organisation org
    5: Environment  env
}

union Auth {
    1: AuthMethod method
    // Любопытно, что ответ на вопрос «что делать с протухшим токеном?» можно
    // кажется переложить на вычислитель политик, как и всё остальное. Вопрос
    // в том, корректно ли будет туда переносить эту ответственность? У меня
    // складывается ощущение, что да.
    2: Expiration expiration
}

union AuthMethod {
    1: AuthMethodID id
}

union CommonAPI {
    1: Operation operation
    2: Requester requester
}

union Operation {
    1: OperationID id
    2: Invoice invoice
    3: Payment payment
    4: Shop shop
    5: Contract contract
    6: Party party
}

union Invoice {
    1: InvoiceID id
}

union Payment {
    1: PaymentID id
}

union Shop {
    1: ShopID id
}

union Contract {
    1: ContractID id
    2: ContractRealm realm
}

union Requester {
    1: IPAddress ip
}

struct OperationID {}

union Party {
    1: PartyID id
    2: UserID  owner
}

union Organisation {
    1: Member member
}

union User {
    1: UserID    id
    2: EMail     email
    3: UserRealm realm
}

union Member {
    1: OrganisationRole role
}

union OrganisationRole {
    1: RoleID id
}

union Environment {
    1: DateTime datetime
}

union IPAddress {
    1: IPv4Address v4
    2: IPv6Address v6
}

struct AuthMethodID {}
struct Expiration {}
struct PartyID {}
struct InvoiceID {}
struct PaymentID {}
struct ShopID {}
struct ContractID {}
struct ContractRealm {}
struct UserID {}
struct UserRealm {}
struct EMail {}
struct RoleID {}
struct DateTime {}
struct IPv4Address {}
struct IPv6Address {}
