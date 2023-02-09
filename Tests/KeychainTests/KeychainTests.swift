import XCTest
@testable import Keychain

final class KeychainTests: XCTestCase {

    var keychain: Keychain!

    override func setUpWithError() throws {
        try super.setUpWithError()
        keychain = Keychain(service: "UnitTest")
    }

    override func tearDownWithError() throws {
        try keychain.removeAll()
        try super.tearDownWithError()
    }

    func testGetStringQuery() {
        let expectedQuery: [String: Any] = [
            "acct": "ShogunAccountManager-accesstoken",
            "svce": "UnitTest",
            "m_Limit": "m_LimitOne",
            "class": "genp",
            "sync": "syna",
            "r_Data": 1
        ]
        let keychainQuery = keychain.makeGetQueryFor(key: "ShogunAccountManager-accesstoken")
        XCTAssertEqual(NSDictionary(dictionary: expectedQuery),
                       NSDictionary(dictionary: keychainQuery))
    }

    func testGetStringBeforeItsSet() throws {
        XCTAssertNil(try keychain.getString("non-existing"))
    }

    func testSetValueAndGetValue() throws {
        try keychain.set("some-value", key: "some-key")
        let savedValue = try keychain.getString("some-key")

        XCTAssertEqual(savedValue, "some-value")
    }

    func testUpdateValue() throws {
        try keychain.set("some-value", key: "some-key")
        XCTAssertNoThrow(try keychain.update("other-value", key: "some-key"))
    }

    func testRemoveWithKey() throws {
        try keychain.set("some-value", key: "a-key")
        XCTAssertEqual("some-value", try keychain.getString("a-key"))

        try keychain.remove("a-key")
        XCTAssertNil(try keychain.getString("a-key"))
    }
}
