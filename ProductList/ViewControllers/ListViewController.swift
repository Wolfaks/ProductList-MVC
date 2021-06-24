
import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var searchForm: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    private var dataProvider: ListDataProvider!

    // Поиск
    var searchText = ""
    private let searchOperationQueue = OperationQueue()

    // Страницы
    var page = 1
    var haveNextPage = false
    
    // Переход в детальную информацию
    private var productIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingUI()
    }
    
    private func settingUI() {
        
        // dataProvider
        dataProvider = ListDataProvider()
        dataProvider.delegate = self
        
        // searchForm
        searchForm.delegate = self
        searchForm.addTarget(self, action: #selector(changeSearchText), for: .editingChanged) // добавляем отслеживание изменения текста
        
        // TableView
        tableView.delegate = dataProvider
        tableView.dataSource = dataProvider
        tableView.rowHeight = 160.0

        // Наблюдатель изменения товаров в корзине
        NotificationCenter.default.addObserver(self, selector: #selector(updateCartCount), name: Notification.Name(rawValue: "notificationUpdateCartCount"), object: nil)

        // Наблюдатель перехода в детальную информацию
        NotificationCenter.default.addObserver(self, selector: #selector(showDetail), name: Notification.Name(rawValue: "notificationRedirectToDetail"), object: nil)
        
        // Запрос данных
        loadProducts()
        
    }

    @objc func updateCartCount(notification: Notification) {

        // Изменяем кол-во товара в корзине
        guard let userInfo = notification.userInfo, let index = userInfo["index"] as? Int, let newCount = userInfo["count"] as? Int, !dataProvider.productList.isEmpty && dataProvider.productList.indices.contains(index) else { return }

        // Записываем новое значение
        dataProvider.productList[index].selectedAmount = newCount

        // Обновляем tableView
        tableView.reloadData()

    }

    @objc func showDetail(notification: Notification) {

        // Выполняем переход в детальную информацию
        guard let userInfo = notification.userInfo, let index = userInfo["index"] as? Int else { return }

        productIndex = index
        performSegue(withIdentifier: "detail", sender: self)

    }
    
    @IBAction func removeSearch(_ sender: Any) {
        
        // Очищаем форму поиска
        searchForm.text = ""
        
        // Скрываем клавиатуру
        hideKeyboard()
        
        // Вызываем метод поиска
        changeSearchText(textField: searchForm)
        
    }
    
    func hideKeyboard() {
        view.endEditing(true);
    }
    
    @objc func changeSearchText(textField: UITextField) {

        // Проверяем измененный в форме текст
        guard let newSearchText = textField.text else { return }
        
        // Выполняем поиск когда форма была изменена
        if newSearchText.hash == searchText.hash {
            return
        }

        // Получаем искомую строку
        searchText = newSearchText

        // Очищаем старые данные и обновляем таблицу
        removeOldProducts()

        // Поиск с задержкой (по ТЗ)
        let operationSearch = BlockOperation()
        operationSearch.addExecutionBlock { [weak operationSearch] in

            // Задержка (по ТЗ)
            sleep(2)

            if !(operationSearch?.isCancelled ?? false) {

                // Выполняем поиск
                // Задаем первую страницу
                self.page = 1

                // Запрос данных
                self.loadProducts()

            }

        }
        searchOperationQueue.cancelAllOperations()
        searchOperationQueue.addOperation(operationSearch)
        
    }
    
    func removeOldProducts() {
        
        // Очищаем старые данные и обновляем таблицу
        dataProvider.productList.removeAll()
        tableView.reloadData()
        
        // Отображаем анимацию загрузки
        loadIndicator.startAnimating()
        
    }
    
    func loadProducts() {
        
        // Отправляем запрос загрузки товаров
        ProductNetworking.getProducts(page: page, searchText: searchText) { [weak self] (response) in
            
            // Скрываем анимацию загрузки
            if self?.page == 1 {
                self?.loadIndicator.stopAnimating()
            }

            // Обрабатываем полученные товары
            var products = response.products

            // Так как API не позвращает отдельный ключ, который говорит о том, что есть следующая страница, определяем это вручную
            if !products.isEmpty && products.count == ProductNetworking.maxProductsOnPage {

                // Задаем наличие следующей страницы
                self?.haveNextPage = true

                // Удаляем последний элемент, который используется только для проверки на наличие следующей страницы
                products.remove(at: products.count - 1)

            }

            // Устанавливаем загруженные товары и обновляем таблицу
            // append contentsOf так как у нас метод грузит как первую страницу, так и последующие
            self?.dataProvider.productList.append(contentsOf: products)
            self?.tableView.reloadData()
            
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "detail" {
            
            if let index = productIndex, !dataProvider.productList.isEmpty && dataProvider.productList.indices.contains(index) {
            
                // Переход в детальную информацию
                guard let detailController = segue.destination as? DetailViewController else { return }
                detailController.productIndex = index
                detailController.productID = dataProvider.productList[index].id
                detailController.productTitle = dataProvider.productList[index].title
                detailController.productSelectedAmount = dataProvider.productList[index].selectedAmount

            }
            
        }
        
    }
    
}

extension ListViewController: ListDataProviderProtocol {
    
   
    func nextPage() {
        // Загружаем следующую страницу, если она есть
        if haveNextPage {

            // Задаем новую страницу
            haveNextPage = false
            page += 1

            // Запрос данных
            loadProducts()

        }
    }
    
}

extension ListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == searchForm {
            // Скрываем клавиатуру при нажатии на клавишу Done / Готово
            hideKeyboard()
        }
        
        return true
        
    }
    
}
