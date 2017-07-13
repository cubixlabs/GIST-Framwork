import UIKit

@objc public protocol AnimatedTextInputDelegate: class {
    @objc optional func animatedTextInputDidBeginEditing(animatedTextInput: AnimatedTextInput)
    @objc optional func animatedTextInputDidEndEditing(animatedTextInput: AnimatedTextInput)
    @objc optional func animatedTextInputDidChange(animatedTextInput: AnimatedTextInput)
    @objc optional func animatedTextInput(animatedTextInput: AnimatedTextInput, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    @objc optional func animatedTextInputShouldBeginEditing(animatedTextInput: AnimatedTextInput) -> Bool
    @objc optional func animatedTextInputShouldEndEditing(animatedTextInput: AnimatedTextInput) -> Bool
    @objc optional func animatedTextInputShouldReturn(animatedTextInput: AnimatedTextInput) -> Bool
}

open class AnimatedTextInput: UIControl, BaseView, TextInputDelegate {

    //MARK: - Properties
    
    private var _placeholder:String? = "Placeholder";
    @IBInspectable open var placeholder:String? {
        set {
            if let key:String = newValue , key.hasPrefix("#") == true {
                _placeholder = SyncedText.text(forKey: key);
            } else {
                _placeholder = newValue;
            }
            
            placeholderLayer.string = _placeholder
        }
        
        get {
            return _placeholder;
        }
    }
    
    @IBInspectable open var multilined:Bool = false {
        didSet {
            self.type = (multilined) ? .multiline:.standard;
        }
    }
    
    /// Max Character Count Limit for the text field.
    @IBInspectable open var maxCharLimit: Int = 255;
    
    
    /// Background color key from Sync Engine.
    @IBInspectable open var bgColorStyle:String? = nil {
        didSet {
            self.backgroundColor = SyncedColors.color(forKey: bgColorStyle);
        }
    }
    
    /// Width of View Border.
    @IBInspectable open var border:Int = 0 {
        didSet {
            if let borderCStyle:String = borderColorStyle {
                self.addBorder(SyncedColors.color(forKey: borderCStyle), width: border)
            }
        }
    }
    
    /// Border color key from Sync Engine.
    @IBInspectable open var borderColorStyle:String? = nil {
        didSet {
            if let borderCStyle:String = borderColorStyle {
                self.addBorder(SyncedColors.color(forKey: borderCStyle), width: border)
            }
        }
    }
    
    /// Corner Radius for View.
    @IBInspectable open var cornerRadius:Int = 0 {
        didSet {
            self.addRoundedCorners(GISTUtility.convertToRatio(CGFloat(cornerRadius), sizedForIPad: iStyle.sizeForIPad));
        }
    }
    
    /// Flag for making circle/rounded view.
    @IBInspectable open var rounded:Bool = false {
        didSet {
            if rounded {
                self.addRoundedCorners();
            }
        }
    }
    
    /// Flag for Drop Shadow.
    @IBInspectable open var hasDropShadow:Bool = false {
        didSet {
            if (hasDropShadow) {
                self.addDropShadow();
            } else {
                // TO HANDLER
            }
        }
    }
    
    typealias AnimatedTextInputType = AnimatedTextInputFieldConfigurator.AnimatedTextInputType

    private var _tapAction: ((Void) -> Void)?
    
    open  weak var delegate: AnimatedTextInputDelegate?
    open fileprivate(set) var isActive = false

    var type: AnimatedTextInputType = .standard {
        didSet {
            configureType()
        }
    }

    open var returnKeyType: UIReturnKeyType = .default {
        didSet {
            textInput.changeReturnKeyType(with: returnKeyType)
        }
    }
    
    open var clearButtonMode: UITextFieldViewMode = .whileEditing {
        didSet {
            textInput.changeClearButtonMode(with: clearButtonMode)
        }
    }

    open var placeholderAlignment: CATextLayer.Alignment = .natural {
        didSet {
            placeholderLayer.alignmentMode = String(describing: placeholderAlignment)
        }
    }

    //External GIST Style
    open var style: AnimatedTextInputStyle? {
        didSet {
            //Externel Style
            self.iStyle = InternalAnimatedTextInputStyle(style);
        }
    }
    
    //Internal Style
    var iStyle: InternalAnimatedTextInputStyle = InternalAnimatedTextInputStyle(nil) {
        didSet {
            configureStyle()
        }
    }

    open var text: String? {
        get {
            return textInput.currentText
        }
        set {
            if !textInput.view.isFirstResponder {
                (newValue != nil) ? configurePlaceholderAsInactiveHint() : configurePlaceholderAsDefault()
            }
            textInput.currentText = newValue
        }
    }

    open var selectedTextRange: UITextRange? {
        get { return textInput.currentSelectedTextRange }
        set { textInput.currentSelectedTextRange = newValue }
    }

    open var beginningOfDocument: UITextPosition? {
        get { return textInput.currentBeginningOfDocument }
    }

    open var font: UIFont? {
        get { return textInput.font }
        set { textAttributes = [NSFontAttributeName: newValue as Any] }
    }

    open var textColor: UIColor? {
        get { return textInput.textColor }
        set { textAttributes = [NSForegroundColorAttributeName: newValue as Any] }
    }

    open var lineSpacing: CGFloat? {
        get {
            guard let paragraph = textAttributes?[NSParagraphStyleAttributeName] as? NSParagraphStyle else { return nil }
            return paragraph.lineSpacing
        }
        set {
            guard let spacing = newValue else { return }
            let paragraphStyle = textAttributes?[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = spacing
            textAttributes = [NSParagraphStyleAttributeName: paragraphStyle]
        }
    }

    open var textAlignment: NSTextAlignment? {
        get {
            guard let paragraph = textInput.textAttributes?[NSParagraphStyleAttributeName] as? NSParagraphStyle else { return nil }
            return paragraph.alignment
        }
        set {
            guard let alignment = newValue else { return }
            let paragraphStyle = textAttributes?[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
            paragraphStyle.alignment = alignment
            textAttributes = [NSParagraphStyleAttributeName: paragraphStyle]
        }
    }

    open var tailIndent: CGFloat? {
        get {
            guard let paragraph = textAttributes?[NSParagraphStyleAttributeName] as? NSParagraphStyle else { return nil }
            return paragraph.tailIndent
        }
        set {
            guard let indent = newValue else { return }
            let paragraphStyle = textAttributes?[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
            paragraphStyle.tailIndent = indent
            textAttributes = [NSParagraphStyleAttributeName: paragraphStyle]
        }
    }

    open var headIndent: CGFloat? {
        get {
            guard let paragraph = textAttributes?[NSParagraphStyleAttributeName] as? NSParagraphStyle else { return nil }
            return paragraph.headIndent
        }
        set {
            guard let indent = newValue else { return }
            let paragraphStyle = textAttributes?[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
            paragraphStyle.headIndent = indent
            textAttributes = [NSParagraphStyleAttributeName: paragraphStyle]
        }
    }

    open var textAttributes: [String: Any]? {
        didSet {
            guard var textInputAttributes = textInput.textAttributes else {
                textInput.textAttributes = textAttributes
                return
            }
            guard textAttributes != nil else {
                textInput.textAttributes = nil
                return
            }
            textInput.textAttributes = textInputAttributes.merge(dict: textAttributes!)
        }
    }

    private var _inputAccessoryView: UIView?

    open override var inputAccessoryView: UIView? {
        set {
            _inputAccessoryView = newValue
        }

        get {
            return _inputAccessoryView
        }
    }

    open var contentInset: UIEdgeInsets? {
        didSet {
            guard let insets = contentInset else { return }
            textInput.contentInset = insets
        }
    }

    fileprivate let lineView = AnimatedLine()
    fileprivate let placeholderLayer = CATextLayer()
    fileprivate let counterLabel = UILabel()
    fileprivate let lineWidth: CGFloat = GIST_CONFIG.seperatorWidth;
    fileprivate let counterLabelRightMargin: CGFloat = 15
    fileprivate let counterLabelTopMargin: CGFloat = 5

    fileprivate var isResigningResponder = false
    fileprivate var isPlaceholderAsHint = false
    fileprivate var hasCounterLabel = false
    fileprivate var textInput: TextInput!
    fileprivate var lineToBottomConstraint: NSLayoutConstraint!
    fileprivate var textInputTrailingConstraint: NSLayoutConstraint!
    fileprivate var disclosureViewWidthConstraint: NSLayoutConstraint!
    fileprivate var disclosureView: UIView?
    fileprivate var placeholderErrorText: String?

    fileprivate var placeholderPosition: CGPoint {
        let hintPosition = CGPoint(
            x: placeholderAlignment != .natural ? 0 : iStyle.leftMargin,
            y: iStyle.yHintPositionOffset
        )
        let defaultPosition = CGPoint(
            x: placeholderAlignment != .natural ? 0 : iStyle.leftMargin,
            y: iStyle.topMargin + iStyle.yPlaceholderPositionOffset
        )
        return isPlaceholderAsHint ? hintPosition : defaultPosition
    }
    
    private var _data:Any?
    
    /// Holds Data.
    open var data:Any? {
        get {
            return _data;
        }
    } //P.E.

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setupCommonElements()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupCommonElements()
    }
    
    //MARK: - Methods
    
    open func updateData(_ data: Any?) {
        _data = data;
        
        let dicData:NSMutableDictionary? = data as? NSMutableDictionary;
        
        self.maxCharLimit = dicData?["maxCharLimit"] as? Int ?? (self.multilined ? 255 : 50);
        
        //Set the text and placeholder
        self.text = dicData?["text"] as? String;
        self.placeholder = dicData?["placeholder"] as? String;
    } //F.E.

    override open var intrinsicContentSize: CGSize {
        let normalHeight = textInput.view.intrinsicContentSize.height
        return CGSize(width: UIViewNoIntrinsicMetric, height: normalHeight + iStyle.topMargin + iStyle.bottomMargin)
    }

    open override func updateConstraints() {
        addLineViewConstraints()
        addTextInputConstraints()
        addCharacterCounterConstraints()
        super.updateConstraints()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutPlaceholderLayer()
        
        if rounded {
            self.addRoundedCorners();
        }
        
        if (hasDropShadow) {
            self.addDropShadow();
        }
    }

    fileprivate func layoutPlaceholderLayer() {
        // Some letters like 'g' or 'á' were not rendered properly, the frame need to be about 20% higher than the font size
        let frameHeightCorrectionFactor: CGFloat = 1.2
        placeholderLayer.frame = CGRect(origin: placeholderPosition, size: CGSize(width: bounds.width, height: iStyle.textInputFont.pointSize * frameHeightCorrectionFactor))
    }

    // mark: Configuration

    fileprivate func addLineViewConstraints() {
        removeConstraints(constraints)
        pinLeading(toLeadingOf: lineView, constant: iStyle.leftMargin)
        pinTrailing(toTrailingOf: lineView, constant: iStyle.rightMargin)
        lineView.setHeight(to: lineWidth)
        let constant = hasCounterLabel ? -counterLabel.intrinsicContentSize.height - counterLabelTopMargin : 0
        lineToBottomConstraint = pinBottom(toBottomOf: lineView, constant: constant)
    }

    fileprivate func addTextInputConstraints() {
        pinLeading(toLeadingOf: textInput.view, constant: iStyle.leftMargin)
        if disclosureView == nil {
            textInputTrailingConstraint = pinTrailing(toTrailingOf: textInput.view, constant: iStyle.rightMargin)
        }
        pinTop(toTopOf: textInput.view, constant: iStyle.topMargin)
        textInput.view.pinBottom(toTopOf: lineView, constant: iStyle.bottomMargin)
    }

    fileprivate func setupCommonElements() {
        addLine()
        addPlaceHolder()
        addTapGestureRecognizer()
        addTextInput()
    }

    fileprivate func addLine() {
        lineView.defaultColor = iStyle.lineInactiveColor
        lineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineView)
    }

    fileprivate func addPlaceHolder() {
        placeholderLayer.masksToBounds = false
        placeholderLayer.string = placeholder
        placeholderLayer.foregroundColor = iStyle.inactiveColor.cgColor
        placeholderLayer.fontSize = iStyle.textInputFont.pointSize
        placeholderLayer.font = iStyle.textInputFont
        placeholderLayer.contentsScale = UIScreen.main.scale
        placeholderLayer.backgroundColor = UIColor.clear.cgColor
        layoutPlaceholderLayer()
        layer.addSublayer(placeholderLayer)
    }

    fileprivate func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        addGestureRecognizer(tap)
    }

    fileprivate func addTextInput() {
        textInput = AnimatedTextInputFieldConfigurator.configure(with: type)
        textInput.textInputDelegate = self
        textInput.view.tintColor = iStyle.activeColor
        textInput.textColor = iStyle.textInputFontColor
        textInput.font = iStyle.textInputFont
        textInput.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textInput.view)
        invalidateIntrinsicContentSize()
    }

    fileprivate func updateCounter() {
        guard let counterText = counterLabel.text else { return }
        let components = counterText.components(separatedBy: "/")
        let characters = (text != nil) ? text!.characters.count : 0
        counterLabel.text = "\(characters)/\(components[1])"
    }

    // mark: States and animations

    fileprivate func configurePlaceholderAsActiveHint() {
        isPlaceholderAsHint = true
        configurePlaceholderWith(fontSize: iStyle.placeholderMinFontSize,
                                 foregroundColor: iStyle.activeColor.cgColor,
                                 text: placeholder)
        lineView.fillLine(with: iStyle.activeColor)
    }

    fileprivate func configurePlaceholderAsInactiveHint() {
        isPlaceholderAsHint = true
        configurePlaceholderWith(fontSize: iStyle.placeholderMinFontSize,
                                 foregroundColor: iStyle.inactiveColor.cgColor,
                                 text: placeholder)
        lineView.animateToInitialState()
    }

    fileprivate func configurePlaceholderAsDefault() {
        isPlaceholderAsHint = false
        configurePlaceholderWith(fontSize: iStyle.textInputFont.pointSize,
                                 foregroundColor: iStyle.inactiveColor.cgColor,
                                 text: placeholder)
        lineView.animateToInitialState()
    }

    fileprivate func configurePlaceholderAsErrorHint() {
        isPlaceholderAsHint = true
        configurePlaceholderWith(fontSize: iStyle.placeholderMinFontSize,
                                 foregroundColor: iStyle.errorColor.cgColor,
                                 text: placeholderErrorText)
        lineView.fillLine(with: iStyle.errorColor)
    }

    fileprivate func configurePlaceholderWith(fontSize: CGFloat, foregroundColor: CGColor, text: String?) {
        placeholderLayer.fontSize = fontSize
        placeholderLayer.foregroundColor = foregroundColor
        placeholderLayer.string = text
        layoutPlaceholderLayer()
    }

    fileprivate func animatePlaceholder(to applyConfiguration: (Void) -> Void) {
        let duration = 0.2
        let function = CAMediaTimingFunction(controlPoints: 0.3, 0.0, 0.5, 0.95)
        transactionAnimation(with: duration, timingFuncion: function, animations: applyConfiguration)
    }

    // mark: Behaviours

    public func onTap(action: @escaping (Void) -> Void) {
        _tapAction = action;
    } //F.E.
    
    @objc fileprivate func viewWasTapped(sender: UIGestureRecognizer) {
        if let tapAction = _tapAction {
            tapAction()
        } else {
            becomeFirstResponder()
        }
    }

    fileprivate func styleDidChange() {
        lineView.defaultColor = iStyle.lineInactiveColor
        placeholderLayer.foregroundColor = iStyle.inactiveColor.cgColor
        let fontSize = iStyle.textInputFont.pointSize
        placeholderLayer.fontSize = fontSize
        placeholderLayer.font = iStyle.textInputFont
        textInput.view.tintColor = iStyle.activeColor
        textInput.textColor = iStyle.textInputFontColor
        textInput.font = iStyle.textInputFont
        invalidateIntrinsicContentSize()
        layoutIfNeeded()
    }

    @discardableResult override open func becomeFirstResponder() -> Bool {
        isActive = true
        let firstResponder = textInput.view.becomeFirstResponder()
        counterLabel.textColor = iStyle.activeColor
        placeholderErrorText = nil
        animatePlaceholder(to: configurePlaceholderAsActiveHint)
        return firstResponder
    }

    override open var isFirstResponder: Bool {
        return textInput.view.isFirstResponder
    }

    @discardableResult override open func resignFirstResponder() -> Bool {
        guard !isResigningResponder else { return true }
        isActive = false
        isResigningResponder = true
        let resignFirstResponder = textInput.view.resignFirstResponder()
        isResigningResponder = false
        counterLabel.textColor = iStyle.inactiveColor

        if let textInputError = textInput as? TextInputError {
            textInputError.removeErrorHintMessage()
        }

        // If the placeholder is showing an error we want to keep this state. Otherwise revert to inactive state.
        if placeholderErrorText == nil {
            animateToInactiveState()
        }
        return resignFirstResponder
    }

    fileprivate func animateToInactiveState() {
        guard let text = textInput.currentText, !text.isEmpty else {
            animatePlaceholder(to: configurePlaceholderAsDefault)
            return
        }
        animatePlaceholder(to: configurePlaceholderAsInactiveHint)
    }

    override open var canResignFirstResponder: Bool {
        return textInput.view.canResignFirstResponder
    }

    override open var canBecomeFirstResponder: Bool {
        guard !isResigningResponder else { return false }
        if let disclosureView = disclosureView, disclosureView.isFirstResponder {
            return false
        }
        return textInput.view.canBecomeFirstResponder
    }

    open func show(error errorMessage: String, placeholderText: String? = nil) {
        placeholderErrorText = errorMessage
        if let textInput = textInput as? TextInputError {
            textInput.configureErrorState(with: placeholderText)
        }
        animatePlaceholder(to: configurePlaceholderAsErrorHint)
    }

    open func clearError() {
        placeholderErrorText = nil
        if let textInputError = textInput as? TextInputError {
            textInputError.removeErrorHintMessage()
        }
        if isActive {
            animatePlaceholder(to: configurePlaceholderAsActiveHint)
        } else {
            animateToInactiveState()
        }
    }

    fileprivate func configureType() {
        textInput.view.removeFromSuperview()
        addTextInput()
    }
    
    open func applyStyle() {
        self.configureStyle();
    } //F.E.

    fileprivate func configureStyle() {
        styleDidChange()
        if isActive {
            configurePlaceholderAsActiveHint()
        } else {
            isPlaceholderAsHint ? configurePlaceholderAsInactiveHint() : configurePlaceholderAsDefault()
        }
    }

    open func showCharacterCounterLabel(with maximum: Int? = nil) {
        hasCounterLabel = true
        let characters = (text != nil) ? text!.characters.count : 0
        if let maximumValue = maximum {
            counterLabel.text = "\(characters)/\(maximumValue)"
        } else {
            counterLabel.text = "\(characters)"
        }
        
        counterLabel.textColor = isActive ? iStyle.activeColor : iStyle.inactiveColor
        counterLabel.font = iStyle.counterLabelFont
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(counterLabel)
        invalidateIntrinsicContentSize()
    }

    fileprivate func addCharacterCounterConstraints() {
        guard hasCounterLabel else { return }
        lineToBottomConstraint.constant = -counterLabel.intrinsicContentSize.height - counterLabelTopMargin
        lineView.pinBottom(toTopOf: counterLabel, constant: counterLabelTopMargin)
        pinTrailing(toTrailingOf: counterLabel, constant: counterLabelRightMargin)
    }

    open func removeCharacterCounterLabel() {
        hasCounterLabel = false
        counterLabel.removeConstraints(counterLabel.constraints)
        counterLabel.removeFromSuperview()
        lineToBottomConstraint.constant = 0
        invalidateIntrinsicContentSize()
    }

    open func addDisclosureView(disclosureView: UIView) {
        if let constraint = textInputTrailingConstraint {
            removeConstraint(constraint)
        }
        self.disclosureView?.removeFromSuperview()
        self.disclosureView = disclosureView
        addSubview(disclosureView)
        textInputTrailingConstraint = textInput.view.pinTrailing(toLeadingOf: disclosureView, constant: 0)
        disclosureView.alignHorizontalAxis(toSameAxisOfView: textInput.view)
        disclosureView.pinBottom(toBottomOf: self, constant: 12)
        disclosureView.pinTrailing(toTrailingOf: self, constant: 16)
    }

    open func removeDisclosureView() {
        guard disclosureView != nil else { return }
        disclosureView?.removeFromSuperview()
        disclosureView = nil
        textInput.view.removeConstraint(textInputTrailingConstraint)
        textInputTrailingConstraint = pinTrailing(toTrailingOf: textInput.view, constant: iStyle.rightMargin)
    }

    open func position(from: UITextPosition, offset: Int) -> UITextPosition? {
        return textInput.currentPosition(from: from, offset: offset)
    }
    
    //MARK: - Methods
    
    /// Updates layout and contents from SyncEngine. this is a protocol method BaseView that is called when the view is refreshed.
    func updateView(){
        if let bgCStyle:String = self.bgColorStyle {
            self.bgColorStyle = bgCStyle;
        }
        
        if let borderCStyle:String = self.borderColorStyle {
            self.borderColorStyle = borderCStyle;
        }
    } //F.E.

    open func textInputDidBeginEditing(textInput: TextInput) {
        becomeFirstResponder()
        delegate?.animatedTextInputDidBeginEditing?(animatedTextInput: self)
    }

    open func textInputDidEndEditing(textInput: TextInput) {
        resignFirstResponder()
        delegate?.animatedTextInputDidEndEditing?(animatedTextInput: self)
    }

    open func textInputDidChange(textInput: TextInput) {
        updateCounter()
        delegate?.animatedTextInputDidChange?(animatedTextInput: self)
    }

    open func textInput(textInput: TextInput, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let rtn:Bool = delegate?.animatedTextInput?(animatedTextInput: self, shouldChangeCharactersIn: range, replacementString: string) ?? true;
        
        //IF CHARACTERS-LIMIT <= ZERO, MEANS NO RESTRICTIONS ARE APPLIED
        if (self.maxCharLimit <= 0 || rtn == false) {
            return rtn;
        }
        
        guard let text = textInput.currentText else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return (newLength <= self.maxCharLimit) // Bool
    }

    open func textInputShouldBeginEditing(textInput: TextInput) -> Bool {
        return delegate?.animatedTextInputShouldBeginEditing?(animatedTextInput: self) ?? true
    }

    open func textInputShouldEndEditing(textInput: TextInput) -> Bool {
        return delegate?.animatedTextInputShouldEndEditing?(animatedTextInput: self) ?? true
    }

    open func textInputShouldReturn(textInput: TextInput) -> Bool {
        return delegate?.animatedTextInputShouldReturn?(animatedTextInput: self) ?? true
    }
}

public protocol TextInput {
    var view: UIView { get }
    var currentText: String? { get set }
    var font: UIFont? { get set }
    var textColor: UIColor? { get set }
    var textAttributes: [String: Any]? { get set }
    weak var textInputDelegate: TextInputDelegate? { get set }
    var currentSelectedTextRange: UITextRange? { get set }
    var currentBeginningOfDocument: UITextPosition? { get }
    var contentInset: UIEdgeInsets { get set }

    func changeKeyboardType(with newKeyboardType: UIKeyboardType)
    func changeReturnKeyType(with newReturnKeyType: UIReturnKeyType)
    func currentPosition(from: UITextPosition, offset: Int) -> UITextPosition?
    func changeClearButtonMode(with newClearButtonMode: UITextFieldViewMode)
}

public extension TextInput where Self: UIView {
    var view: UIView {
        return self
    }
}

public protocol TextInputDelegate: class {
    func textInputDidBeginEditing(textInput: TextInput)
    func textInputDidEndEditing(textInput: TextInput)
    func textInputDidChange(textInput: TextInput)
    func textInput(textInput: TextInput, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func textInputShouldBeginEditing(textInput: TextInput) -> Bool
    func textInputShouldEndEditing(textInput: TextInput) -> Bool
    func textInputShouldReturn(textInput: TextInput) -> Bool
}

public protocol TextInputError {
    func configureErrorState(with message: String?)
    func removeErrorHintMessage()
}

public extension CATextLayer {
    /// Describes how individual lines of text are aligned within the layer.
    ///
    /// - natural: Natural alignment.
    /// - left: Left alignment.
    /// - right: Right alignment.
    /// - center: Center alignment.
    /// - justified: Justified alignment.
    enum Alignment {
        case natural
        case left
        case right
        case center
        case justified
    }
}

fileprivate extension Dictionary {
    mutating func merge(dict: [Key: Value]) -> Dictionary {
        for (key, value) in dict { self[key] = value }
        return self
    }
}

