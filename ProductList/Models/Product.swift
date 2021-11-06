
import UIKit

struct Products: Decodable {
    var data: [ProductData]?
}

struct Product: Decodable {
    var data: ProductData?
}

struct ProductData: Decodable {
    let id: Int
    let title: String
    let shortDescription: String
    let imageUrl: String
    let amount: Int
    let price: Double
    let producer: String
    
    var selectedAmount = 0
    var categories: [Category]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case shortDescription = "shortDescription"
        case imageUrl = "imageUrl"
        case amount = "amount"
        case price = "price"
        case producer = "producer"
        case categories = "categories"
    }
    
    func getFirstCategory() -> String {
        var category = "Нет категории"
        if let categories = categories, !categories.isEmpty, let firstCategory = categories.first {
            category = firstCategory.title
        }
        return category
    }
}
