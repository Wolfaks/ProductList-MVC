
import UIKit

protocol CartButtDetailDelegate: class {
    func addCart()
}

@IBDesignable class CartButtDetail: UIView, CartButtProtocol {
    
    @IBOutlet weak var radiusView: UIView!
    weak var delegate: CartButtDetailDelegate?
    
    var view: UIView!
    var nibName: String = "CartButtDetail"
    
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addCartTapped))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func addCartTapped() {
        // Добавляем товар в карзину
        delegate?.addCart()
    }
    
}
