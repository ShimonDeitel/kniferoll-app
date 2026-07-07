import XCTest
@testable import KnifeRoll

@MainActor
final class KnifeRollTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        XCTAssertLessThan(store.items.count, Store.freeTierLimit)
    }

    func testAddIncreasesCount() {
        let before = store.items.count
        store.add(KnifeItem(name: "Test", steelType: "A", sharpened: "B"))
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testDeleteRemovesItem() {
        let item = KnifeItem(name: "ToDelete", steelType: "A", sharpened: "B")
        store.add(item)
        store.delete(item)
        XCTAssertFalse(store.items.contains(item))
    }

    func testIsAtFreeLimitFalseInitially() {
        XCTAssertFalse(store.isAtFreeLimit)
    }

    func testIsAtFreeLimitTrueAfterFilling() {
        while store.items.count < Store.freeTierLimit {
            store.add(KnifeItem(name: "Filler \(store.items.count)", steelType: "A", sharpened: "B"))
        }
        XCTAssertTrue(store.isAtFreeLimit)
    }

    func testUpdateChangesFields() {
        var item = KnifeItem(name: "Orig", steelType: "A", sharpened: "B")
        store.add(item)
        item.name = "Changed"
        store.update(item)
        XCTAssertEqual(store.items.first(where: { $0.id == item.id })?.name, "Changed")
    }

    func testDeleteAtOffsets() {
        let before = store.items.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, before - 1)
    }

    func testPersistenceRoundTrip() {
        store.add(KnifeItem(name: "Persisted", steelType: "A", sharpened: "B"))
        let reloaded = Store()
        XCTAssertTrue(reloaded.items.contains(where: { $0.name == "Persisted" }))
    }
}
