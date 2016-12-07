# TanVIPER 一个使用VIPER架构的Demo
原文链接: [探究在iOS开发中实现VIPER架构](http://tangent.gift/2016/12/07/探究在iOS开发中实现VIPER架构/)

# 探究在iOS开发中实现VIPER架构
## 前言 
在软件开发中，架构是至关重要的一部分，就好比盖房子需要基本的钢筋石桩等骨架，常听到的架构有`MVC`、`MVP`、`MVVM`、`VIPER`等，其中，`MVC`是我们最常用的软件架构模式，而苹果的整个API框架都是使用`MVC`作为架构的，所以我们会看到一些iOS的API中有这些类:`UIXXXViewController`、`UIXXXView`，而现在比较兴起的架构当属`MVP`和`MVVM`，我个人觉得这它们是非常相似的，但在之前我使用第三方函数式、响应式框架`RxSwift`或`ReactiveCocoa`去实现`MVP`或`MVVM`架构时，我自认为，`MVP`中的`Presenter`专注于事件、数据的转换，成为`View`层及`Model`层的一条流通管道，而`MVVM`中的`ViewModel`更像是一个装有视图显示数据的，并带有一些显示逻辑处理的分层，然后我们可以将`ViewModel`中的显示数据与`View`中的视图进行响应式绑定（个人观点，若有误，望各位纠正）。在现在的开发中，我也是使用`MVP`或`MVVM`架构。而`VIPER`架构，一开始我是只听过其名，并未深入了解，也并未实战使用，直到某个契机我看到大神[@罗琦aidenluo](http://weibo.com/u/1840543654)的iOS架构讲解视频，了解到了`VIPER`架构，受益匪浅，这篇文章是我对`VIPER`学习以及实践的总结，主要简单介绍`VIPER`架构以及其怎样使用`Swift3.0`语言在iOS平台上实现。

文章所对应的代码我已经放到了我的Github上[TanVIPER](https://github.com/TangentW/TanVIPER)，欢迎Click入~
## 什么是 VIPER
传统的`MVC`架构中，我们都知道，其`Controller(控制器)`层接纳了太多的任务，当开发不断进行，其内部的业务逻辑逐渐积累，最后则会变得臃肿不堪，不便于后期的调试测试以及多人协助，所以，我们需要寻找减轻`Controller`层负担的方法，而`VIPER`架构其实是将`Controller`再细分成三层，分别是`View`、`Interactor`、`Presenter`，已达到减轻`Controller`层负担的作用。

`VIPER`中每个字母的意思是如下：

* **V: View**  **视图**：在这里并不是指传统的`UIView`或其子类，事实上它就是`UIViewController`，在前面所说到，`VIPER`架构主要是将`MVC`架构中的`Controller`进行更加细致的划分，而`View(视图)`层则是主要负责一些视图的显示、布局，用户事件的接受以及转发，基本的显示逻辑处理等等工作。
* **I: Interactor**  **交互器**：其为`VIPER`的中心枢纽，主要负责交互的工作，例如数据的请求（网络请求、本地持久化层请求）、某些业务逻辑的处理，在这里我们得到的数据是原始数据，需要经过解析处理转换成能够直接应用于视图的视图模型数据，所以我们需要用到了下一层`Presenter(展示器)`。
* **P: Presenter**  **展示器**：当我们在上一层`Interactor(交互器)`中获得原始数据后，我们需要将数据进行解析处理，比如我们在交互器中进行了网络请求，得到了json数据，若要将json中所包含的内容显示出来，我们则需要将json数据进行解析，展示器就是专注于数据的解析转换，将原始的数据转换成最终能够直接显示在试图上的视图模型数据。此外，展示器中还带有路由器`Router`，可以进行路由的操作。
* **E: Entity**  **实体模型对象**
* **R: Router**  **路由器**： 负责视图的跳转，因为使用`VIPER`架构需要进行各层之间的相互绑定，所以视图的跳转不能简单地使用原始的方法。

下面是一张`VIPER`的简单逻辑图：
![](http://7xsfp9.com1.z0.glb.clouddn.com/viper.jpeg)
图中，箭头代表着数据流的传递，我们可以看到，在`VIPER`架构中，数据的流向总是`单向流动`，在`View`、`Interactor`、`Presenter`三层中形成了一个流动闭环，而在其他的某些架构中，如`MVC`、`MVP`、`MVVM`，它们的数据在中间层会有着双向的流动，`VIPER`较它们而言，其更加约束了整个软件的架构，每一层功能特定，数据的流向单一，使得软件在开发中对原架构的高度切合。

## 如何配置 VIPER
在对`VIPER`架构的实现中，我是基于[@罗琦aidenluo](http://weibo.com/u/1840543654)的`VIP`架构思想，稍作添加改动。使用的语言是`Swift 3.0`。

### 协议
我们先指定好一套协议，用于规范好`VIPER`各层间的绑定与联系。
```Swift
//  MARK: - Protocol
protocol ViewToInteratorPipline {
    func refresh(request: Request)
}

protocol InteratorToPresenterPipline {
    func present(response: Response)
}

protocol PresenterToViewPipline {
    func display(viewModel: ViewModel)
}

protocol Request { }

protocol Response { }

protocol ViewModel { }
```
如上，有三个管道协议，用于连通`View`、`Interactor`、`Presenter`三层；在`View`通向`Interactor`管道中，通过方法`refresh(request:)`来让`View`请求`Interactor`去进行刷新；在`Interactor`通向`Presenter`管道中，通过方法`present(response:)`来让`Interactor`将原始数据传递给`Presenter`让其进行数据的解析处理；在`Presenter`通向`View`管道中，通过`display(viewModel:)`方法来让`Presenter`将视图模型传递给`View`然后让其显示。三层环环相扣。

### 抽象基类
在之前曾想过使用`Swift`的面向协议编程来对各层进行实现，但是考虑到一些动态创建以及各层的绑定问题，所以最后使用的是抽象基类方法。
```Swift
//  MARK: - Abstract Class
class View: ViewController, PresenterToViewPipline {
    
    final let interator: Interactor
    
    required init(interator: Interactor) {
        self.interator = interator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func display(viewModel: ViewModel) {
        fatalError("display(viewModel:) is an abstract function")
    }
    
    func show(route: Router, userInfo: Any?) {
        fatalError("show(route:userInfo:) is an abstract function")
    }
}

class Interactor: ViewToInteratorPipline {
    
    final let presenter: Presenter
    
    required init(presenter: Presenter) {
        self.presenter = presenter
    }
    
    func refresh(request: Request) {
        fatalError("refresh(request:) is an abstract function")
    }
}

class Presenter: InteratorToPresenterPipline {
    
    private final weak var _view: View? {  //  !! Weak !!
        didSet {
            self._router = Router(presenter: self)
        }
    }
    
    private final var _router: Router?
    
    final var view: View? {
        set {
            assert(self._view == nil, "view has already set!")
            self._view = newValue
        }
        
        get {
            return self._view
        }
    }
    
    final var router: Router? {
        get {
            return self._router
        }
    }
    
    required init() { }
    
    func present(response: Response) {
        fatalError("response(Response:) is an abstract function")
    }
}
```
如上代码所示，定义了三个抽象基类，分别代表了`View`、`Interactor`、`Presenter`三层，它们各自实现了管道协议，每一个抽象基类中都持有其下一层的基类，在构造方法中进行初始化。如`View`类中持有了`Interactor`类的属性，作用是进行层与层之间的数据传输。
这里细讲一下：

* **View**是直接继承于`ViewController`的，所以在`VIPER`中，我们将`View`指代了`ViewController`，并且，`View`除了实现管道协议外，其内部还有一个`show(router:userInfo:)`的抽象方法，此方法可用于路由跳转时数据的传输，将一些数据在跳转前传输到目标跳转视图中。
* **Presenter**中的`View`是`weak`弱引用类型，因为在`View`、`Interactor`、`Presenter`三层绑定时有引用环形成，如果不将引用环中的某个引用设为弱引用，则会出现`循环引用`现象。此外，`Presenter`中还具有路由器`Router`，我们在`Presenter`中可以利用路由器进行页面的跳转。

### 绑定器与联合体
我们在使用`VIPER`时，需要将各层进行绑定，比如`OneView`的交互器要绑定`OneInteractor`，而`OneInteractor`的展示器要绑定`OnePresenter`，因为绑定的操作频繁，所以我这里将层之间的绑定操作封装成了绑定器`Binder`。联合体就是将要绑定在一起的`View`、`Interactor`、`Presenter`封装成模型。
```Swift
//  MARK: - Unity
struct Unity {
    let viewType: View.Type
    let interatorType: Interactor.Type
    let presenterType: Presenter.Type
}

extension Unity: ExpressibleByArrayLiteral {
    
    typealias Element = AnyClass
    
    init(arrayLiteral elements: Unity.Element...) {
        assert(elements.count == 3)
        guard let viewType = elements[0] as? View.Type else { assert(false) }
        guard let interactorType = elements[1] as? Interactor.Type else { assert(false) }
        guard let presenterType = elements[2] as? Presenter.Type else { assert(false) }
        self.viewType = viewType
        self.interatorType = interactorType
        self.presenterType = presenterType
    }
}

//  MARK: - Binder
class Binder {
    
    static var unitySet: [String: Unity] = [:]
    
    static func addUnity(_ unity: Unity, identifier: String) {
        self.unitySet[identifier] = unity
    }
    
    static func obtainView(identifier: String) -> View? {
        guard let unity = self.unitySet[identifier] else { return nil }
        
        //  Bind
        let presenter = unity.presenterType.init()
        let interator = unity.interatorType.init(presenter: presenter)
        let view = unity.viewType.init(interator: interator)
        presenter.view = view
        return view
    }
    
}
```

* **Unity** 联合体实现了字面量表达式的协议，我们能直接通过列表来构建联合体，而在联合体中储存的是三个分层的类型，用于绑定器的分层动态生成与绑定。
* **Binder** 绑定器职责是将其里面储存的联合体中的三个分层进行绑定， 我们通过`obtainView(identifier:)`方法，传入标识符对`View`进行索取，在此方法返回前，就自动帮我们进行三层的绑定。在对`View`进行索取前，必须先进行联合体的添加配置，使用的是`addUnity(_, identifier:)`方法，一般我们可以在`AppDelegate`的`application(_, didFinishLaunchingWithOptions:)`方法中进行绑定器的初始化配置。

### 路由器
路由器主要是负责视图的跳转，它位于`Presnter`层，以下是它的代码：
```Swift
//  MARK: - Router
enum RouteType {
    case root(identifier: String)
    case push(identifier: String)
    case modal(identifier: String)
    case back
}

extension RouteType {
    var identifier: String? {
        switch self {
        case let .root(identifier):
            return identifier
        case let .push(identifier):
            return identifier
        case let .modal(identifier):
            return identifier
        default:
            return nil
        }
    }
    
    var view: View? {
        guard let identifier = self.identifier else { return nil}
        return Binder.obtainView(identifier: identifier)
    }
}

class Router {
    
    let presenter: Presenter?
    
    required init(presenter: Presenter? = nil) {
        self.presenter = presenter
    }
    
    func route(type: RouteType, userInfo: Any?) {
        let view = type.view
        view?.show(router: self, userInfo: userInfo)
        switch type {
        case .root:
            UIApplication.shared.keyWindow?.rootViewController = view
        case .push:
            if let view = view { self.presenter?.view?.navigationController?.pushViewController(view, animated: true) }
        case .modal:
            if let view = view { self.presenter?.view?.present(view, animated: true, completion: nil) }
        case .back:
            guard let view = presenter?.view else { return }
            if view.presentationController != nil {
                view.dismiss(animated: true, completion: nil)
            } else {
                _ = view.navigationController?.popViewController(animated: true)
            }
        }
    }
}
```
我定义的这个路由器比较简单，有四种跳转的方式：
1. 模态跳转
2. 导航跳转
3. 根视图切换
4. 返回
其中，根视图切换是针对应用程序主窗口`KeyWindow`的根视图进行切换，一般在应用程序启动时应用。

这里，我们进行跳转不像是传统的那样传入`ViewController`实例，而是直接传入联合体的标识符，路由器会利用此标识符经过绑定器的动态生成及绑定，获取到要跳转的视图，从而进行跳转。
在跳转时，我们可以将一些附带数据传入`userInfo`参数中，这些数据能在跳转前于目标跳转视图的`show(router:userInfo:)`方法中获取到。

---
到此，`VIPER`架构的基本配置就已经搭好了。

## 使用 VIPER
下面我们通过`VIPER`架构来做一个实例，主要包含两个需求，一个是用户的登录，另一个是视图的跳转。
上GIF图~
![](http://7xsfp9.com1.z0.glb.clouddn.com/instance.gif)
如图所示，主页面有两个按钮，一个是用于将视图跳转到另一个页面，二哥则是将输入的用户名及密码进行验证登录。

下面就开工吧~
### 服务器端构建
服务器端这里我写的比较简单，只是进行一些死数据的判断以及json输出，使用的是`PHP`语言：
```PHP
<?php
//  TanVIPER Server

$userName = isset($_POST['user_name']) ? $_POST['user_name'] : '';
$password = isset($_POST['password']) ? $_POST['password'] : '';

$out = check($userName, $password);
echo json_encode($out, JSON_UNESCAPED_UNICODE);

//  Code: 200  --> Success , 300  --> Faild
//  Function
function check($userName, $password) {
    if ($userName == 'tangent') {
        if ($password == '123456') {
            $userInfo = array('name' => 'tangent', 'gender' => 1, 'token' => '11233', 'age' => 20);
            return array('code' => 200, 'message' => '登录成功', 'user_info' => $userInfo);
        } else {
            return array('code' => 300, 'message' => '密码错误');
        }
    } else {
        return array('code' => 300, 'message' => '不存在此用户');
    }
}
?>
```
---

接下来，就是手机iOS端的搭构

### 依赖
在此实例中涉及了网络请求、json数据解析、自动布局等等需求，所以我们利用`CocoaPods`引入一些第三方依赖库。

* Moya 用于网络请求
* SnapKit 用于自动布局
* Argo、Curry 用于JSON数据转模型

### 实体 Entity
这个项目有两个联合体，我分别起名叫`One`和`Two`：
```Swift
//  MARK: - VIPERs
enum VIPERs: String {
    case one
    case two
}

extension VIPERs {
    var identifier: String {
        return self.rawValue
    }
}
```
在前面说到，绑定器以及路由都是通过联合体的标识符来唯一标识的，所以这里我让枚举的原始值类型为字符串，并在扩展中添加了获取标识符的方法。

--- 
针对不同的联合体，`Request`、`Response`、`ViewModel`有所不同，所以这里我们定义两个联合体的各种实体模型：
```Swift
//  One
enum OneRequest: Request {
    case jump
    case login(userName: String, password: String)
}

enum OneResponse: Response {
    case jumpResponse(viper: VIPERs)
    case loginResponse(json: Any?)
}

struct OneViewModel: ViewModel {
    
    let alertMessage: String
    
    init(alertMessage: String) {
        self.alertMessage = alertMessage
    }
}

//  Two
enum TwoRequest: Request {
    case back
}

enum TwoResponse: Response {
    case back
}
```
---
当我们启动应用时，我们需要对`Binder(绑定器)`进行初始化，将应用的所以联合体进行添加配置，这里我就封装了一个结构体，专门用于绑定器的初始化：
```Swift
//  MARK: - BinderHelper
struct BinderHelper {
    static func initBinder() {
        Binder.addUnity([OneView.self, OneInteractor.self, OnePresenter.self], identifier: VIPERs.one.identifier)
        Binder.addUnity([TwoView.self, TwoInteractor.self, TwoPresenter.self], identifier: VIPERs.two.identifier)
    }
}
```
我们在应用刚启动的时候就可以调用里面的初始化方法。

---
我将从网络获取到的响应数据以及其中的用户数据封装成一个模型实体：
```Swift
//  MARK: - User
enum UserGender: String {
    case male = "男"
    case female = "女"
}

struct User {
    let name: String
    let age: Int
    let gender: UserGender
    let token: String
}

extension User: CustomStringConvertible {
    var description: String {
        return "姓名: \(self.name), 年龄: \(self.age), 性别: \(self.gender.rawValue), 令牌: \(self.token)"
    }
}

extension User: Decodable {
    
    static func decode(_ json: JSON) -> Decoded<User> {
        
        let genderMapper: (Int) -> UserGender = { genderType in
            if genderType == 1 {
                return .male
            } else {
                return .female
            }
        }
        
        return curry(self.init)
            <^> json <| "name"
            <*> json <| "age"
            <*> (genderMapper <^> json <| "gender")
            <*> json <| "token"
    }
}

//  MARK: - Network Response
enum NetworkResponse {
    case faild(message: String)
    case success(user: User)
}

extension NetworkResponse: Decodable {
    
    init(code: Int, message: String, userInfo: User?) {
        if let user = userInfo, code == 200 {
            self = .success(user: user)
        } else {
            self = .faild(message: message)
        }
    }
    
    static func decode(_ json: JSON) -> Decoded<NetworkResponse> {
        return curry(self.init)
            <^> json <| "code"
            <*> json <| "message"
            <*> json <|? "user_info"
    }
}
```
其中，实体的`Decodable`扩展是`Argo`框架中用于json的数据转模型的实现。

---
由于我们使用了网络请求框架`Moya`，它需要我们提供一个请求的目标实体：
```Swift
//  MARK: - Network Request
enum NetworkRequest {
    case login(userName: String, password: String)
}

extension NetworkRequest: TargetType {
    
    var baseURL: URL {
        return URL(string: "http://127.0.0.1")!
    }
    
    var path: String {
        switch self {
        case .login:
            return "/projects/tanviper.php"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var parameters: [String: Any]? {
        switch self {
        case let .login(userName, password):
            return ["user_name": userName, "password": password]
        }
    }
    
    var sampleData: Data {
        return "{\"code\": \"300\", \"message\": \"不存在此用户\"}".data(using: .utf8)!
    }
    
    var task: Task {
        return .request
    }
}
```
这个请求实体只有一项登录功能，在这里，我连接的是本地的服务器。

### One 联合体
接下来就开始构建联合体了，先看回上面所说到的用于初始化绑定器的实体的绑定器初始化方法：
```Swift
        Binder.addUnity([OneView.self, OneInteractor.self, OnePresenter.self], identifier: VIPERs.one.identifier)
        Binder.addUnity([TwoView.self, TwoInteractor.self, TwoPresenter.self], identifier: VIPERs.two.identifier)
```
我们可以看到，对于One联合体来说，它的组成为`OneView`、`OneInteractor`、`OnePresenter`，对于Two联合体来说是`TwoView`、`TwoInteractor`、`TwoPresenter`，所以我们需要创建这两个联合体的每个组成部分。

对于One联合体：
#### View
```Swift
import UIKit
import SnapKit

class OneView: View {

    //  MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.buttonListener = OneViewButtonListener(jump: { 
            self.interator.refresh(request: OneRequest.jump)
        }, login: {
            self.interator.refresh(request: OneRequest.login(userName: self.userNameInput.text!, password: self.passwordInput.text!))
            self.loginButton.isEnabled = false
        })
        
        self.view.addSubview(self.jumpButton)
        self.view.addSubview(self.loginButton)
        self.view.addSubview(self.userNameInput)
        self.view.addSubview(self.passwordInput)
        
        self.layoutViews()
    }

    //  Override
    override func display(viewModel: ViewModel) {
        self.loginButton.isEnabled = true
        let alertMessage = (viewModel as! OneViewModel).alertMessage
        self.alertController.message = alertMessage
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func show(router: Router, userInfo: Any?) {
        
    }
    
    //  MARK: - Pirvate Function
    private func layoutViews() {
        let viewHeight: CGFloat = 45
        let viewMargin: CGFloat = 30
        
        self.jumpButton.snp.makeConstraints { [unowned self] maker in
            maker.height.equalTo(viewHeight)
            maker.left.right.equalTo(self.view).inset(UIEdgeInsets(top: 0, left: viewMargin * 0.5, bottom: 0, right: viewMargin))
            maker.bottom.equalTo(self.view.snp.centerY).offset(-viewMargin)
        }
        
        self.loginButton.snp.makeConstraints { [unowned self] maker in
            maker.height.left.right.equalTo(self.jumpButton)
            maker.top.equalTo(self.view.snp.centerY).offset(viewMargin * 0.5)
        }
        
        self.userNameInput.snp.makeConstraints { [unowned self] maker in
            maker.height.left.right.equalTo(self.jumpButton)
        }
        
        self.passwordInput.snp.makeConstraints { [unowned self] maker in
            maker.height.left.right.equalTo(self.jumpButton)
            maker.top.equalTo(self.userNameInput.snp.bottom).offset(viewMargin)
            maker.bottom.equalTo(self.jumpButton.snp.top).offset(-viewMargin)
        }
    }
    
    private func initButton(_ button: UIButton, title: String, onClick: Selector) -> UIButton {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.orange
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.gray, for: .highlighted)
        button.addTarget(self.buttonListener, action: onClick, for: .touchUpInside)
        return button
    }
    
    private func initTextField(_ textField: UITextField, placeHolder: String) -> UITextField {
        textField.backgroundColor = UIColor.green
        textField.textColor = UIColor.darkGray
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 8
        textField.placeholder = placeHolder
        return textField
    }
    
    //  MARK: - Lazy
    private lazy var jumpButton: UIButton = {
        return self.initButton($0, title: "跳转", onClick: #selector(OneViewButtonListener.onJumpButtonClick))
    }(UIButton())
    
    private lazy var loginButton: UIButton = {
        return self.initButton($0, title: "登录", onClick: #selector(OneViewButtonListener.onLoginButtonClick))
    }(UIButton())
    
    private lazy var userNameInput: UITextField = {
        return self.initTextField($0, placeHolder: "用户名")
    }(UITextField())
    
    private lazy var passwordInput: UITextField = {
        return self.initTextField($0, placeHolder: "密码")
    }(UITextField())
    
    private lazy var alertController: UIAlertController = {
        let action = UIAlertAction(title: "确认", style: .default, handler: nil)
        $0.addAction(action)
        return $0
    }(UIAlertController(title: "登录提示", message: nil, preferredStyle: .alert))
    
    //  MARK: - Button Listener
    private var buttonListener: OneViewButtonListener?
    
    //  MARK: - Event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

fileprivate class OneViewButtonListener {
    
    let jumpButtonClickCallback: () -> ()
    let loginButtonClickCallback: () -> ()
    
    init(jump: @escaping () -> (), login: @escaping () -> ()) {
        self.jumpButtonClickCallback = jump
        self.loginButtonClickCallback = login
    }
    
    @objc func onJumpButtonClick() {
        self.jumpButtonClickCallback()
    }
    
    @objc func onLoginButtonClick() {
        self.loginButtonClickCallback()
    }
}
```
在`View`中，进行的是视图的显示、布局以及用户事件的转发，可以看到，当两个按钮被用户点击时，`Interactor`的`refresh(request:)`方法会被调用，事件及数据转发到了`Interactor`中。

#### Interactor
```Swift
import UIKit
import Moya

class OneInteractor: Interactor {
    
    let provider: MoyaProvider<NetworkRequest> = MoyaProvider<NetworkRequest>()
    
    override func refresh(request: Request) {
        let request = request as! OneRequest
        switch request {
        case .jump:
            self.presenter.present(response: OneResponse.jumpResponse(viper: .two))
        case let .login(userName, password):
            self.provider.request(.login(userName: userName, password: password), completion: { result in
                var json: Any? = nil
                switch result {
                case .failure: ()
                case let .success(response):
                    json = try? response.mapJSON()
                }
                self.presenter.present(response: OneResponse.loginResponse(json: json))
            })
        }
    }
}
```
在这里，我们接收到上一层`View`传来的请求数据，根据这些请求，我们进一步处理：

* 当接收到跳转请求时，通知展示器进行路由跳转
* 当接收到登录请求是，向网络发送请求，并将得到的请求结果json数据传递到展示器要求其进行解析。

#### Presenter
```Swift
import UIKit
import Argo

class OnePresenter: Presenter {
    override func present(response: Response) {
        let response = response as! OneResponse
        switch response {
        case let .jumpResponse(viper):
            self.router?.route(type: .modal(identifier: viper.identifier), userInfo: "From One To Two | One --> Two")
        case let .loginResponse(json):
            var alertMessage = ""
            if let json = json {
                let networkResponse: NetworkResponse = decode(json)!
                switch networkResponse {
                case let .faild(message):
                    alertMessage = "登录失败,\(message)"
                case let .success(user):
                    alertMessage = "登录成功,\(user)"
                }
            } else {
                alertMessage = "网络请求或数据解析错误"
            }
            self.view?.display(viewModel: OneViewModel(alertMessage: alertMessage))
        }
    }
}
```
展示器可通过自身的路由器属性进行页面的跳转，在跳转时能够向目标视图传递数据，就想这里我们向目标试图传递了一串字符串。当接收到上一层`Interactor`的原始数据后，展示器进行解析处理，然后最后输出能够直接应用于视图显示的视图模型`ViewModel`，通知视图层去显示。

### Two 联合体
Two 联合体相对较简单，这里我只列出了代码，不做解释。
```Swift
//  MARK: - View
class TwoView: View {
    
    var showMessage: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orange
        self.view.addSubview(self.showView)
        self.showView.snp.makeConstraints { [unowned self] maker in
            maker.center.equalTo(self.view)
        }
        self.showView.text = self.showMessage
    }
    
    override func show(router: Router, userInfo: Any?) {
        self.showMessage = userInfo as? String
    }
    
    //  MARK: - Lazy
    private lazy var showView: UILabel = {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 23)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.interator.refresh(request: TwoRequest.back)
    }
    
    //  Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

//  MARK: - Interactor
class TwoInteractor: Interactor {
    override func refresh(request: Request) {
        self.presenter.present(response: TwoResponse.back)
    }
}

//  MARK: - Presenter
class TwoPresenter: Presenter {
    override func present(response: Response) {
        switch response as! TwoResponse {
        case .back:
            self.router?.route(type: .back, userInfo: nil)
        }
    }
}
```
### AppDelegate
最后，我们需要在`AppDelegate`中进行应用程序初始化配置：
```Swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //  Init Window
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        window.makeKeyAndVisible()
        self.window = window
        //  Init Binder
        BinderHelper.initBinder()
        //  Router
        Router().route(type: .root(identifier: VIPERs.one.identifier), userInfo: nil)
        return true
    }
```
---
到此为止，整个基于`VIPER`架构的小Demo就完成了。

## 总结 & 链接
本文架构设计灵感源于[@罗琦aidenluo](http://weibo.com/u/1840543654)的`VIP`架构设计思想，在这里我也感谢大神的指点，让我对`VIPER`架构有着更深层的了解。

本人为iOS开发菜鸟一只，若文章中某些话语不严谨或出现技术性错误，还请各位提点意见，也欢迎各位在评论区进行讨论，在这里也祝大家冬日愉快~

文章中实例的Github链接：[TanVIPER](https://github.com/TangentW/TanVIPER)


