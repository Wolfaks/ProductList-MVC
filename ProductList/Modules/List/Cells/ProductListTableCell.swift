
import UIKit

protocol ProductListCellDelegate: class {
    func changeCartCount(index: Int, value: Int, reload: Bool)
    func redirectToDetail(index: Int)
}

class ProductListTableCell: UITableViewCell {
    
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productProducer: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var stackFooterCell: UIStackView!

    lazy var cartBtnListView: CartBtnList = {
        let btnList = CartBtnList()
        btnList.translatesAutoresizingMaskIntoConstraints = false
        return btnList
    }()

    lazy var cartCountView: CartCount = {
        let cartCount = CartCount()
        cartCount.translatesAutoresizingMaskIntoConstraints = false
        return cartCount
    }()
    
    var productIndex: Int?
    weak var delegate: ProductListCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setBorder() {
        
        // Устанавливаем обводку
        borderView.layer.cornerRadius = 10.0
        borderView.layer.borderWidth = 1.0
        borderView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    func setCartButtons(count: Int) {
        
        // Вывод корзины и кол-ва добавленых в корзину
        if count > 0 {

            // Удаляем cartBtnListView
            stackFooterCell.removeArrangedSubview(cartBtnListView)
            cartBtnListView.removeFromSuperview()
            
            // Выводим переключатель кол-ва продукта в корзине
            stackFooterCell.addArrangedSubview(cartCountView)

            // Задаем текущее значение счетчика
            cartCountView.count = count

            // Подписываемся на делегат
            cartCountView.delegate = self

            // Constraints
            cartCountView.widthAnchor.constraint(equalToConstant: CartCount.widthSize).isActive = true
            cartCountView.heightAnchor.constraint(equalToConstant: CartCount.heightSize).isActive = true

        } else {

            // Удаляем cartCountView
            stackFooterCell.removeArrangedSubview(cartCountView)
            cartCountView.removeFromSuperview()

            // Выводим кнопку добавления в корзину
            stackFooterCell.addArrangedSubview(cartBtnListView)

            // Подписываемся на делегат
            cartBtnListView.delegate = self

            // Constraints
            cartBtnListView.widthAnchor.constraint(equalToConstant: CartBtnList.widthSize).isActive = true
            cartBtnListView.heightAnchor.constraint(equalToConstant: CartBtnList.heightSize).isActive = true

        }
        
    }
    
    @objc func detailTapped() {
        // Выполняем переход в детальную информацию
        guard let productIndex = productIndex else { return }
        delegate?.redirectToDetail(index: productIndex)
    }
    
    func setClicable() {
        
        // Клик на изображение для перехода в детальную информацию
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(detailTapped))
        productImage.isUserInteractionEnabled = true
        productImage.addGestureRecognizer(tapImageGesture)
        
        // Клик на название для перехода в детальную информацию
        let tapTitleGesture = UITapGestureRecognizer(target: self, action: #selector(detailTapped))
        productTitle.isUserInteractionEnabled = true
        productTitle.addGestureRecognizer(tapTitleGesture)
        
    }
    
    func set(product: Product) {
        
        // Устанавливаем обводку
        setBorder()
        
        // Заполняем данные
        productCategory.text = product.getFirstCategory()
        productTitle.text = product.title
        productProducer.text = product.producer
        
        // Убираем лишние нули после запятой, если они есть и выводим цену
        productPrice.text = String(format: "%g", product.price) + " ₽"

        // Загрузка изображения, если ссылка пуста, то выводится изображение по умолчанию
        productImage.image = UIImage(named: "nophoto")
        if !product.imageUrl.isEmpty {
            
            // Загрузка изображения
            guard let imageURL = URL(string: product.imageUrl) else { return }
            ImageNetworking.shared.getImage(link: imageURL) { (img) in
                DispatchQueue.main.async {
                    self.productImage.image = img
                }
            }
            
        }
        
        // Вывод корзины и кол-ва добавленых в корзину
        setCartButtons(count: product.selectedAmount)
        
        // Действия при клике
        setClicable()
        
    }
    
}

extension ProductListTableCell: CartCountDelegate {
    
    func changeCount(value: Int) {
        // Изменяем значение количества в структуре
        guard let productIndex = productIndex else { return }
        setCartButtons(count: value)
        delegate?.changeCartCount(index: productIndex, value: value, reload: false)
    }
    
}

extension ProductListTableCell: CartBtnListDelegate {
    func addCart() {
        // Добавляем товар в карзину
        guard let productIndex = productIndex else { return }
        setCartButtons(count: 1)
        delegate?.changeCartCount(index: productIndex, value: 1, reload: false)
    }
}
