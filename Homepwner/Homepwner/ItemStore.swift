import Foundation

let sharedStorage = ItemStore()

class ItemStore {
    class var sharedStore: ItemStore { return sharedStorage }
    var privateItems = Item[]()
    var allItems: Item[] { return privateItems }

    init () {
        NSException(name: "Singleton", reason: "Use ItemStore.sharedStore", userInfo: nil)
    }

    func createItem() -> Item {
        let item = Item.randomItem()
        privateItems.append(item)

        return item
    }

    func removeItem(item: Item) {
        if let imageKey = item.itemKey {
            ImageStore.sharedStore.dictionary.removeValueForKey(imageKey)
        }

        let indexOfItem = privateItems.indexOf() { $0 == item }
        if let index = indexOfItem {
            privateItems.removeAtIndex(index)
            println("Removed item at index \(index)")
        }
        println(privateItems)
        println(allItems)
    }

    func moveItem(from fromIndex: Int, to toIndex: Int) {
        if fromIndex == toIndex {
            return
        }
        let item = privateItems[fromIndex]
        println("Moving item from row:\(fromIndex) to row:\(toIndex)")
        privateItems.removeAtIndex(fromIndex)
        privateItems.insert(item, atIndex: toIndex)
    }
}