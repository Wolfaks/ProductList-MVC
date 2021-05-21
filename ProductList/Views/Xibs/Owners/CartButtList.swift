
import UIKit

protocol CartButtListDelegate: class {
    func addCart()
}

@IBDesignable class CartButtList: UIView, CartButtProtocol {
    
    @IBOutlet weak var radiusView: UIView!
    @IBOutlet weak var cartButton: UIButton!
    weak var delegate: CartButtListDelegate?
    
    var view: UIView!
    var nibName: String = "CartButtList"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func loadFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
        
    }
    
    func setupView() {
        
        let view = loadFromNib()
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(view)
        
        // Закругляем углы кнопки
        radiusView.layer.cornerRadius = 5.0
        
        // Клик на добавление в карзину
        cartButton.addTarget(self, action: #selector(addCartTapped), for: .touchUpInside)
        
    }
    
    @objc func addCartTapped() {
        // Добавляем товар в карзину
        delegate?.addCart()
    }
    
}
