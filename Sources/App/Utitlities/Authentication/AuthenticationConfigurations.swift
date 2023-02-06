//
//  File.swift
//  
//
//  Created by Joe Maghzal on 04/02/2023.
//

import Vapor
import JWT

struct AuthConfigurations {
    static let esPublicKeyString = """
    -----BEGIN PUBLIC KEY-----
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwF/9knENDh7ew9y2BuyS
    YOSYBl7wzy/zcM92P/ttNpSoFaVSqyOwZuWB2hUZN7BRwvZbtoswbU8n/J6XxttE
    o75Mj6UsNKtNymiyrxkKUgCHN13gIPSinaKgodFpbnjR/rByNH6IFXveu5Ly+FAa
    qf3gcKt6dSNMA1BGvNsuyGpUScqEk65NNCsLLOhedQGvOKDhIZvZVjS+zABud3t/
    y9ayWWizDMGgpsBnAtKCzdy9F85jGTwKN4Z8FXGOB59xqji7/b74lRfFc0z0iFCV
    oW1J4CvKKgI20l/FMGHfPLwz2InoWRLpsocHH1Nzn1t9h/tdv/8UCqLGFvwX9Sss
    DQIDAQAB
    -----END PUBLIC KEY-----
    """
    static let esPrivateKeyString = """
    -----BEGIN PRIVATE KEY-----
    MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDAX/2ScQ0OHt7D
    3LYG7JJg5JgGXvDPL/Nwz3Y/+202lKgVpVKrI7Bm5YHaFRk3sFHC9lu2izBtTyf8
    npfG20SjvkyPpSw0q03KaLKvGQpSAIc3XeAg9KKdoqCh0WlueNH+sHI0fogVe967
    kvL4UBqp/eBwq3p1I0wDUEa82y7IalRJyoSTrk00Kwss6F51Aa84oOEhm9lWNL7M
    AG53e3/L1rJZaLMMwaCmwGcC0oLN3L0XzmMZPAo3hnwVcY4Hn3GqOLv9vviVF8Vz
    TPSIUJWhbUngK8oqAjbSX8UwYd88vDPYiehZEumyhwcfU3OfW32H+12//xQKosYW
    /Bf1KywNAgMBAAECggEADi8FoyZyr/fWtNoxEZGfuUUhcFbPqnb+m/Kv5UfEZaHQ
    QshNsBCRkQSa7llf4ps9bAJ+AJeCmoybhiSrTB4ekXQWcQDcoYV/1syhYAeYmzMu
    xQZG4CcpVjYHYebuvxZpZT3dLcGmhu77HRlYkLZXQPFW+vepr7lKgXQJwyLl8CDG
    Ga5NRv1aAdZo18HFKUhviJluQa38T06fpQBH3WSs5HglLUGT6XJh1nQybLUgMSOG
    hJA8fBHn8yioXhkE665+QuyIDT6DP+RHcbR8a33u8p301aFKLV0dcVb3cWtbLp82
    6so4tPPZG8/BrI4h2q5R1tO78oURpSGVoumdvhDcAQKBgQDj/JRY10mx344h5QAc
    InsEmqxeMJgFeuMIfLRFo9n/Etn44ArYcY/wW2b59RAdEJM7lazGsBEUjxtIMlVA
    oNS4QGYe8xiewghbZWvG59u1NIEv73hdTJy3yML21/lmdC8oECNqB9f3+oNYh9gQ
    TxNZoRnTI5qh2N/DSuXXAvL7JQKBgQDYAzrjZw/JJfflI74Jyi0xV/hi/RTjQig7
    NCz2FsfzhdwAZKoVXCHVH8w9iR71g3Ki/K/3TvmUwPgnqWULCISwA4dvmLZuQNwq
    KTiWvZOwFBRlMaXfX42cyc2BnBMJNVnkQmgA53PXdWztg/7c6bP68MIHvIzqBlve
    9NC1hPFMyQKBgA8LqyqVwppHe5THDRPOProWDwwEPvQVoQf9WtRBtPA9aT8gYfbY
    v7wH/CrAvnh8kIrdHNLb6bSmoRFJqRCjzIYAUfz25AgOHAkUD2HICVrTBTeJoTLf
    DHSgfiVWKXJWdoo5Tmz/6YPG94YPKPYikc9Xb2Hctqa5rkKwHazr1+c1AoGAaW4y
    KNmdn8yzUJiAYaDXK/VG23Gw5zbcEgFmTHpT/2z/MwXu6dv8+1u4wPQTMzuEET8J
    18gpEsyYkisgkSEIOiyOxw4fRHLNwpo574D5+3/hcH6p+ftWUAdDEZaOx/jNNhaf
    UomlRa0fjFHXbBV47erimQoTMQoHfyu4TlBjwdkCgYEA1Q200RBERj6tf0ggcoaJ
    fqO5wbcZsVtH/oD/03lkacX1tHefvmoS39Opa4ZDDpaJQQlB214Tf/tk2Y4DJFwG
    W5TjDtUPa5mYUUr5gKwxgRVvG7/xgm2w7xdgtMEo8doTNxSHZXm6cFsx6NpbxRyx
    KvNmCA+p/psYK6ADXDjgKOY=
    -----END PRIVATE KEY-----
    """
    static func esPublicSigner(app: Application) throws -> JWTSigner {
        return JWTSigner.es512(key: try ECDSAKey.generate())
    }
    static func esPrivateSigner(app: Application) throws -> JWTSigner {
        return try JWTSigner.es512(key: .private(pem: esPrivateKeyString))
    }
}

extension JWKIdentifier {
    static let publicES = JWKIdentifier(string: "publicES")
    static let privateES = JWKIdentifier(string: "privateES")
}
