
import UIKit

class DetailViewController: UIViewController {
    
    var productIndex: Int?
    var productID: Int?
    var productTitle: String?
    var productSelectedAmount = 0
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var producerLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var constraintDescriptionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var cartButtDetailView: CartButtDetail!
    @IBOutlet weak var cartCountView: CartCount!

    private var dataProvider: DetailDataProvider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingUI()
    }
    
    private func settingUI() {
        
        // Задаем заголовок страницы
        if let productTitle = productTitle {
            title = productTitle
        }
        
        // dataProvider
        dataProvider = DetailDataProvider()
        
        // TableView
        tableView.delegate = dataProvider
        tableView.dataSource = dataProvider
        
        // Запрос данных
        loadProduct()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
            super.viewWillTransition(to: size, with: coordinator)
        
            // Экран телефона повернули, наново вычисляем высоту описания
            // Асинхронно чтобы выполнилось после полного поворота экрана и перерисовки элементов, чтобы размеры были актуальными
            DispatchQueue.main.async() {
                self.setDescriptionHeight()
            }
        
        }
    
    func setCartButtons() {
        
        // Вывод корзины и кол-ва добавленых в корзину
        if productSelectedAmount > 0 {
            
            // Выводим переключатель кол-ва продукта в корзине
            cartButtDetailView.isHidden = true
            cartCountView.isHidden = false
            
            // Задаем текущее значение счетчика
            cartCountView.count = productSelectedAmount
            
            // Подписываемся на делегат
            cartCountView.delegate = self
            
        } else {
            // Выводим кнопку добавления в карзину
            cartButtDetailView.isHidden = false
            cartButtDetailView.delegate = self
            cartCountView.isHidden = true
        }
        
    }
    
    func setDescriptionHeight() {
        
        constraintDescriptionHeight.constant = 0.0
        if let text = descriptionLabel.text, !text.isEmpty {
            
            // Вычисляем необходимую высоту текста
            let size = CGSize(width: descriptionLabel.frame.width, height: CGFloat.infinity)
            let attributes = [NSAttributedString.Key.font: descriptionLabel.font]
            let needSize = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            // Задаем полученную высоту в констрейт
            constraintDescriptionHeight.constant = needSize.height + 5.0
            
        }
        
    }
    
    func changeDescription(text: String) {
        
        // Задаем описание
        if text.isEmpty {
            descriptionLabel.isHidden = true
            descriptionLabel.text = ""
        } else {
            descriptionLabel.isHidden = false
            descriptionLabel.text = text
        }
        
        // Вычисляем высоту описания
        setDescriptionHeight()
        
    }
    
    func loadProduct() {
        
        // Отправляем запрос загрузки товара
        guard let productID = productID else { return }
        ProductNetworking.getOneProduct(id: productID) { [weak self] (response) in
  
            // Проверяем что данные были успешно обработаны
            if let product = response.product {
            
                // Скрываем анимацию загрузки
                self?.loadIndicator.stopAnimating()
                
                // Задаем обновленный заголовок страницы
                self?.title = product.title

                // Выводим информацию
                self?.titleLabel.text = product.title
                self?.producerLabel.text = product.producer
                
                // Описание
                self?.changeDescription(text: product.shortDescription)
                
                // Убираем лишние нули после запятой, если они есть и выводим цену
                self?.priceLabel.text = String(format: "%g", product.price) + " ₽"
                
                // Загрузка изображения, если ссылка пуста, то выводится изображение по умолчанию
                self?.image.image = UIImage(named: "nophoto")
                if !product.imageUrl.isEmpty {
                    
                    // Загрузка изображения
                    guard let imageURL = URL(string: product.imageUrl) else { return }
                    ImageNetworking.networking.getImage(link: imageURL) { (img) in
                        DispatchQueue.main.async {
                            self?.image.image = img
                        }
                    }
                    
                }
                
                // Вывод корзины и кол-ва добавленых в корзину
                self?.setCartButtons()
                
                // Устанавливаем загруженные категории и обновляем таблицу
                self?.dataProvider.categoryList = product.categories
                self?.tableView.reloadData()
                
                // Отображаем данные
                self?.infoStackView.isHidden = false
                
            }
            
        }
        
    }
    
}

extension DetailViewController: CartCountDelegate {
    
    func changeCount(value: Int) {
        
        // Изменяем значение количества в структуре
        guard let productIndex = productIndex else { return }
        
        // Обновляем кнопку в отображении
        productSelectedAmount = value
        setCartButtons()
        
        // Обновляем значение в корзине в списке через наблюдатель
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationUpdateCartCount"), object: nil, userInfo: ["index": productIndex, "count": productSelectedAmount])
        
    }
    
}

extension DetailViewController: CartButtDetailDelegate {
    
    func addCart() {
        
        // Добавляем товар в карзину
        guard let productIndex = productIndex else { return }
        
        // Обновляем кнопку в отображении
        productSelectedAmount = 1
        setCartButtons()

        // Обновляем значение в корзине в списке через наблюдатель
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationUpdateCartCount"), object: nil, userInfo: ["index": productIndex, "count": productSelectedAmount])
        
    }
    
}
